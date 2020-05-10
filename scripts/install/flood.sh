#!/bin/bash
# Flood for rtorrent installation script for swizzin
# Author: liara

if [[ ! -f /install/.rtorrent.lock ]]; then
  echo "Flood is a GUI for rTorrent, which doesn't appear to be installed. Exiting."
  exit 1
fi

#if [[ -f /tmp/.install.lock ]]; then
#  log="/root/logs/install.log"
#else
#  log="/root/logs/swizzin.log"
#fi

. /etc/swizzin/sources/functions/npm
npm_install

if [[ ! $(which node-gyp) ]]; then
  npm install -g node-gyp >> $log 2>&1
fi

cat > /etc/systemd/system/flood@.service <<SYSDF
[Unit]
Description=Flood rTorrent Web UI
After=network.target

[Service]
User=%i
Group=%i
WorkingDirectory=/srv/flood
ExecStart=/usr/bin/npm start

[Install]
WantedBy=multi-user.target
SYSDF

user=$(cut -d: -f1 < /root/.master.info)
salt=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 32 | head -n 1)
cd /srv
git clone https://github.com/jfurrow/flood.git flood >>  "${SEEDIT_LOG}"  2>&1
cd flood
cp -a config.template.js config.js
sed -i "s/baseURI: '\/',/baseURI: '\/flood',\n  socket: true,\n  socketPath: '\/var\/run\/${user}\/.rtorrent.sock',/g" config.js
sed -i "s/floodServerPort: 3000/floodServerPort: 3001/g" config.js
#sed -i "s/socket: false/socket: true/g" config.js
#sed -i "s/socketPath.*/socketPath: '\/var\/run\/${user}\/.rtorrent.sock'/g" config.js
sed -i "s/secret: 'flood'/secret: '$salt'/g" config.js
echo "Building Flood for $u. This might take some time..." >>  "${SEEDIT_LOG}"  2>&1
cd /srv/flood
npm install >>  "${SEEDIT_LOG}"  2>&1
npm update >>  "${SEEDIT_LOG}"  2>&1
npm install -g node-gyp >>  "${SEEDIT_LOG}"  2>&1
npm run build >>  "${SEEDIT_LOG}"  2>&1

chown -R ${user}:${user} /srv/flood

systemctl enable flood > /dev/null 2>&1

if [[ -f /install/.nginx.lock ]]; then
  bash /usr/local/bin/swizzin/nginx/flood.sh
  systemctl start flood
fi

touch /install/.flood.lock
