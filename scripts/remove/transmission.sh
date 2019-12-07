#!/bin/bash

systemctl disable transmission-daemon
systemctl stop transmission-daemon

waitforapt
apt-get remove -y transmission-cli transmission-common transmission-daemon >>  "${SEEDIT_LOG}"  2>&1

rm -rf /etc/nginx/apps/transmission.conf
rm -rf /var/lib/transmission-daemon
rm -rf /install/.transmission.lock
