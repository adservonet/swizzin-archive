#!/bin/bash
systemctl disable --now -q mountrar2fs
rm /etc/systemd/system/mountrar2fs.service
systemctl daemon-reload -q
rm -rf /home/seedit4me/rar2fsmount

rm /install/.rar2fs.lock
