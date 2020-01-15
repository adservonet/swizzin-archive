#!/bin/bash

apt remove -y thelounge
systemctl disable thelounge >> /dev/null 2>&1
systemctl stop thelounge >> /dev/null 2>&1
deluser thelounge >> /dev/null 2>&1
systemctl daemon-reload
rm -rf /etc/thelounge
rm -f /etc/systemd/system/thelounge.service


systemctl disable lounge >> /dev/null 2>&1
systemctl stop lounge >> /dev/null 2>&1

npm uninstall -g thelounge --save >> /dev/null 2>&1

deluser lounge >> /dev/null 2>&1
rm -rf /home/lounge

rm -f /etc/systemd/system/lounge.service
rm -f /install/.lounge.lock