#!/bin/bash

. /etc/swizzin/sources/functions/utils
version=$(github_latest_version "plexdrive/plexdrive")
username=$(cut -d: -f1 < /root/.master.info)

echo_progress_start "Downloading and extracting plexdrive"

mkdir -p /home/$username/plexdrive
cd /home/$username/plexdrive
wget "https://github.com/plexdrive/plexdrive/releases/download/${version}/plexdrive-linux-amd64" >> "$log" 2>&1
chmod +x plexdrive-linux-amd64
echo_progress_done


# function _service() {
#     echo_progress_start "Creating systemd service"
#     cat > "/etc/systemd/system/irssi@.service" << ADC
# [Unit]
# Description=AutoDL IRSSI
# After=network.target

# [Service]
# Type=forking
# KillMode=none
# User=%i
# ExecStart=/usr/bin/screen -d -m -fa -S irssi /usr/bin/irssi
# ExecStop=/usr/bin/screen -S irssi -X stuff '/quit\n'
# WorkingDirectory=/home/%i/
# Restart=on-failure
# RestartSec=5s

# [Install]
# WantedBy=multi-user.target
# ADC

#     for u in "${users[@]}"; do
#         systemctl enable -q --now irssi@${u} 2>&1 | tee -a $log
#     done
#     echo_progress_done
# }

touch /install/.plexdrive.lock
echo_success "plexdrive installed"
