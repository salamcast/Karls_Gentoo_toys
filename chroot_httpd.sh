#!/bin/sh
#
# (c) Copyright by Wolfgang Fuschlberger
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#    ( http://www.fsf.org/licenses/gpl.txt )

# first Release: 2004-07-30
# latest update: 2006-04-20
# Jy update: 2006-04-25 (apache chroot)
#
# The latest version of the script is available at
#   http://www.fuschlberger.net/programs/ssh-scp-chroot-jail/
#
# Feedback is welcome!
#
# Thanks for Bugfixes / Enhancements to
# Michael Prokop <http://www.michael-prokop.at/chroot/>,
# Randy K., Randy D. and Jonathan Hunter.

#
# Features:
# - enable scp and sftp in the chroot-jail
# - use one directory (default /home/jail/) as chroot for all users
################################################################################

if [ "$(whoami)" != "root" ]; then
  echo "Error: You must be root to run this command." >&2
  exit 1
fi

# Specify the apps you want to copy to the jail
APPS="/bin/bash /bin/cp /usr/bin/dircolors /bin/ls /bin/sh /bin/su /usr/bin/id /usr/bin/nc /usr/sbin/httpd /usr/lib/httpd/modules/libphp5.so /usr/lib/httpd/modules/libphp4.so"

# Check if we are called with username or update
if [ -z "$1" ]; then
  echo
  echo "Error: Parameter missing. Did you forget the apache chroot dir?"
  echo
  echo "Creating new chrooted account:"
  echo "Usage: $0 dir"
  echo
  exit
fi

# Check existence of necessary files
echo -n "Checking for chroot... "
if [ `which chroot` ];
then
    echo "OK";
else
    echo "failed
    Please install chroot-package/binary!
    "
    exit 1
fi

JAILPATH=/chroot/$1

# make common jail for everybody if inexistent
if [ ! -d $JAILPATH ]; then
    mkdir -p $JAILPATH
    echo "Creating $JAILPATH"
fi
cd $JAILPATH

# Create directories in jail that do not exist yet
JAILDIRS="dev etc bin home sbin usr usr/bin usr/sbin var/log/httpd lib var/lib/php/session usr/lib/php/modules var/run usr/lib/httpd/modules usr/lib/httpd/build"
for directory in $JAILDIRS; do
    if [ ! -d "$JAILPATH/$directory" ]; then
        mkdir -p $JAILPATH/"$directory"
        echo "Creating $JAILPATH/$directory"
    fi
done
echo



# Creating necessary devices
[ -r $JAILPATH/dev/urandom ] || mknod $JAILPATH/dev/urandom c 1 9
[ -r $JAILPATH/dev/null ]    || mknod $JAILPATH/dev/null    c 1 3
[ -r $JAILPATH/dev/zero ]    || mknod $JAILPATH/dev/zero    c 1 5
[ -r $JAILPATH/dev/tty ]     || mknod $JAILPATH/dev/tty     c 5 0 && chmod 666 $JAILPATH/dev/tty


# Copy the apps and the related libs
echo "Copying necessary library-files to jail (may take some time)"

# The original code worked fine on RedHat 7.3, but did not on FC3.
# On FC3, when the 'ldd' is done, there is a 'linux-gate.so.1' that
# points to nothing (or a 90xb.....), and it also does not pick up
# some files that start with a '/'. To fix this, I am doing the ldd
# to a file called ldlist, then going back into the file and pulling
# out the libs that start with '/'
#
# Randy K.
#
# The original code worked fine on 2.4 kernel systems. Kernel 2.6
# introduced an internal library called 'linux-gate.so.1'. This
# 'phantom' library caused non-critical errors to display during the
# copy since the file does not actually exist on the file system.
# To fix re-direct output of ldd to a file, parse the file and get
# library files that start with /
#
if [ -x /root/ldlist ]; then
    mv /root/ldlist /root/ldlist.bak
fi
if [ -x /root/lddlist2 ]; then
    mv /root/lddlist2 /root/lddlist2.bak
fi

for app in $APPS;  do

    # First of all, check that this application exists
    if [ -x $app ]; then
        # Check that the directory exists; create it if not.
        app_path=`echo $app | sed -e 's#\(.\+\)/[^/]\+#\1#'`
        if ! [ -d .$app_path ]; then
            mkdir -p .$app_path
        fi

        # If the files in the chroot are on the same file system as the
        # original files you should be able to use hard links instead of
        # copying the files, too. Symbolic links cannot be used, because the
        # original files are outside the chroot.
        cp -p $app .$app

        # get list of necessary libraries
        ldd $app >> /root/ldlist
    fi
done

# Clear out any old temporary file before we start
if [ -e /root/ldlist2 ]; then
    rm /root/ldlist2
fi
for libs in `cat /root/ldlist`; do
   frst_char="`echo $libs | cut -c1`"
   if [ "$frst_char" = "/" ]; then
     echo "$libs" >> /root/ldlist2
   fi
done
for lib in `cat /root/ldlist2`; do
    mkdir -p .`dirname $lib` > /dev/null 2>&1

    # If the files in the chroot are on the same file system as the original
    # files you should be able to use hard links instead of copying the files,
    # too. Symbolic links cannot be used, because the original files are
    # outside the chroot.
    cp $lib .$lib
done

#
# Now, cleanup the 2 files we created for the library list
#
/bin/rm -f /root/ldlist
/bin/rm -f /root/ldlist2

# Necessary files that are not listed by ldd
cp /lib/libnss_compat.so.2 /lib/libnsl.so.1 /lib/libnss_files.so.2 /lib/libcap.so.1 /lib/libnss_dns.so.2 ./lib/


# if you are using PAM you need stuff from /etc/pam.d/ in the jail,
echo "Copying files from /etc/pam.d/ to jail"
cp -r /etc/pam.d ./etc/

# ...and of course the PAM-modules...
echo "Copying PAM-Modules to jail"
cp -r /lib/security ./lib/

# ...and something else useful for PAM
#echo "Copying /etc/security to jail"
cp -r /etc/security ./etc/
cp /etc/login.defs ./etc/
cp -rf /etc/host.conf /etc/nsswitch.conf /etc/resolv.conf ./etc

echo "Copying over the apache/php configs"
cp -rf /etc/httpd ./etc/
cp -rf /etc/php.d ./etc/
cp -rf /etc/php.ini ./etc/
cp /etc/mime.types ./etc/
cp -rf /usr/lib/php/modules/* ./usr/lib/php/modules/
cp -rf /usr/lib/httpd/modules/* ./usr/lib/httpd/modules/
cp -rf /usr/lib/httpd/build/* ./usr/lib/httpd/build/
chown apache:apache ./var/lib/php/session

echo $2
if [ -n "$2" ]
then
    echo "Copying over the doc root: $2"
    cp -rf $2 .$2
else
    mkdir -p ./var/www
    mkdir -p ./var/www/cgi-bin
    cp -rf /var/www/error ./var/www
    cp -rf /var/www/icons ./var/www
    mkdir -p ./var/www/html
fi

echo "Copying over the logs"
cp -rf /var/log/httpd ./var/log/

echo "Grabbing the apache user"
grep apache /etc/passwd > ./etc/passwd
grep apache /etc/group > ./etc/group


exit
