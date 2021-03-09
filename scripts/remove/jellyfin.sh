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
rm -rf /var/lib/jellyfin
rm -rf /var/log/jellyfin
rm -rf /var/cache/jellyfin
rm -rf /usr/share/jellyfin/web
#
# Remove the nginx conf and reload nginx.
if [[ -f /install/.nginx.lock ]]; then
    rm -rf /etc/nginx/apps/jellyfin.conf
    systemctl -q reload nginx.service
fi
#
rm -rf /install/.jellyfin.lock
#
exit
