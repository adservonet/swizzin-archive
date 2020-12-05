#!/bin/bash
# Medusa Uninstaller for Swizzin
# Author: liara

user=$(cut -d: -f1 < /root/.master.info)
systemctl disable medusa@${user}
systemctl stop medusa@${user}
sudo rm /etc/nginx/apps/medusa.conf > /dev/null 2>&1
sudo rm /etc/systemd/medusa@.service > /dev/null 2>&1
rm -rf /etc/systemd/system/medusa@.service
rm -rf /home/${user}/.medusa



systemctl disable --now -q medusa

sudo rm /etc/nginx/apps/medusa.conf > /dev/null 2>&1
sudo rm /etc/systemd/medusa.service > /dev/null 2>&1
systemctl reload nginx
rm -rf /opt/medusa
sudo rm /install/.medusa.lock
