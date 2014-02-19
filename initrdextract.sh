#!/bin/bash

#Global Variables
folder=""
initrd=""
extract=1
version="0.1"
name="$0"

#functions
function showversion()
{
	echo "$version"
}

function showhelp()
{
	echo "Usage: $name -c|[-e] [-f <folder>] [-i <initrd>]"
        echo 

        echo "Extracts an initrd/initramfs to a folder OR compresses a folder back into an initrd/initramfs."

        echo -e "-c, --compress\tTell the script to compress the given folder into the given initramfs."
        echo -e "-e, --extract\tTell the script to extract the given initramfs into the given folder."
        echo -e "\t\tDefault Action"
        echo -e "-f, --folder\tSpecifies the folder to use. If extracting folder will be created if it doesn't exist."
	echo -e "\t\tDefault: extracted-<timestamp> in current folder"
        echo -e "-i, --initrd\tSpecifies the Initrs file to extract or to create."
	echo -e "\t\tDefault: initrd-<timestamp> in current folder."
        echo -e "-v, --version\tDisplays the scripts version"
        echo -e "-h, --help\tDisplays this help information"
	
	echo
        echo "Report bugs to <bugs@kororaa.org>"	
}

function extractinitrd()
{
	folder=$1
	initrd=$2

	if [ ! -d $folder ]
	then
		#folder doesn't exist, so lets create it.
		mkdir -p $folder
	fi

	#extract the initrd
	#We want to use the full path to the folder, so lets check to see if it is indeed the full path.
	if [ -z "`echo "$folder" |grep "^/"`" ]
	then
		#reletive not full path
		folder="$PWD/$folder"
	fi

	#check to see if the initrd uses the full path
	 if [ -z "`echo "$initrd" |grep "^/"`" ]
        then
                #reletive not full path
                initrd="$PWD/$initrd"
        fi
	
	#now we can extract the uncompressed initrd	
	cat $initrd |gunzip |( exitval=0 ; while [ $exitval -eq 0 ] ; do cd $folder ; cpio -i || exitval=1 ; done ) 2> /dev/null

	echo "$initrd extracted to $folder"
}

function compressinitrd()
{
	folder=$1
	initrd=$2

	if [ ! -d $folder ]
	then
		#folder doesn't exist
		echo "$folder doesn't exist"
		exit 1
	fi

	#check to see if the initrd uses the full path
        if [ -z "`echo "$initrd" |grep "^/"`" ]
        then
                #reletive not full path
                initrd="$PWD/$initrd"
        fi

	#go into the folder containing the extracted initramfs.
	cd $folder
	

	#use cpio and find to create initrd cpio arcive.
	find . | cpio -o -H newc > $initrd

	#go into the old PWD
	cd $OLDPWD

	#gzip the initrd
	gzip -9 $initrd
	mv $initrd.gz $initrd

	echo "$folder compressed into $initrd"
		
}

#Main Section
# parse argument list
while [ $# -ge 1 ]; do
case $1 in
  -c|--compress) extract=0;;
  -e|--extract) extract=1;;
  -f|--folder) folder=$2; shift;;
  -i|--initrd) initrd=$2; shift;;
  -h|--help) showhelp; exit 0;;
  -v|--version) showversion; exit 0;;
  *)  break;;
esac
shift
done

if [ $extract -eq 0 ]
then
	if [ -z "$folder" ]
	then
		showhelp ; exit 1;
	fi

	if [ -z "$initrd" ]
	then
		initrd="initrd-`date +%Y%m%d%H%M%S`"
	fi
	compressinitrd $folder $initrd
else
	if [ -z "$initrd" ]
        then
                showhelp ; exit 1;
        fi

        if [ -z "$folder" ]
        then
                folder="extracted-`date +%Y%m%d%H%M%S`"
        fi
	extractinitrd $folder $initrd
fi
