#!/bin/bash
# rTorrent installer
# Author: liara
# Copyright (C) 2017 Swizzin
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
function _string() { perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15 ; }

function _rconf() {
cat >/home/${user}/.rtorrent.rc<<EOF
################################################################################
## Seedit4me Configuration file for rTorrent.                                 ##
## Last updated Aug 2019 by Peter                                             ##
##   If you choose to edit this file, there are a couple of things to note:   ##
##   1. Be sure this file is saved with \n (LF) line breaks.  If you're       ##
##      connecting via SSH and using nano (or similar), this shouldn't be a   ##
##      problem.  However, if you're on Windows and are (S)FTP'ing the file   ##
##      to your computer, there's a chance that the line breaks may change.   ##
##      If there aren't LF line breaks, rTorrent will not start.              ##
##   2. Please respect the fact that this is a shared server.  Hash checking  ##
##      on completion is disabled because most times it will spike the load   ##
##      while it's checking the files.  For large torrents, this can take a   ##
##      very long time, and generally isn't even needed.                      ##
##   3. scgi must not be changed, in order for ruTorrent to work.             ##
##                                                                            ##
##   4. If you edit this config and break your client we will formatt         ##
##      your slot and all data will be lost!!                                 ##
##                                                                            ##
##                                                                            ##
##                                                                            ##
##                                                                            ##
##                                                                            ##
################################################################################





# -- START HERE --
##############################################################################################
## These control where rTorrent looks for .torrents and where files are saved DO NOT CHANGE ##
##############################################################################################
directory.default.set = /home/${user}/torrents/rtorrent
schedule2 = chmod_scgi_socket, 0, 0, "execute2=chmod,\"g+w,o=\",/var/run/${user}/.rtorrent.sock"
schedule = watch_directory,5,5,load.start=/home/${user}/rwatch/*.torrent
session.path.set = /home/${user}/.sessions/
network.xmlrpc.size_limit.set = 2097152

#################################################
## These settings are mostly user customizable ##
#################################################
protocol.pex.set = no
throttle.global_down.max_rate.set = 0
throttle.global_up.max_rate.set = 0
throttle.max_peers.normal.set = 100
throttle.max_peers.seed.set = -1
throttle.max_uploads.global.set = 100
throttle.min_peers.normal.set = 1
throttle.min_peers.seed.set = 2
trackers.use_udp.set = yes

###############################################################
## These settings shouldn't be changed DO NOT CHANGE        ##
###############################################################

encoding.add = UTF-8
encryption = allow_incoming,try_outgoing,enable_retry
execute.nothrow = chmod,777,/home/${user}/.config/rpc.socket
execute.nothrow = chmod,777,/home/${user}/.sessions
network.port_random.set = no
network.port_range.set = $port-$portend
network.scgi.open_local = /var/run/${user}/.rtorrent.sock

network.tos.set = throughput
pieces.hash.on_completion.set = no

schedule = low_diskspace,5,60,close_low_diskspace=5120M
execute = {sh,-c,/usr/bin/php /srv/rutorrent/php/initplugins.php ${user} &}
# -- END HERE --
EOF
chown ${user}.${user} -R /home/${user}/.rtorrent.rc
}


function _makedirs() {
	mkdir -p /home/${user}/torrents/rtorrent >> "${SEEDIT_LOG}" 2>&1
	mkdir -p /home/${user}/.sessions
	mkdir -p /home/${user}/rwatch
	chown -R ${user}.${user} /home/${user}/{torrents,.sessions,rwatch} >> "${SEEDIT_LOG}" 2>&1
	usermod -a -G www-data ${user} >> "${SEEDIT_LOG}" 2>&1
	usermod -a -G ${user} www-data >> "${SEEDIT_LOG}" 2>&1
}

_systemd() {
cat >/etc/systemd/system/rtorrent@.service<<EOF
[Unit]
Description=rTorrent
After=network.target

[Service]
Type=forking
KillMode=none
User=%I
ExecStartPre=-/bin/rm -f /home/%I/.sessions/rtorrent.lock
ExecStart=/usr/bin/screen -d -m -fa -S rtorrent /usr/bin/rtorrent
ExecStop=/usr/bin/screen -X -S rtorrent quit
WorkingDirectory=/home/%I/

[Install]
WantedBy=multi-user.target
EOF
systemctl enable rtorrent@${user} >> "${SEEDIT_LOG}" 2>&1
service rtorrent@${user} start
}

export DEBIAN_FRONTEND=noninteractive

#if [[ -f /tmp/.install.lock ]]; then
#  export log="/root/logs/install.log"
#else
#  export log="/dev/null"
#fi
. /etc/swizzin/sources/functions/rtorrent
#whiptail_rtorrent

#if [[ $function == 0.9.8 ]]; then
#  export rtorrentver='0.9.8'
#  export libtorrentver='0.13.8'
#elif [[ $function == 0.9.7 ]]; then
#  export rtorrentver='0.9.7'
#  export libtorrentver='0.13.7'
#elif [[ $function == 0.9.6 ]]; then
#  export rtorrentver='0.9.6'
#  export libtorrentver='0.13.6'
#elif [[ $function == 0.9.4 ]]; then
#  export rtorrentver='0.9.4'
#  export libtorrentver='0.13.4'
#elif [[ $function == 0.9.3 ]]; then
#  export rtorrentver='0.9.3'
#  export libtorrentver='0.13.3'
#elif [[ $function == feature-bind ]]; then
  export rtorrentver='feature-bind'
  export libtorrentver='feature-bind'
#elif [[ $function == repo ]]; then
#  export rtorrentver='repo'
#  export libtorrentver='repo'
#fi


noexec=$(grep "/tmp" /etc/fstab | grep noexec)
user=$(cut -d: -f1 < /root/.master.info)
rutorrent="/srv/rutorrent/"
port=$(cat /home/seedit4me/.rtorrent_port)
portend=$(cat /home/seedit4me/.rtorrent_port)

if [[ -n $1 ]]; then
	user=$1
	_makedirs
	_rconf
	exit 0
fi

if [[ -n $noexec ]]; then
	mount -o remount,exec /tmp
	noexec=1
fi
	  echo "Installing rTorrent Dependencies ... " >> "${SEEDIT_LOG}" 2>&1;depends_rtorrent
		if [[ ! $rtorrentver == repo ]]; then
			echo "Building xmlrpc-c from source ... " >> "${SEEDIT_LOG}" 2>&1;build_xmlrpc-c
			echo "Building libtorrent from source ... " >> "${SEEDIT_LOG}" 2>&1;build_libtorrent_rakshasa
			echo "Building rtorrent from source ... " >> "${SEEDIT_LOG}" 2>&1;build_rtorrent
		else
			echo "Installing rtorrent with apt-get ... " >> "${SEEDIT_LOG}" 2>&1;rtorrent_apt
		fi
		echo "Making ${user} directory structure ... " >> "${SEEDIT_LOG}" 2>&1;_makedirs
		echo "setting up rtorrent.rc ... " >> "${SEEDIT_LOG}" 2>&1;_rconf;_systemd

if [[ -n $noexec ]]; then
	mount -o remount,noexec /tmp
fi
		touch /install/.rtorrent.lock
