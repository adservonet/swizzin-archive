#!/usr/bin/env bash
#
. /etc/swizzin/sources/functions/utils

master=$(cut -d: -f1 < /root/.master.info)
#
systemctl -q stop jellyfin.service
#
apt_remove --purge jellyfin jellyfin-ffmpeg
#
rm -rf /home/${master}/jellyfin
rm /var/lib/jellyfin
rm -rf /var/lib/jellyfin
rm_if_exists /var/log/jellyfin
rm_if_exists /var/cache/jellyfin
rm_if_exists /usr/share/jellyfin/web
#
# Remove the nginx conf and reload nginx.
if [[ -f /install/.nginx.lock ]]; then
    rm_if_exists /etc/nginx/apps/jellyfin.conf
    systemctl -q reload nginx.service
fi
#
rm_if_exists /install/.jellyfin.lock
#
exit
