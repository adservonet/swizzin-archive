#!/bin/bash
MASTER=$(cut -d: -f1 < /root/.master.info)
systemctl stop syncthing@${MASTER}
apt_remove --purge syncthing
rm /etc/systemd/system/syncthing@.service
rm -f  /etc/nginx/apps/syncthing.conf
rm -rf /home/${MASTER}/.config/syncthing
systemctl reload nginx
rm /install/.syncthing.lock
