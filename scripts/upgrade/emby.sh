#!/bin/bash
# Simple tool to grab the latest release of emby

current=$(curl -L -s -H 'Accept: application/json' https://github.com/MediaBrowser/Emby.Releases/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
cd /tmp
wget -q -O emby.dpkg https://github.com/MediaBrowser/Emby.Releases/releases/download/${current}/emby-server-deb_${current}_amd64.deb  >> "${SEEDIT_LOG}"  2>&1;

echo 'Dpkg::Options {\n"--force-confnew";\n};' > /etc/apt/apt.conf.d/71debconf;
export DEBIAN_FRONTEND=noninteractive

#. /etc/swizzin/sources/functions/waitforapt.sh
waitforapt

chmod 777 /var/lib/emby/logs

dpkg --force-confnew -i emby.dpkg  >> "${SEEDIT_LOG}"  2>&1;
rm emby.dpkg
