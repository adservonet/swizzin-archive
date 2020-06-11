#!/bin/bash

if [[ -f /install/.tools.lock ]]; then
  export log=/srv/tools/logs/output.log
else
  export log=/root/logs/install.log
fi

apt-get -y remove proftpd proftpd-basic vsftpd >> "${log}" 2>&1

rm /install/.proftpd.lock
rm /install/.vsftpd.lock

waitforapt

box install proftpd