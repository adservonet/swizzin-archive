#!/bin/bash
# ruTorrent installation wrapper

if [[ ! -f /install/.nginx.lock ]]; then
  echo "nginx does not appear to be installed, ruTorrent requires a webserver to function. Please install nginx first before installing this package."
  exit 1
fi

if [[ ! -f /install/.rtorrent.lock ]]; then
  echo "ruTorrent is a GUI for rTorrent, which doesn't appear to be installed. Installing now.."  >> "${log}" 2>&1
  bash /usr/local/bin/swizzin/install/rtorrent.sh  >> "${log}" 2>&1
fi

bash /usr/local/bin/swizzin/nginx/rutorrent.sh  >> "${log}" 2>&1
systemctl force-reload nginx
touch /install/.rutorrent.lock
