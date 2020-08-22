#!/bin/bash

systemctl disable qbittorrent
systemctl stop qbittorrent

waitforapt
apt-get remove -y qbittorrent-nox >>  "${log}"  2>&1

userdel -r qbittorrent-nox

rm -rf /etc/nginx/apps/qbittorrent.conf
rm -rf /var/lib/transmission-daemon
rm -rf /install/.transmission.lock
