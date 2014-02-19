#!/bin/bash

# grub acrive name 
ARC="grub.tar.gz"
#Get grub legacy url 
URL="ftp://alpha.gnu.org/gnu/grub/grub-0.97.tar.gz"

#wget options
WGET='/usr/bin/wget'
WGET_OPT="-O ${ARC}"

#tar options
TAR="/bin/tar"
TAR_OPT="-zxvf"

#Conf options
CONF='--enable-diskless'

#download grub
${WGET} ${WGET_OPT} ${URL}
#explode grub
${TAR} ${TAR_OPT} ${ARC}

#change to grub source directory
cd grub-0*

DISKLESS=$(./configure --help | grep driver |tr -s ' '| sed -e 's/\ enable\ / /' -e 's/^\ //'|cut -f1 -d' ')
for d in ${DISKLESS}
do
 ./configure ${CONF} ${d}
 make
 mv netboot/ 
done
