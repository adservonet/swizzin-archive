#!/bin/bash
#
# [Swizzin :: Install Deluge package]
# Author: liara
#
# Copyright (C) 2017 Swizzin
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
#################################################################################

function _dconf {
  for u in "${users[@]}"; do
    echo_progress_start "Configuring Deluge for $u"
    if [[ ${u} == ${master} ]]; then
      pass=$(cut -d: -f2 < /root/.master.info)
    else
      pass=$(cut -d: -f2 < /root/${u}.info)
    fi
  n=$RANDOM
  DPORT=$((n%59000+10024))
  DWSALT=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32; echo "")
  localpass=$(head /dev/urandom | tr -dc a-z0-9 | head -c 40; echo "")
  if $(command -v python2.7 > /dev/null 2>&1); then
    pythonversion=python2.7
  elif $(command -v python3 > /dev/null 2>&1); then
    pythonversion=python3
  fi
  DWP=$(${pythonversion} ${local_packages}/deluge.Userpass.py ${pass} ${DWSALT})
  DUDID=$(${pythonversion} ${local_packages}/deluge.addHost.py)
  port=$(cat /home/seedit4me/.deluge_port)
  # -- Secondary awk command -- #
  #DPORT=$(awk -v min=59000 -v max=69024 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')
  #DWPORT=$(shuf -i 10001-11000 -n 1)
  ltconfig
  chmod 755 /home/${u}/.config
  chmod 755 /home/${u}/.config/deluge
  cat > /home/${u}/.config/deluge/core.conf <<DC
  {
    "file": 1,
    "format": 1
  }{
    "info_sent": 0.0,
    "lsd": false,
    "max_download_speed": -1.0,
    "send_info": false,
    "natpmp": false,
    "move_completed_path": "/home/${u}/Downloads",
    "peer_tos": "0x08",
    "enc_in_policy": 1,
    "queue_new_to_top": false,
    "ignore_limits_on_local_network": true,
    "rate_limit_ip_overhead": true,
    "daemon_port": ${DPORT},
    "torrentfiles_location": "/home/${u}/dwatch",
    "max_active_limit": -1,
    "geoip_db_location": "/usr/share/GeoIP/GeoIP.dat",
    "upnp": false,
    "utpex": false,
    "max_active_downloading": 3,
    "max_active_seeding": -1,
    "allow_remote": true,
    "outgoing_ports": [
      0,
      0
    ],
    "enabled_plugins": [
      "ltConfig",
      "Blocklist"
    ],
    "max_half_open_connections": 50,
    "download_location": "/home/${u}/torrents/deluge",
    "compact_allocation": true,
    "max_upload_speed": -1.0,
    "plugins_location": "/home/${u}/.config/deluge/plugins",
    "max_connections_global": -1,
    "enc_prefer_rc4": true,
    "cache_expiry": 60,
    "dht": false,
    "stop_seed_at_ratio": false,
    "stop_seed_ratio": 2.0,
    "max_download_speed_per_torrent": -1,
    "prioritize_first_last_pieces": true,
    "max_upload_speed_per_torrent": -1,
    "auto_managed": true,
    "enc_level": 2,
    "copy_torrent_file": false,
    "max_connections_per_second": 50,
    "port": [
      $port,
      $port
    ],
    "listen_ports": [
      $port,
      $port
    ],
    "max_connections_per_torrent": -1,
    "del_copy_torrent_file": false,
    "move_completed": false,
    "autoadd_enable": false,
    "proxies": {
      "peer": {
        "username": "",
        "password": "",
        "hostname": "",
        "type": 0,
        "port": 8080
      },
      "web_seed": {
        "username": "",
        "password": "",
        "hostname": "",
        "type": 0,
        "port": 8080
      },
      "tracker": {
        "username": "",
        "password": "",
        "hostname": "",
        "type": 0,
        "port": 8080
      },
      "dht": {
        "username": "",
        "password": "",
        "hostname": "",
        "type": 0,
        "port": 8080
      }
    },
    "dont_count_slow_torrents": true,
    "add_paused": false,
    "random_outgoing_ports": true,
    "max_upload_slots_per_torrent": -1,
    "new_release_check": false,
    "enc_out_policy": 1,
    "seed_time_ratio_limit": 7.0,
    "remove_seed_at_ratio": false,
    "autoadd_location": "/home/${u}/dwatch/",
    "max_upload_slots_global": -1,
    "seed_time_limit": 180,
    "cache_size": 512,
    "share_ratio_limit": 2.0,
    "random_port": false,
    "listen_interface": "${ip}"
  }
DC
cat > /home/${u}/.config/deluge/web.conf <<DWC
{
  "file": 1,
  "format": 1
}{
  "port": 10033,
  "enabled_plugins": [],
  "pwd_sha1": "${DWP}",
  "theme": "gray",
  "show_sidebar": true,
  "sidebar_show_zero": false,
  "pkey": "ssl/daemon.pkey",
  "https": true,
  "sessions": {},
  "base": "/",
  "interface": "0.0.0.0",
  "pwd_salt": "${DWSALT}",
  "show_session_speed": false,
  "first_login": false,
  "cert": "ssl/daemon.cert",
  "session_timeout": 3600,
  "default_daemon": "${DUDID}",
  "sidebar_multiple_filters": true
}
DWC
cat > /home/${u}/.config/deluge/blocklist.conf <<DBL
{
  "file": 1,
  "format": 1
}{
  "check_after_days": 1,
  "timeout": 180,
  "url": "https://my.seedit4.me/storage/deluge_blocklist.dat",
  "try_times": 3,
  "list_size": 22949,
  "last_update": 1566142180.170619,
  "list_type": "PeerGuardian",
  "list_compression": "",
  "load_on_start": true
}
DBL

dvermajor=$(deluged -v | grep deluged | grep -oP '\d+\.\d+\.\d+' | cut -d. -f1)

case $dvermajor in
  1)
  SUFFIX=.1.2
  ;;
esac
cat > /home/${u}/.config/deluge/hostlist.conf${SUFFIX} <<DHL
{
  "file": 1,
  "format": 1
}{
  "hosts": [
    [
      "${DUDID}",
      "127.0.0.1",
      ${DPORT},
      "localclient",
      "${localpass}"
    ]
  ]
}
DHL

  wget -O /home/${u}/.config/deluge/blocklist.cache https://my.seedit4.me/storage/deluge_blocklist.dat

  echo "${u}:${pass}:10" > /home/${u}/.config/deluge/auth
  echo "localclient:${localpass}:10" >> /home/${u}/.config/deluge/auth
  chmod 600 /home/${u}/.config/deluge/auth
  chown -R ${u}.${u} /home/${u}/.config/
  mkdir /home/${u}/dwatch
  chown ${u}: /home/${u}/dwatch
  mkdir -p /home/${u}/torrents/deluge
  chown ${u}: /home/${u}/torrents
  chown ${u}: /home/${u}/torrents/deluge
  usermod -a -G ${u} www-data 2>> "$log"
  echo_progress_done "Configured for $u"
done
}

function _dservice {
  echo_progress_start "Adding systemd service files"
  if [[ ! -f /etc/systemd/system/deluged@.service ]]; then
  dvermajor=$(deluged -v | grep deluged | grep -oP '\d+\.\d+\.\d+' | cut -d. -f1)
  if [[ $dvermajor == 2 ]]; then args=" -d"; fi
    cat > /etc/systemd/system/deluged@.service <<DD
[Unit]
Description=Deluge Bittorrent Client Daemon
After=network.target

[Service]
Type=simple
User=%i

ExecStart=/usr/bin/deluged -d
ExecStop=/usr/bin/killall -w -s 9 /usr/bin/deluged
Restart=on-failure
TimeoutStopSec=300

[Install]
WantedBy=multi-user.target
DD
  fi
  if [[ ! -f /etc/systemd/system/deluge-web@.service ]]; then
    cat > /etc/systemd/system/deluge-web@.service <<DW
[Unit]
Description=Deluge Bittorrent Client Web Interface
After=network.target

[Service]
Type=simple
User=%i

ExecStart=/usr/bin/deluge-web${args}
ExecStop=/usr/bin/killall -w -s 9 /usr/bin/deluge-web
TimeoutStopSec=300
Restart=on-failure

[Install]
WantedBy=multi-user.target
DW
  fi
for u in "${users[@]}"; do
  systemctl enable -q deluged@${u} 2>&1  | tee -a $log
  systemctl enable -q deluge-web@${u} 2>&1  | tee -a $log
  systemctl start deluged@${u}
  systemctl start deluge-web@${u}
done

echo_progress_done "Services added and started"

if [[ -f /install/.nginx.lock ]]; then
  echo_progress_start "Adding nginx configs"
  bash /usr/local/bin/swizzin/nginx/deluge.sh
  systemctl reload nginx
  echo_progress_done "nginx configured"
fi

  touch /install/.deluge.lock
  touch /install/.delugeweb.lock
}

. /etc/swizzin/sources/functions/deluge
. /etc/swizzin/sources/functions/libtorrent
. /etc/swizzin/sources/functions/utils
local_packages=/usr/local/bin/swizzin
users=($(_get_user_list))
master=$(cut -d: -f1 < /root/.master.info)
pass=$(cut -d: -f2 < /root/.master.info)
codename=$(lsb_release -cs)
ip=$(ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p')

if [[ -n $1 ]]; then
  users=($1)
  _dconf
  if [[ -f /install/.nginx.lock ]]; then
    bash /etc/swizzin/scripts/nginx/deluge.sh $users
    systemctl reload nginx
  fi
  exit 0
fi

#whiptail_deluge
check_client_compatibility

#export deluge=repo
#export deluge=1.3-stable
#export deluge=master
export deluge=master

#export libtorrent=repo
#export libtorrent=RC_1_0
#export libtorrent=RC_1_1
#export libtorrent=RC_1_2
export libtorrent=repo

if ! skip_libtorrent_rasterbar; then
    #whiptail_libtorrent_rasterbar
    echo_progress_start "Building libtorrent-rasterbar"; build_libtorrent_rasterbar
    echo_progress_done "Libtorrent-rasterbar installed"
fi

build_deluge

_dconf
_dservice
