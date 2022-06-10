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


function _service() {
    echo_progress_start "Creating systemd service"
    cat > "/etc/systemd/system/plexdrive.service" << PLEXDRIVE
[Unit]
Description=Plexdrive
AssertPathIsDirectory=/mnt/plexdrive
After=network-online.target

[Service]
Type=notify
ExecStart=/home/$username/plexdrive/plexdrive mount -v 2 /mnt/plexdrive
ExecStopPost=-/bin/fusermount -quz /mnt/plexdrive
Restart=on-abort

[Install]
WantedBy=default.target
PLEXDRIVE
    systemctl enable -q --now plexdrive 2>&1 | tee -a $log
    echo_progress_done
}

_service

touch /install/.plexdrive.lock
echo_success "plexdrive installed"
