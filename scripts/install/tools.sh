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

if [[ -f /lib/systemd/system/php7.3-fpm.service ]]; then
  echo "php setup ok"
else
  waitforapt
  apt -y -q  remove php7.0 php7.0-fpm php7.0-cli php7.0-common
  LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
  waitforapt
  apt -y -q  update
  waitforapt
  apt -y -q  install nano php7.3 php7.3-fpm php7.3-cli php7.3-common php7.3-zip php7.3-sqlite3 php7.3-curl php7.3-simplexml
  update-alternatives --set php /usr/bin/php7.3
  sed -i "s/php7.0-fpm/php7.3-fpm/g" /etc/nginx/apps/*.conf
fi

#remove this
croncmd="box update && apt-get -y -q update && apt-get -y -q upgrade > /srv/tools/logs/apt_upgrade.log 2>&1"
cronjob=""
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -

#remove this too
croncmd="/usr/local/bin/swizzin/box update"
cronjob=""
#cronjob="0 0 * * * $croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -


if [[ ! -f /install/.nginx.lock ]]; then
  echo "ERROR: Web server not detected. Please install nginx and restart seedit4me install."
  exit 1
fi

bash /usr/local/bin/swizzin/nginx/tools.sh
