#!/bin/bash

systemctl disable transmission-daemon
systemctl stop transmission-daemon

apt_remove transmission-cli transmission-common transmission-daemon >>  "${log}"  2>&1

rm -rf /etc/nginx/apps/transmission.conf
rm -rf /var/lib/transmission-daemon
rm -rf /install/.transmission.lock
