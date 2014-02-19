#!/bin/bash

start() {
IP=192.168.9
ifconfig en0 ${IP}.1 netmask 0xffffff00 
 /opt/local/sbin/dnsmasq -C /boot/dnsmasq.conf

/opt/local/sbin/monkey -c /boot/monkey -D >/dev/null
}

stop() {
 DNS=/opt/local/var/run/dnsmasq.pid
 HTTP=/var/run/monkey.pid
 kill -s kill $(cat ${DNS})
 kill -s kill $(cat ${HTTP})

}

if test $1
then
$1
else
 echo "USAGE: $0 [start|stop] "
fi
