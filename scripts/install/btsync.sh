#!/bin/bash
#
# [Quick Box :: Install Resilio Sync (BTSync) package]
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
MASTER=$(cut -d: -f1 < /root/.master.info)
BTSYNCIP=$(ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p')
<<<<<<< HEAD
port=$(cat /home/seedit4me/.btsync_port)
port2=$(cat /home/seedit4me/.btsync2_port)

username="$(cut -d: -f1 < /root/.master.info)"
password="$(cut -d: -f2 < /root/.master.info)"

#if [[ -f /tmp/.install.lock ]]; then
#  OUTTO="/root/logs/install.log"
#else
#  OUTTO="/root/logs/swizzin.log"
#fi

function _installBTSync1() {
  #sudo sh -c 'echo "deb http://linux-packages.getsync.com/btsync/deb btsync non-free" > /etc/apt/sources.list.d/btsync.list'
  #wget -qO - http://linux-packages.getsync.com/btsync/key.asc | sudo apt-key add - >/dev/null 2>&1
  sudo sh -c 'echo "deb http://linux-packages.resilio.com/resilio-sync/deb resilio-sync non-free" > /etc/apt/sources.list.d/btsync.list'
  wget -qO - https://linux-packages.resilio.com/resilio-sync/key.asc | sudo apt-key add - >> "${log}"  2>&1;
}
function _installBTSync2() {
  sudo apt-get update >/dev/null 2>&1
}
function _installBTSync3() {
  #sudo apt-get -y -q install btsync >/dev/null 2>&1
  cd && mkdir -p /home/"${MASTER}"/.config/resilio-sync/storage/
  sudo apt-get install resilio-sync >/dev/null 2>&1
}
function _installBTSync4() {
  cd && mkdir /home/"${MASTER}"/sync_folder
  chown ${MASTER}: /home/${MASTER}/sync_folder
  chmod 2775 /home/${MASTER}/sync_folder
  chown ${MASTER}: -R /home/${MASTER}/.config/resilio-sync
}
function _installBTSync5() {
  cat > /etc/resilio-sync/config.json <<RSCONF
{
    "listening_port" : $port2,
    "storage_path" : "/home/${MASTER}/.config/resilio-sync/",
    "pid_file" : "/var/run/resilio-sync/sync.pid",
    "agree_to_EULA": "yes",

    "webui" :
    {
        "listen" : "0.0.0.0:$port",
        "login" : "${username}",
        "password" : "${password}"
    }
}
RSCONF
  cp -a /lib/systemd/system/resilio-sync.service /etc/systemd/system/
  sed -i "s/=rslsync/=${MASTER}/g" /etc/systemd/system/resilio-sync.service
  sed -i "s/rslsync:rslsync/${MASTER}:${MASTER}/g" /etc/systemd/system/resilio-sync.service
  systemctl daemon-reload
  sed -i "s/BTSGUIP/$BTSYNCIP/g" /etc/resilio-sync/config.json

}
function _installBTSync6() {
  touch /install/.btsync.lock
  systemctl enable resilio-sync >> "${log}"  2>&1;
  systemctl start resilio-sync >> "${log}"  2>&1;
  systemctl restart resilio-sync >> "${log}"  2>&1;
}
function _installBTSync7() {
  echo "BTSync Install Complete!" >> "${log}"  2>&1;
}
function _installBTSync8() {
  exit
}

echo "Installing btsync keys and sources ... " >> "${log}"  2>&1;_installBTSync1
echo "Updating system ... " >> "${log}"  2>&1;_installBTSync2
echo "Installing btsync ... " >> "${log}"  2>&1;_installBTSync3
echo "Setting up btsync permissions ... " >> "${log}"  2>&1;_installBTSync4
echo "Setting up btsync configurations ... " >> "${log}"  2>&1;_installBTSync5
echo "Starting btsync ... " >> "${log}"  2>&1;_installBTSync6
_installBTSync7
_installBTSync8
