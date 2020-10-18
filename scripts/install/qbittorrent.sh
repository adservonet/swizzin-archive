#!/bin/bash
# qBittorrent Installer for swizzin
# Author: liara

user=$(cut -d: -f1 < /root/.master.info)
port=$(cat /home/seedit4me/.qbittorrent_port)

if [[ ! -d /home/seedit4me/torrents/qbittorrent ]]; then
  mkdir /home/seedit4me/torrents/qbittorrent
  chown -R seedit4me:seedit4me /home/seedit4me/torrents/qbittorrent
  chmod -R 775 /home/seedit4me/torrents/qbittorrent
fi

#if [[ -f /tmp/.install.lock ]]; then
#  export log="/root/logs/install.log"
#else
#  export log="/root/logs/swizzin.log"
#fi

# Source the required functions
. /etc/swizzin/sources/functions/qbittorrent
. /etc/swizzin/sources/functions/libtorrent
. /etc/swizzin/sources/functions/utils
. /etc/swizzin/sources/functions/fpm

users=($(_get_user_list))

if [[ -n $1 ]]; then
    user=$1
    qbittorrent_user_config ${user}
    if [[ -f /install/.nginx.lock ]]; then
        bash /etc/swizzin/scripts/nginx/qbittorrent.sh
        systemctl reload nginx
    fi
    exit 0
fi

whiptail_qbittorrent
if ! skip_libtorrent_rasterbar; then
    whiptail_libtorrent_rasterbar
    echo "Building libtorrent-rasterbar"; build_libtorrent_rasterbar
fi

echo "Building qBittorrent"; build_qbittorrent
qbittorrent_service
for user in ${users[@]}; do
    qbittorrent_user_config ${user}
    systemctl enable --now qbittorrent@${user}
done


sleep 10

sed -i -e 's/Connection\\PortRangeMin=.*/Connection\\PortRangeMin='$port' /g' /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf
echo "Bittorrent\DHT=false" >> /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf
echo "Bittorrent\LSD=false" >> /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf
echo "Bittorrent\PeX=false" >> /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf
echo "WebUI\LocalHostAuth=false" >> /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf
echo "Downloads\SavePath=/home/seedit4me/torrents/qbittorrent/" >> /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf

systemctl restart qbittorrent >>  "${log}"  2>&1



if [[ -f /install/.nginx.lock ]]; then
    bash /etc/swizzin/scripts/nginx/qbittorrent.sh
    systemctl reload nginx
fi

touch /install/.qbittorrent.lock