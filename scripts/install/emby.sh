#!/bin/bash
#
# [Swizzin :: Install Emby package]
#
# Original Author:   QuickBox.IO | JMSolo
# Modified for Swizzin by liara
#
# QuickBox Copyright (C) 2017 QuickBox.io
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.

DISTRO=$(lsb_release -is)
CODENAME=$(lsb_release -cs)
#if [[ -f /install/.tools.lock ]]; then
#  log="/srv/tools/logs/output.log"
#else
#  log="/dev/null"
#fi
username=$(cut -d: -f1 < /root/.master.info)

. /etc/swizzin/sources/functions/waitforapt.sh

if [[ -f /install/.nginx.lock ]]; then
echo "Setting up emby nginx configuration ... " >> "${SEEDIT_LOG}"  2>&1;
  bash /usr/local/bin/swizzin/nginx/emby.sh
  service nginx reload
fi

echo "Installing emby keys and sources ... " >> "${SEEDIT_LOG}"  2>&1;
  if [[ $DISTRO == Debian ]]; then
    version=$(grep VERSION= /etc/os-release| cut -d "\"" -f 2 | cut -d " " -f1).0
    echo "deb http://download.opensuse.org/repositories/home:/emby/$(lsb_release -is)_${version}/ /" > /etc/apt/sources.list.d/emby-server.list
    wget --quiet http://download.opensuse.org/repositories/home:emby/$(lsb_release -is)_${version}/Release.key -O - | apt-key add - >> "${SEEDIT_LOG}"  2>&1;
  elif [[ $DISTRO == Ubuntu ]]; then
    if [[ $CODENAME =~ ("artful"|"bionic") ]]; then
      current=$(curl -L -s -H 'Accept: application/json' https://github.com/MediaBrowser/Emby.Releases/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
      cd /tmp
      wget -q -O emby.dpkg https://github.com/MediaBrowser/Emby.Releases/releases/download/${current}/emby-server-deb_${current}_amd64.deb  >> "${SEEDIT_LOG}"  2>&1;

      waitforapt

      dpkg --force-confnew -i emby.dpkg >>  "${SEEDIT_LOG}"  2>&1
      rm emby.dpkg
    else
      version=$(grep VERSION= /etc/os-release | cut -d "\"" -f 2 | cut -d " " -f1 | cut -d. -f1-2)
      sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/emby/x$(lsb_release -is)_${version}/ /' > /etc/apt/sources.list.d/emby-server.list"
      wget --quiet http://download.opensuse.org/repositories/home:emby/x$(lsb_release -is)_${version}/Release.key -O - | apt-key add - >> "${SEEDIT_LOG}"  2>&1;
    fi
  fi

echo "Updating system & installing emby server ... " >> "${SEEDIT_LOG}"  2>&1;
    waitforapt
    apt-get -y update  >> "${SEEDIT_LOG}"  2>&1;
    waitforapt
    apt-get install -y --allow-unauthenticated -f emby-server >> "${SEEDIT_LOG}"  2>&1;
    echo
    sleep 5

    if [[ -f /etc/emby-server.conf ]]; then
      printf "\n" >> /etc/emby-server.conf
      echo "EMBY_USER="${username}"" >> /etc/emby-server.conf
      echo "EMBY_GROUP="${username}"" >> /etc/emby-server.conf
    fi

    systemctl restart emby-server  >> "${SEEDIT_LOG}"  2>&1;
    touch /install/.emby.lock
    echo

echo "Emby Install Complete!" >> "${SEEDIT_LOG}"  2>&1;

    exit
