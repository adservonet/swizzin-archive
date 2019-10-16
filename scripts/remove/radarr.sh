#!/bin/sh
MASTER=$(cut -d: -f1 < /root/.master.info)
systemctl stop radarr
systemctl disable radarr
rm -rf /home/${MASTER}/.config/Radarr
rm -rf /etc/systemd/system/radarr.service
rm -rf /opt/Radarr
rm -rf /etc/nginx/apps/radarr.conf
rm -rf /install/.radarr.lock
echo "Radarr uninstalled!"
