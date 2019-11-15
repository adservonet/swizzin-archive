#!/bin/bash
# Flood uninstaller
# Author: liara

systemctl disable flood
systemctl stop flood
rm -rf /srv/flood
rm -rf /etc/nginx/conf.d/*.flood.conf

rm -rf /etc/nginx/apps/flood.conf
if [[ ! -f /install/.rutorrent.lock ]]; then
  rm -rf /etc/nginx/apps/rindex.conf
  rm -f /etc/nginx/apps/*.scgi.conf
fi
rm -rf /etc/systemd/system/flood.service
systemctl reload nginx
rm -rf /install/.flood.lock
