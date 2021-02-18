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
touch /install/.tools.lock



if type apt_upgrade | grep -q '^function$' 2>/dev/null; then
    apt_upgrade
else
  echo "apt_upgrade not defined";
  waitforapt
  sudo apt update >> "${SEEDIT_LOG}"  2>&1;
  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y >> "${SEEDIT_LOG}"  2>&1;
  sudo apt upgrade -y >> "${SEEDIT_LOG}"  2>&1;
  sudo apt autoremove -y >> "${SEEDIT_LOG}"  2>&1;
fi



crontab -l | grep -v notify.sh | crontab -

#fix broken pip
curl https://bootstrap.pypa.io/2.7/get-pip.py --output get-pip.py; python get-pip.py; rm get-pip.py;

service cron reload

if [[ ! -f /install/.nginx.lock ]]; then
  echo "ERROR: Web server not detected. Please install nginx and restart seedit4me install."
  exit 1
fi

bash /usr/local/bin/swizzin/nginx/tools.sh
