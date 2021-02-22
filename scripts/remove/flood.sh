#!/bin/bash
# Flood uninstaller
# Author: liara

users=($(cut -d: -f1 < /etc/htpasswd))
for u in "${users[@]}"; do
    systemctl disable -q flood@$u
    systemctl stop -q flood@$u
    rm -rf /home/$u/.flood
    rm -rf /etc/nginx/conf.d/$u.flood.conf
done
rm -rf /etc/nginx/apps/flood.conf
if [[ ! -f /install/.rutorrent.lock ]]; then
    rm -rf /etc/nginx/apps/rindex.conf
    rm -f /etc/nginx/apps/${u}.scgi.conf
fi
rm -rf /etc/systemd/system/flood@.service
systemctl reload nginx
rm -rf /install/.flood.lock

if [[ ! -f /install/.rutorrent.lock ]]; then
    rm -rf /etc/nginx/apps/rindex.conf
    for u in "${users[@]}"; do
        rm -f /etc/nginx/apps/${u}.scgi.conf
    done
    /usr/local/bin/swizzin/remove/rtorrent.sh
fi

users=($(cut -d: -f1 < /etc/htpasswd))
