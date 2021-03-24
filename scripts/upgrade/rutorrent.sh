#!/bin/bash
# ruTorrent upgrade wrapper
# Author: liara
# Does not update from git remote at this time...

if [[ -d /srv/rutorrent ]] && [[ ! -f /install/.rutorrent.lock ]]; then
    touch /install/.rutorrent.lock
fi

if [[ ! -f /install/.rutorrent.lock ]]; then
    echo_error "ruTorrent doesn't appear to be installed. Script exiting."
    exit 1
fi

bash /usr/local/bin/swizzin/nginx/rutorrent.sh

user=$(cut -d: -f1 < /root/.master.info)
port=$(cat /home/seedit4me/.rtorrent_port)
portend=$(cat /home/seedit4me/.rtorrent_port)

cat > /home/${user}/.rtorrent.rc << EOF
# -- START HERE --
directory.default.set = /home/${user}/torrents/rtorrent
encoding.add = UTF-8
encryption = allow_incoming,try_outgoing,enable_retry
execute.nothrow = chmod,777,/home/${user}/.config/rpc.socket
execute.nothrow = chmod,777,/home/${user}/.sessions
network.port_random.set = no
network.port_range.set = $port-$portend
network.scgi.open_local = /var/run/${user}/.rtorrent.sock
schedule2 = chmod_scgi_socket, 0, 0, "execute2=chmod,\"g+w,o=\",/var/run/${user}/.rtorrent.sock"
network.tos.set = throughput
pieces.hash.on_completion.set = no
protocol.pex.set = no
schedule = watch_directory,5,5,load.start=/home/${user}/rwatch/*.torrent
session.path.set = /home/${user}/.sessions/
network.xmlrpc.size_limit.set = 2097152
throttle.global_down.max_rate.set = 0
throttle.global_up.max_rate.set = 0
throttle.max_peers.normal.set = 100
throttle.max_peers.seed.set = -1
throttle.max_uploads.global.set = 100
throttle.min_peers.normal.set = 1
throttle.min_peers.seed.set = 2
trackers.use_udp.set = yes
schedule = low_diskspace,5,60,close_low_diskspace=5120M
execute = {sh,-c,/usr/bin/php /srv/rutorrent/php/initplugins.php ${user} &}

# -- END HERE --
EOF
chown ${user}.${user} -R /home/${user}/.rtorrent.rc

systemctl restart rtorrent@seedit4me



systemctl reload nginx
