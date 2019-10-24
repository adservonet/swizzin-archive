#!/bin/bash
MASTER=$(cut -d: -f1 < /root/.master.info)

. /etc/swizzin/sources/functions/waitforapt.sh

systemctl stop syncthing@${MASTER}

waitforapt
apt-get -q -y purge syncthing
rm /etc/systemd/system/syncthing@.service
rm -f  /etc/nginx/apps/syncthing.conf
rm -rf /home/${MASTER}/.config/syncthing

service nginx reload
rm /install/.syncthing.lock
