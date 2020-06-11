#!/bin/bash
#
# [Quick Box :: Install rclone]
#
# GITHUB REPOS
# GitHub _ packages  :   https://github.com/QuickBox/quickbox_packages
# LOCAL REPOS
# Local _ packages   :   /etc/QuickBox/packages
# Author             :   DedSec | d2dyno
# URL                :   https://quickbox.io
#
# QuickBox Copyright (C) 2017 QuickBox.io
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.

#if [[ -f /tmp/.install.lock ]]; then
#  OUTTO="/root/logs/install.log"
#else
#  OUTTO="/root/logs/swizzin.log"
#fi
MASTER=$(cut -d: -f1 < /root/.master.info)

waitforapt

apt-get update -y -q

waitforapt

apt-get install -y fuse >>  "${log}"  2>&1

echo "Downloading and installing rclone ..." >> "${log}"  2>&1;

# One-liner to check arch/os type, as well as download latest rclone for relevant system.
curl https://rclone.org/install.sh | sudo bash -s beta

# Make sure rclone downloads and installs without error before proceeding
if [ $? -eq 0 ]; then
    echo "Adding rclone mount service..." >> "${log}"  2>&1;

user=$(cut -d: -f1 < /root/.master.info)
passwd=$(cut -d: -f2 < /root/.master.info)


cat >/etc/systemd/system/rclone@.service<<EOF
[Unit]
Description=rclonemount
After=network.target

[Service]
Type=simple
User=%i
Group=%i
ExecStart=/usr/sbin/rclone  rcd --rc-web-gui --rc-user=${user} --rc-pass=${passwd} --rc-addr 127.0.0.1:5572 --rc-baseurl /rclone
ExecStop=/bin/fusermount -u /home/%i/cloud
Restart=on-failure
RestartSec=30
StartLimitInterval=60s
StartLimitBurst=3

[Install]
WantedBy=multi-user.target

EOF

touch /install/.rclone.lock
echo "rclone installation complete!" >> "${log}"  2>&1;
else
    echo "Issue occured during rclone installation." >> "${log}"  2>&1;
fi

  if [[ -f /install/.nginx.lock ]]; then
    bash /usr/local/bin/swizzin/nginx/rclone.sh
    service nginx reload
  fi
  echo "Enabling and starting rclone services ... " >> "${log}"  2>&1;
  systemctl enable rclone@${MASTER}.service >/dev/null >> "${log}"  2>&1;
  systemctl start rclone@${MASTER}.service >/dev/null >> "${log}"  2>&1;
  service nginx reload
