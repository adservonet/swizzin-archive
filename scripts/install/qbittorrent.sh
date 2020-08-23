#!/bin/bash

user=$(cut -d: -f1 < /root/.master.info)
port=$(cat /home/seedit4me/.qbittorrent_port)

#password="$(cut -d: -f2 < /root/.master.info)"
#sha1passwd="$(echo -n "${password}" | sha1sum | cut -b 1-40)"

if [[ ! -d /home/seedit4me/torrents/qbittorrent ]]; then
mkdir /home/seedit4me/torrents/qbittorrent
chown -R seedit4me:seedit4me /home/seedit4me/torrents/qbittorrent
chmod -R 775 /home/seedit4me/torrents/qbittorrent
fi

waitforapt
add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable >>  "${log}"  2>&1
apt-get update >>  "${log}"  2>&1
apt install -y qbittorrent-nox >>  "${log}"  2>&1
adduser --system --group qbittorrent-nox >>  "${log}"  2>&1
usermod -a -G seedit4me qbittorrent-nox >>  "${log}"  2>&1
usermod -a -G qbittorrent-nox seedit4me >>  "${log}"  2>&1

cat > /etc/systemd/system/qbittorrent.service <<SSS
[Unit]
Description=qBittorrent Command Line Client
After=network.target

[Service]
#Do not change to "simple"
Type=forking
User=qbittorrent-nox
Group=qbittorrent-nox
UMask=007
ExecStart=/usr/bin/qbittorrent-nox -d --webui-port=9148
Restart=on-failure

[Install]
WantedBy=multi-user.target
SSS


systemctl enable qbittorrent >>  "${log}"  2>&1
systemctl start qbittorrent >>  "${log}"  2>&1

sleep 10

sed -i -e 's/Connection\\PortRangeMin=.*/Connection\\PortRangeMin='$port' /g' /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf
echo "Bittorrent\DHT=false" >> /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf
echo "Bittorrent\LSD=false" >> /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf
echo "Bittorrent\PeX=false" >> /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf
echo "WebUI\LocalHostAuth=false" >> /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf

#echo "WebUI\Username=seedit4me" >> /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf
#echo "WebUI\Password_PBKDF2="@ByteArray(Nhc0IAtfyl49psuYV+7BoA==:WyEqotj1k7/5x6dgqv9lUKo7Ez69Lqh8CxstajGgi+DwrdwUnZiDEwbK97zhZJB+c6SKlKPVsWq3uxYAS54dNA==)"

systemctl restart qbittorrent >>  "${log}"  2>&1

if [[ -f /install/.nginx.lock ]]; then
  bash /usr/local/bin/swizzin/nginx/qbittorrent.sh
fi

touch /install/.qbittorrent.lock
