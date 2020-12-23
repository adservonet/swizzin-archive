#!/bin/bash

if [[ -f /install/.tools.lock ]]; then
    export log=/srv/tools/logs/output.log
else
    export log=/root/logs/install.log
fi

apt_remove proftpd proftpd-basic vsftpd >> "${log}" 2>&1

rm /install/.proftpd.lock
rm /install/.vsftpd.lock

apt_update

box install proftpd
