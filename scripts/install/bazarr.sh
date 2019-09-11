#!/bin/bash
# Bazarr installation
# Author: liara
# Copyright (C) 2019 Swizzin
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.

user=$(cut -d: -f1 < /root/.master.info )



if [[ -f /install/.tools.lock ]]; then
  OUTTO="/srv/tools/log/output.log"
else
  OUTTO="/dev/null"
fi



apt-get -y -q install python-pip >>"${OUTTO}" 2>&1
cd /home/${user}
echo "Cloning into 'bazarr'"
git clone https://github.com/morpheus65535/bazarr.git >>"${OUTTO}" 2>&1
chown -R ${user}: bazarr
cd bazarr
echo "Checking python depends"
sudo -u ${user} bash -c "pip install --user -r requirements.txt" >>"${OUTTO}" 2>&1

cat > /etc/systemd/system/bazarr.service <<BAZ
[Unit]
Description=Bazarr for ${user}
After=syslog.target network.target

[Service]
WorkingDirectory=/home/${user}/bazarr
User=${user}
Group=${user}
UMask=0002
Restart=on-failure
RestartSec=5
Type=simple
ExecStart=/usr/bin/python /home/${user}/bazarr/bazarr.py
KillSignal=SIGINT
TimeoutStopSec=20
SyslogIdentifier=bazarr.${user}

[Install]
WantedBy=multi-user.target
BAZ

chown -R ${user}: /home/${user}/bazarr

systemctl enable --now bazarr

if [[ -f /install/.nginx.lock ]]; then
    sleep 10
    bash /usr/local/bin/swizzin/nginx/bazarr.sh
    service nginx reload
fi

touch /install/.bazarr.lock
