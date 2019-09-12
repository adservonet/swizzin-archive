#!/bin/bash
#
# [Quick Box :: Install Rapidleech package]
#
# GITHUB REPOS
# GitHub _ packages  :   https://github.com/QuickBox/quickbox_packages
# LOCAL REPOS
# Local _ packages   :   /etc/QuickBox/packages
# Author             :   QuickBox.IO | JMSolo
# URL                :   https://quickbox.io
#
# QuickBox Copyright (C) 2017 QuickBox.io
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#

if [[ ! -f /install/.nginx.lock ]]; then
  echo "ERROR: Web server not detected. Please install nginx and restart panel install."
  exit 1
fi
MASTER=$(cut -d: -f1 < /root/.master.info)
#if [[ -f /install/.tools.lock ]]; then
#  log="/srv/tools/logs/output.log"
#else
#  log="/dev/null"
#fi
function _installRapidleech1() {
  sudo git clone https://github.com/Th3-822/rapidleech.git  /home/"${MASTER}"/rapidleech >/dev/null 2>&1
}
function _installRapidleech2() {
  touch /install/.rapidleech.lock
  chown "${MASTER}":"${MASTER}" -R /home/"${MASTER}"/rapidleech
  chmod -R 777 /home/"${MASTER}"/rapidleech/configs
  chmod -R 777 /home/"${MASTER}"/rapidleech/files
}
function _installRapidleech3() {
  if [[ -f /install/.nginx.lock ]]; then
    bash /usr/local/bin/swizzin/nginx/rapidleech.sh
    service nginx reload
  fi
}
function _installRapidleech4() {
  service nginx reload
}
function _installRapidleech5() {
    echo "Rapidleech Install Complete!" >>${SEEDIT_LOG} 2>&1;
    service nginx reload
}
function _installRapidleech6() {
    exit
}

echo "Installing rapidleech ... " >>${SEEDIT_LOG} 2>&1;_installRapidleech1
echo "Setting up rapidleech permissions ... " >>${SEEDIT_LOG} 2>&1;_installRapidleech2
echo "Setting up rapidleech nginx configuration ... " >>${SEEDIT_LOG} 2>&1;_installRapidleech3
echo "Reloading nginx ... " >>${SEEDIT_LOG} 2>&1;_installRapidleech4
_installRapidleech5
_installRapidleech6
