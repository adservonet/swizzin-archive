#!/bin/bash
#
# [Quick Box :: Install pyLoad package]
#
# QUICKLAB REPOS
# QuickLab _ packages  :   https://github.com/QuickBox/QB/packages
# LOCAL REPOS
# Local _ packages   :   /etc/QuickBox/packages
# Author             :   QuickBox.IO | JMSolo
# URL                :   https://quickbox.io
#
# Modifications for Swizzin by liara
#
# QuickBox Copyright (C) 2017 QuickBox.io
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#

function _installpyLoad1() {
  echo "Installing any additional dependencies needed for pyLoad ... "
  apt-get install -y sqlite3 tesseract-ocr gocr rhino pyqt4-dev-tools python-imaging python-dev libcurl4-openssl-dev >/dev/null 2>&1
  apt-get -y autoremove >/dev/null 2>&1
}

function _installpyLoad2() {
  echo "Setting up python package management system in /home/${MASTER}/.pip ... "
  mkdir /home/${MASTER}/.pip && cd /home/${MASTER}/.pip
  wget https://bootstrap.pypa.io/get-pip.py >/dev/null 2>&1
  python get-pip.py >/dev/null 2>&1
}

function _installpyLoad3() {
  echo "Installing pyLoad packages ... "
  pip install wheel --upgrade >/dev/null 2>&1
  pip install setuptools --upgrade >/dev/null 2>&1
  pip install ply --upgrade >/dev/null 2>&1
  pip install cryptography --upgrade >/dev/null 2>&1
  pip install distribute >/dev/null 2>&1
  #pip install pyOpenSSL >/dev/null 2>&1
  pip install cffi --upgrade >/dev/null 2>&1
  pip install pycurl >/dev/null 2>&1
  pip install django >/dev/null 2>&1
  pip install pyimaging >/dev/null 2>&1
  pip install web2py >/dev/null 2>&1
  pip install beaker >/dev/null 2>&1
  pip install thrift >/dev/null 2>&1
  pip install pycrypto >/dev/null 2>&1
  pip install feedparser >/dev/null 2>&1
  pip install beautifulsoup >/dev/null 2>&1
  pip install tesseract >/dev/null 2>&1
}

function _installpyLoad4() {
  echo "Grabbing latest stable pyLoad repository ... "
  mkdir /home/${MASTER}/.pyload
  cd /home/${MASTER} && git clone --branch "stable" https://github.com/pyload/pyload.git .pyload >/dev/null 2>&1
  printf "/home/${MASTER}/.pyload" > /home/${MASTER}/.pyload/module/config/configdir
  mkdir -p /var/run/pyload
}

function _installpyLoad5() {
  echo "Building pyLoad systemd template ... "
cat >/etc/systemd/system/pyload@.service<<PYSV
[Unit]
Description=pyLoad
After=network.target

[Service]
Type=forking
KillMode=process
User=%I
ExecStart=/usr/bin/python /home/${MASTER}/.pyload/pyLoadCore.py --config=/home/${MASTER}/.pyload --pidfile=/home/${MASTER}/.pyload.pid --daemon
PIDFile=/home/${MASTER}/.pyload.pid
ExecStop=-/bin/kill -HUP
WorkingDirectory=/home/%I/

[Install]
WantedBy=multi-user.target

PYSV
}

function _installpyLoad6() {
  echo "Adjusting permissions ... "
  chown -R ${MASTER}.${MASTER} /home/${MASTER}/.pip
  chown -R ${MASTER}.${MASTER} /home/${MASTER}/.pyload
  chown -R ${MASTER}.${MASTER} /var/run/pyload
}

function _installpyLoad7() {
  touch /install/.pyload.lock
  systemctl daemon-reload >/dev/null 2>&1
  echo "#### pyLoad setup will now run ####"
#  if [[ -f /install/.nginx.lock ]]; then
#    echo "#### To ensure proper proxy configuration:"
#    echo "#### please leave remote access enabled ####"
#    echo "#### and do not alter the default port (8000) ####"
#  fi
  sleep 5

cat >/home/${MASTER}/.pyload/pyload.conf<<PYCFG
version: 1

download - "Download":
        int chunks : "Max connections for one download" = 3
        str interface : "Download interface to bind (ip or Name)" = None
        bool ipv6 : "Allow IPv6" = False
        bool limit_speed : "Limit Download Speed" = False
        int max_downloads : "Max Parallel Downloads" = 3
        int max_speed : "Max Download Speed in kb/s" = -1
        bool skip_existing : "Skip already existing files" = False

downloadTime - "Download Time":
        time end : "End" = 0:00
        time start : "Start" = 0:00

general - "General":
        bool checksum : "Use Checksum" = False
        bool debug_mode : "Debug Mode" = False
        folder download_folder : "Download Folder" = Downloads
        bool folder_per_package : "Create folder for each package" = True
        en;de;fr;it;es;nl;sv;ru;pl;cs;sr;pt_BR language : "Language" = en
        int min_free_space : "Min Free Space (MB)" = 200
        int renice : "CPU Priority" = 0

log - "Log":
        bool file_log : "File Log" = True
        int log_count : "Count" = 5
        folder log_folder : "Folder" = Logs
        bool log_rotate : "Log Rotate" = True
        int log_size : "Size in kb" = 100

permission - "Permissions":
        bool change_dl : "Change Group and User of Downloads" = False
        bool change_file : "Change file mode of downloads" = False
        bool change_group : "Change group of running process" = False
        bool change_user : "Change user of running process" = False
        str file : "Filemode for Downloads" = 0644
        str folder : "Folder Permission mode" = 0755
        str group : "Groupname" = users
        str user : "Username" = user

proxy - "Proxy":
        str address : "Address" = "localhost"
        password password : "Password" = None
        int port : "Port" = 7070
        bool proxy : "Use Proxy" = False
        http;socks4;socks5 type : "Protocol" = http
        str username : "Username" = None

reconnect - "Reconnect":
        bool activated : "Use Reconnect" = False
        time endTime : "End" = 0:00
        str method : "Method" = None
        time startTime : "Start" = 0:00

remote - "Remote":
        bool activated : "Activated" = True
        ip listenaddr : "Adress" = 0.0.0.0
        bool nolocalauth : "No authentication on local connections" = True
        int port : "Port" = 7227

ssl - "SSL":
        bool activated : "Activated" = False
        file cert : "SSL Certificate" = ssl.crt
        file key : "SSL Key" = ssl.key

webinterface - "Webinterface":
        bool activated : "Activated" = True
        ip host : "IP" = 127.0.0.1
        bool https : "Use HTTPS" = False
        int port : "Port" = 8712
        str prefix : "Path Prefix" = /pyload/pyload
        builtin;threaded;fastcgi;lightweight server : "Server" = builtin
        pyplex;classic;modern template : "Template" = modern
PYCFG


sleep 3

  #/usr/bin/python /home/${MASTER}/.pyload/pyLoadCore.py --setup --config=/home/${MASTER}/.pyload
  chown -R ${MASTER}: /home/${MASTER}/.pyload
  if [[ -f /install/.nginx.lock ]]; then
    bash /usr/local/bin/swizzin/nginx/pyload.sh
    service nginx reload
  fi
  echo "Enabling and starting pyLoad services ... "
  systemctl enable pyload@${MASTER}.service >/dev/null 2>&1
  systemctl start pyload@${MASTER}.service >/dev/null 2>&1
  service nginx reload
}

function _installpyLoad8() {
  echo "pyLoad Install Complete!"
  echo "pyLoad Install Complete!" >>"${OUTTO}" 2>&1;
  sleep 2
  echo >>"${OUTTO}" 2>&1;
  echo >>"${OUTTO}" 2>&1;
  echo "Close this dialog box to refresh your browser" >>"${OUTTO}" 2>&1;
}

function _installpyLoad9() {
  exit
}


ip=$(curl -s http://whatismyip.akamai.com)
MASTER=$(cut -d: -f1 < /root/.master.info)
if [[ -f /tmp/.install.lock ]]; then
  OUTTO="/root/logs/install.log"
elif [[ -f /install/.panel.lock ]]; then
  OUTTO="/srv/panel/db/output.log"
else
  OUTTO="/dev/null"
fi


echo "Installing any additional dependencies needed for pyLoad ... " >>"${OUTTO}" 2>&1;_installpyLoad1
echo "Setting up python package management system in /home/${MASTER}/.pip ... " >>"${OUTTO}" 2>&1;_installpyLoad2
echo "Installing pyLoad packages ... " >>"${OUTTO}" 2>&1;_installpyLoad3
echo "Grabbing latest stable pyLoad repository ... " >>"${OUTTO}" 2>&1;_installpyLoad4
echo "Building pyLoad systemd template ... " >>"${OUTTO}" 2>&1;_installpyLoad5
echo "Adjusting permissions ... " >>"${OUTTO}" 2>&1;_installpyLoad6
echo "Enabling and starting pyLoad services ... " >>"${OUTTO}" 2>&1;_installpyLoad7

sleep 3
cd /home/${MASTER}/.pyload
user=$(cut -d: -f1 < /root/.master.info)
passwd=$(cut -d: -f2 < /root/.master.info)

cat >/home/${MASTER}/.pyload/adduser.py<<PYAU
from hashlib import sha1
import random

strpass = "${passwd}"

salt = reduce(lambda x, y: x + y, [str(random.randint(0, 9)) for i in range(0, 5)])
h = sha1(salt + strpass)
password = salt + h.hexdigest()

print(password)
PYAU

sleep 3

saltedpasswd=$(python /home/${MASTER}/.pyload/adduser.py)

sleep 1
echo "INSERT INTO users (name, password) VALUES ('${user}', '${saltedpasswd}');" > sqlquery
sleep 1
sqlite3 files.db ".read sqlquery"



_installpyLoad8
_installpyLoad9
