#!/bin/bash
# qBittorrent Installer for swizzin
# Author: liara

port=$(cat /home/seedit4me/.qbittorrent_port)
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
        echo_progress_start "Configuring nginx"
        bash /etc/swizzin/scripts/nginx/qbittorrent.sh
        systemctl reload nginx
        echo_progress_done
    fi
    exit 0
fi

  . /etc/swizzin/sources/functions/apt
  repov=$(get_candidate_version qbittorrent-nox)
  releases=$(git ls-remote -t --refs https://github.com/qbittorrent/qBittorrent.git | awk '{sub("refs/tags/release-", ""); print $2 }' | sort -r)

  latestv41=$(echo "$releases" | grep -m1 -oP '4\.1\.\d?.?\d')
  latestv42=$(echo "$releases" | grep -m1 -oP '4\.2\.\d?.?\d')
  latestv=$(echo "$releases" | grep -m1 -oP '\d.\d?.?\d?.?\d')

  export qbittorrent=${repov}

#whiptail_qbittorrent
check_client_compatibility
if ! skip_libtorrent_rasterbar; then
    whiptail_libtorrent_rasterbar
    echo_progress_start "Building libtorrent-rasterbar"
    build_libtorrent_rasterbar
    echo_progress_done "Build completed"
fi

echo_progress_start "Building qBittorrent"
build_qbittorrent
echo_progress_done

if [[ ! -d /home/seedit4me/torrents/qbittorrent ]]; then
  mkdir -p /home/seedit4me/torrents/qbittorrent
  chown -R seedit4me:seedit4me /home/seedit4me/torrents/qbittorrent
  chmod -R 775 /home/seedit4me/torrents/qbittorrent
fi
qbittorrent_service
for user in ${users[@]}; do
    echo_progress_start "Enabling qbittorrent for $user"
    qbittorrent_user_config ${user}
    systemctl enable -q --now qbittorrent@${user} 2>&1  | tee -a $log
    echo_progress_done "Started qbt for $user"
done


systemctl enable qbittorrent >>  "${log}"  2>&1
systemctl start qbittorrent >>  "${log}"  2>&1

sleep 10

sed -i -e 's/Connection\\PortRangeMin=.*/Connection\\PortRangeMin='$port' /g' /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf
echo "Bittorrent\DHT=false" >> /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf
echo "Bittorrent\LSD=false" >> /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf
echo "Bittorrent\PeX=false" >> /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf
echo "WebUI\LocalHostAuth=false" >> /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf
echo "Downloads\SavePath=/home/seedit4me/torrents/qbittorrent/" >> /home/qbittorrent-nox/.config/qBittorrent/qBittorrent.conf
systemctl restart qbittorrent >>  "${log}"  2>&1

if [[ -f /install/.nginx.lock ]]; then
    echo_progress_start "Configuring nginx"
    bash /etc/swizzin/scripts/nginx/qbittorrent.sh
    systemctl reload nginx >> $log 2>&1
    echo_progress_done
fi

touch /install/.qbittorrent.lock
