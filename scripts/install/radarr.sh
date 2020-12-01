#!/bin/bash
export log="/srv/tools/logs/output.log"

# radarr v3 installer
# Flying sauasges for swizzin 2020

#shellcheck source=sources/functions/utils
#. /etc/swizzin/sources/functions/utils

master=$(cut -d: -f1 < /root/.master.info)

_install_radarr() {
  waitforapt
  apt update
	apt install -y curl mediainfo sqlite3

	radarrConfDir="/home/$radarrOwner/.config/Radarr"
	mkdir -p "$radarrConfDir"
	chown -R "$radarrOwner":"$radarrOwner" "$radarrConfDir"

	echo "Downloading source files"
	#curl https://api.github.com/repos/Radarr/Radarr/releases | jq -r '.[0].assets | .[] | select (.browser_download_url | contains ("linux-core")).browser_download_url'
	if ! curl "https://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64" -L -o /tmp/Radarr.tar.gz >> "$log" 2>&1; then
		echo "Download failed, exiting"
		exit 1
	fi
	echo "Source downloaded"

	echo "Extracting archive"
	tar -xvf /tmp/Radarr.tar.gz -C /opt >> "$log" 2>&1
	echo "Archive extracted"

	touch /install/.radarr.lock

	echo "Installing Systemd service"
	cat > /etc/systemd/system/radarr.service << EOF
[Unit]
Description=Radarr Daemon
After=syslog.target network.target

[Service]
# Change the user and group variables here.
User=${radarrOwner}
Group=${radarrOwner}

Type=simple

# Change the path to Radarr or mono here if it is in a different location for you.
ExecStart=/opt/Radarr/Radarr -nobrowser
TimeoutStopSec=20
KillMode=process
Restart=on-failure

# These lines optionally isolate (sandbox) Radarr from the rest of the system.
# Make sure to add any paths it might use to the list below (space-separated).
#ReadWritePaths=/opt/Radarr /path/to/movies/folder
#ProtectSystem=strict
#PrivateDevices=true
#ProtectHome=true

[Install]
WantedBy=multi-user.target
EOF
	chown -R "$radarrOwner":"$radarrOwner" /opt/Radarr
	systemctl -q daemon-reload
	systemctl enable --now -q radarr
	sleep 1
	echo "Radarr service installed and enabled"

	if [[ -f $radarrConfDir/update_required ]]; then
		echo "Radarr is installing an internal upgrade..."
		# echo "You can track the update by running \`systemctl status Radarr\`0. in another shell."
		# echo "In case of errors, please press CTRL+C and run \`box remove sonarrv3\` in this shell and check in with us in the Discord"
		while [[ -f $radarrConfDir/update_required ]]; do
			sleep 1
			echo "Upgrade file is still here"
		done
		echo "Upgrade finished"
	fi

}

_nginx_radarr() {
	if [[ -f /install/.nginx.lock ]]; then
		echo "Installing nginx configuration"
		#TODO what is this sleep here for? See if this can be fixed by doing a check for whatever it needs to
		sleep 10
		bash /usr/local/bin/swizzin/nginx/radarr.sh
		systemctl -q reload nginx
		echo "Nginx configured"
	else
		echo "Radarr will be available on port 7878. Secure your installation manually through the web interface."
	fi
}

if [[ -z $radarrOwner ]]; then
	radarrOwner=${master}
fi

_install_radarr
_nginx_radarr

if [[ -f /install/.ombi.lock ]]; then
	echo "Please adjust your Ombi setup accordingly"
fi

if [[ -f /install/.tautulli.lock ]]; then
	echo "Please adjust your Tautulli setup accordingly"
fi

if [[ -f /install/.bazarr.lock ]]; then
	echo "Please adjust your Bazarr setup accordingly"
fi

echo "Radarr v3 installed"
