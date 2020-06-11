#!/bin/bash
#
# [Swizzin :: Couchpotato Installer]
#
# Originally written for QuickBox.io by liara
# Modified for Swizzin by liara
#
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
function _install() {
echo "Installing CouchPotato ... " >> "${log}"  2>&1;
warning=$(echo -e "[ \e[1;91mWARNING\e[0m ]")
waitforapt
apt-get -y --force-yes update >/dev/null 2>&1
waitforapt
apt-get -y --force-yes install git-core python >/dev/null 2>&1;
echo >> "${log}"  2>&1;
echo >> "${log}"  2>&1;
echo "Cloning CouchPotato git ... " >> "${log}"  2>&1;
git clone -q https://github.com/CouchPotato/CouchPotatoServer.git /home/${MASTER}/.couchpotato || { echo "GIT failed"; exit 1; }
chown ${MASTER}:${MASTER} -R /home/${MASTER}/.couchpotato
}

function _services(){
echo >> "${log}"  2>&1;
echo >> "${log}"  2>&1;
echo "Installing and enabling service ... " >> "${log}"  2>&1;

cat > /etc/systemd/system/couchpotato@.service <<CPS
[Unit]
Description=CouchPotato
After=syslog.target network.target

[Service]
Type=forking
KillMode=control-group
User=%i
Group=%i
ExecStart=/usr/bin/python /home/%i/.couchpotato/CouchPotato.py --daemon
GuessMainPID=no
ExecStop=-/bin/kill -HUP


[Install]
WantedBy=multi-user.target
CPS
systemctl enable couchpotato@${MASTER} >> "${log}"  2>&1;
systemctl start couchpotato@${MASTER} >> "${log}"  2>&1;

if [[ -f /install/.nginx.lock ]]; then
  bash /usr/local/bin/swizzin/nginx/couchpotato.sh
  service nginx reload
fi

touch /install/.couchpotato.lock
echo >> "${log}"  2>&1;
echo >> "${log}"  2>&1;
echo "couchpotato installation complete." >> "${log}"  2>&1;
}

#if [[ -f /tmp/.install.lock ]]; then
#  OUTTO="/root/logs/install.log"
#else
#  OUTTO="/root/logs/swizzin.log"
#fi
MASTER=$(cut -d: -f1 < /root/.master.info)
_install
_services
