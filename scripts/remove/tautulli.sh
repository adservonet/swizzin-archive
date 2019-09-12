#!/bin/bash

#if [[ -f /install/.tools.lock ]]; then
#  log="/srv/tools/logs/output.log"
#else
#  log="/dev/null"
#fi

systemctl stop tautulli
systemctl disable tautulli
rm -rf /opt/tautulli
rm /install/.tautulli.lock
rm -f /etc/nginx/apps/tautulli.conf
sudo deluser --force --remove-home tautulli  >>"${log}" 2>&1
service nginx reload  >>"${log}" 2>&1;
rm /etc/systemd/system/tautulli.service
