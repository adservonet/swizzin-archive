#!/bin/bash
#
# [ swizzin :: Install plexmediaserver package]
# Originally authored by: JMSolo for QuickBox
# Modifications to QuickBox package by: liara / PastaGringo
# Maintained and updated for swizzin by: liara
#
# QuickBox Copyright (C) 2017 QuickBox.io
# Modifications for/by swizzin copyright (C) 2019 swizzin.ltd
#
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#

master=$(cut -d: -f1 < /root/.master.info)

#versions=https://plex.tv/api/downloads/1.json
#wgetresults="$(wget "${versions}" -O -)"
#releases=$(grep -ioe '"label"[^}]*' <<<"${wgetresults}" | grep -i "\"distro\":\"ubuntu\"" | grep -m1 -i "\"build\":\"linux-ubuntu-x86_64\"")
#latest=$(echo ${releases} | grep -m1 -ioe 'https://[^\"]*')

echo_progress_start "Installing plex keys and sources ... "
apt_install apt-transport-https
wget -q https://downloads.plex.tv/plex-keys/PlexSign.key -O - | sudo apt-key add -
echo "deb https://downloads.plex.tv/repo/deb public main" > /etc/apt/sources.list.d/plexmediaserver.list
echo

apt_update
echo_progress_done "Sources and keys retrieved and installed"
apt-get install -o Dpkg::Options::="--force-confold" -y -f plexmediaserver --allow-unauthenticated >> "${log}" 2>&1
#DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -q -y -o -f "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install plexmediaserver >/dev/null 2>&1
echo

if [[ ! -d /var/lib/plexmediaserver ]]; then
    mkdir -p /var/lib/plexmediaserver
fi
perm=$(stat -c '%U' /var/lib/plexmediaserver/)
if [[ ! $perm == plex ]]; then
    chown -R plex:plex /var/lib/plexmediaserver
fi
usermod -a -G ${master} plex
service plexmediaserver restart > /dev/null 2>&1
touch /install/.plex.lock

echo_success "Plex installed"
