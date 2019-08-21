#!/bin/bash
# OpenVPN Headless install for box behind NAT
# Author: Earnest

if [[ -f /tmp/.install.lock ]]; then
  log="/root/logs/install.log"
elif [[ -f /install/.panel.lock ]]; then
  log="/srv/panel/db/output.log"
else
  log="/dev/null"
fi

curl -O https://raw.githubusercontent.com/illnesse/openvpn-install/master/openvpn-install.sh
chmod +x openvpn-install.sh

./openvpn-install.sh

touch /install/.openvpn2.lock
