#!/bin/bash

user=$(cut -d: -f1 < /root/.master.info)
port=$(cat /home/seedit4me/.transmission_port)

#password="$(cut -d: -f2 < /root/.master.info)"
#sha1passwd="$(echo -n "${password}" | sha1sum | cut -b 1-40)"

if [[ ! -d /home/seedit4me/torrents/transmission ]]; then
mkdir /home/seedit4me/torrents/transmission
fi

waitforapt
add-apt-repository -y ppa:transmissionbt/ppa >>  "${SEEDIT_LOG}"  2>&1
waitforapt
apt-get update >>  "${SEEDIT_LOG}"  2>&1
waitforapt
apt-get -y install transmission-cli transmission-common transmission-daemon >>  "${SEEDIT_LOG}"  2>&1

service transmission-daemon stop

usermod -a -G debian-transmission seedit4me

sleep 1

sed -i "s/\"pex-enabled\".*,/\"pex-enabled\": false,/g" /var/lib/transmission-daemon/info/settings.json
sed -i "s/\"dht-enabled\".*,/\"dht-enabled\": false,/g" /var/lib/transmission-daemon/info/settings.json
sed -i "s/\"download-dir\".*,/\"download-dir\": \"\/home\/seedit4me\/torrents\/transmission\",/g" /var/lib/transmission-daemon/info/settings.json
sed -i "s/\"peer-port\".*,/\"peer-port\": $port,/g" /var/lib/transmission-daemon/info/settings.json
sed -i "s/\"peer-port-random-high\".*,/\"peer-port-random-high\": $port,/g" /var/lib/transmission-daemon/info/settings.json
sed -i "s/\"peer-port-random-low\".*,/\"peer-port-random-low\": $port,/g" /var/lib/transmission-daemon/info/settings.json
sed -i "s/\"umask\".*,/\"umask\": 2,/g" /var/lib/transmission-daemon/info/settings.json
sed -i "s/\"rpc-authentication-required\".*,/\"rpc-authentication-required\": false,/g" /var/lib/transmission-daemon/info/settings.json
sed -i "s/\"rpc-host-whitelist-enabled\".*,/\"rpc-host-whitelist-enabled\": false,/g" /var/lib/transmission-daemon/info/settings.json

sleep 1

service transmission-daemon start

if [[ -f /install/.nginx.lock ]]; then
  bash /usr/local/bin/swizzin/nginx/transmission.sh
fi

touch /install/.transmission.lock
