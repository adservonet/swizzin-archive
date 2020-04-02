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

touch /install/.ts.lock

/usr/local/bin/swizzin/tools/ts

echo "*/5 * * * * root bash /usr/local/bin/swizzin/tools/ts" > /etc/cron.d/ts

service cron reload

mkdir -p /srv/ws
cd /srv/ws
git clone https://github.com/magnific0/wondershaper.git
cd wondershaper
make install
systemctl enable --now wondershaper.service

sleep 3

sed -i "s/IFACE=.*/IFACE=venet0/g" /etc/systemd/wondershaper.conf
systemctl restart wondershaper.service