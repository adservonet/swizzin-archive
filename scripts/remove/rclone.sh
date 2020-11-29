#!/bin/bash

MASTER=$(cut -d: -f1 < /root/.master.info)

systemctl stop rclone@${MASTER}.service > /dev/null 2>&1
systemctl disable rclone@${MASTER}.service > /dev/null 2>&1

rm /etc/systemd/system/rclone@.service

rm -f /usr/sbin/rclone
rm -f /usr/bin/rclone
rm -f /install/.rclone.lock
