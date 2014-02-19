#!/bin/bash
#prints System info, can be redirected to file
# will add more items as time goes on
cat <<+
`date`

*****************
* system uname -a   
*****************

`uname -a`

*********
* CPUINFO 
*********

`cat /proc/cpuinfo`

************************
* Current loaded modules 
************************

`lsmod`

**********************
* Current PCI hardware
**********************

`lspci`

******************
* Attached Storage
******************

`blkid`

***********************
* Portage Configuration
***********************

`emerge --info`
+
