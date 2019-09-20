#!/bin/bash

. /etc/swizzin/sources/functions/waitforapt.sh
waitforapt
apt remove proftpd proftpd-basic vsftpd;

rm /install/.proftpd.lock
rm /install/.vsftpd.lock

. /etc/swizzin/sources/functions/waitforapt.sh
waitforapt

box install proftpd;