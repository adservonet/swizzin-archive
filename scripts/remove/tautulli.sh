#!/bin/bash
systemctl stop tautulli
systemctl disable tautulli
rm -rf /opt/tautulli
rm /install/.tautulli.lock
rm -f /etc/nginx/apps/tautulli.conf
deluser --force --remove-home tautulli
service nginx reload
rm /etc/systemd/system/tautulli.service
