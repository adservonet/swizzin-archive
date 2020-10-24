#!/bin/bash

systemctl disable qbittorrent
systemctl stop qbittorrent

apt_remove qbittorrent-nox >>  "${log}"  2>&1

userdel -r qbittorrent-nox

rm -rf /etc/nginx/apps/qbittorrent.conf
rm -rf /install/.qbittorrent.lock
