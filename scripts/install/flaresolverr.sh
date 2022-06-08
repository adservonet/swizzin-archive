#!/bin/bash
# flaresolverr installer

#shellcheck source=sources/functions/utils
. /etc/swizzin/sources/functions/utils

_systemd() {
    echo_progress_start "Installing Systemd service"
    cat > /etc/systemd/system/flaresolverr@.service << EOF
[Unit]
Description=FlareSolverr
After=network.target

[Service]
SyslogIdentifier=flaresolverr
Restart=always
RestartSec=5
Type=simple
User=flaresolverr
Group=flaresolverr
Environment="LOG_LEVEL=info"
Environment="CAPTCHA_SOLVER=none"
WorkingDirectory=/opt/FlareSolverr
ExecStart=/opt/FlareSolverr/flaresolverr
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
EOF
    echo_progress_done "Service installed"

    systemctl enable -q --now flaresolverr 2>&1 | tee -a $log
}

##############################

apt_install nodejs npm libgtk-3-0 libdbus-glib-1-2
cd /opt
git clone https://github.com/FlareSolverr/FlareSolverr
cd FlareSolverr/
npm install  jest@^27.0.0

npm install

_systemd

touch "/install/.flaresolverr.lock"
echo_success "flaresolverr installed"
