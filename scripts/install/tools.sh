#!/bin/bash
# QuickBox dashboard installer for Swizzin
# Author: liara
# Copyright (C) 2017 Swizzin
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#

cd /srv/
if [[ ! -f /srv/tools/logs ]]; then
  mkdir -p /srv/tools/logs
fi
touch /srv/tools/logs/output.log
chmod -R 777 /srv/tools/logs
cp -r /usr/local/bin/swizzin/tools/php/* /srv/tools/
chmod 755 /srv/tools/*.sh
chmod +x /srv/tools/*.sh
chown -R www-data: /srv/tools

apt_install htop net-tools nano

if ! [ -c /dev/net/tun ]; then
  mkdir /dev/net
	mknod /dev/net/tun c 10 200
	ip tuntap add mode tap
fi

touch /install/.tools.lock

crontab -l | grep -v notify.sh | crontab -
service cron reload

if [[ ! -f /install/.nginx.lock ]]; then
  echo "ERROR: Web server not detected. Please install nginx and restart seedit4me install."
  exit 1
fi

bash /usr/local/bin/swizzin/nginx/tools.sh
