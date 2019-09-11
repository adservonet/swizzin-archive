#!/bin/bash

if [[ -f /install/.tools.lock ]]; then
  OUTTO="/srv/tools/logs/output.log"
else
  OUTTO="/dev/null"
fi

systemctl stop tautulli
systemctl disable tautulli
rm -rf /opt/tautulli
rm /install/.tautulli.lock
rm -f /etc/nginx/apps/tautulli.conf
sudo deluser --force --remove-home tautulli  >>"${OUTTO}" 2>&1
service nginx reload  >>"${OUTTO}" 2>&1
rm /etc/systemd/system/tautulli.service
