#!/bin/bash
log="/root/logs/swizzin.log"

systemctl stop sonarr
systemctl disable sonarr
apt_remove --purge sonarr
rm -f /etc/apt/sources.list.d/sonarr.list


rm -rf /var/lib/sonarr
rm -rf /usr/lib/sonarr
rm /etc/nginx/apps/sonarrv3.conf
systemctl reload nginx >> $log 2>&1

rm /install/.sonarrv3.lock