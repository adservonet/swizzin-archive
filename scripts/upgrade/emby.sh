#!/bin/bash
# Simple tool to grab the latest release of emby

current=$(curl -L -s -H 'Accept: application/json' https://github.com/MediaBrowser/Emby.Releases/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
cd /tmp
wget -q -O emby.dpkg https://github.com/MediaBrowser/Emby.Releases/releases/download/${current}/emby-server-deb_${current}_amd64.deb  >> "${log}"  2>&1;

apt_update

mkdir -p /var/lib/emby/logs
chmod 777 /var/lib/emby/logs
chown -R emby:emby /opt/emby-server
chown -R emby:emby /var/lib/emby

dpkg --force-confnew -i emby.dpkg  >> "${log}"  2>&1;
rm emby.dpkg
