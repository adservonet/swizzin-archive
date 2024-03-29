#!/bin/bash
. /etc/swizzin/sources/globals.sh
. /etc/swizzin/sources/functions/utils

# Script by @ComputerByte
# For Radarr 4K Installs
#shellcheck=SC1017

# Log to Swizzin.log
export log=/root/logs/swizzin.log
touch $log
# Set variables
user=$(_get_master_username)

if [ ! -f "/install/.radarr.lock" ]; then
    echo_error "radarr is not installed."
    exit 1
fi


echo_progress_start "Making data directory and owning it to ${user}"
mkdir -p "/home/$user/.config/radarr4k"
chown -R "$user":"$user" /home/$user/.config/radarr4k
echo_progress_done "Data Directory created and owned."

echo_progress_start "Installing systemd service file"
cat >/etc/systemd/system/radarr4k.service <<-SERV
[Unit]
Description=Radarr 4K
After=syslog.target network.target

[Service]
# Change the user and group variables here.
User=${user}
Group=${user}

Type=simple

# Change the path to Radarr or mono here if it is in a different location for you.
ExecStart=/usr/lib/Radarr/Radarr -nobrowser --data=/home/${user}/.config/radarr4k
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
SERV
echo_progress_done "Radarr 4K service installed"

# This checks if nginx is installed, if it is, then it will install nginx config for radarr4k
if [[ -f /install/.nginx.lock ]]; then
    echo_progress_start "Installing nginx config"
    cat >/etc/nginx/apps/radarr4k.conf <<-NGX
location ^~ /radarr4k {
    proxy_pass http://127.0.0.1:7888/radarr4k;
    proxy_set_header Host \$proxy_host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_redirect off;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$http_connection;
    proxy_cache_bypass \$http_upgrade;
    proxy_buffering off;
    auth_basic "What's the password?";
    auth_basic_user_file /etc/htpasswd.d/htpasswd.${user};
}
# Allow the API External Access via NGINX
location ^~ /radarr4k/api {
    auth_basic off;
    proxy_pass http://127.0.0.1:7888;
}
NGX
    # Reload nginx
    systemctl reload nginx
    echo_progress_done "Nginx config applied"
fi

echo_progress_start "Generating configuration"

# Start radarr to config
systemctl stop radarr.service >>$log 2>&1


cat > /home/${user}/.config/radarr4k/config.xml << EOSC
<Config>
  <LogLevel>info</LogLevel>
  <UpdateMechanism>BuiltIn</UpdateMechanism>
  <Branch>master</Branch>
  <BindAddress>127.0.0.1</BindAddress>
  <Port>7888</Port>
  <SslPort>6969</SslPort>
  <EnableSsl>False</EnableSsl>
  <LaunchBrowser>False</LaunchBrowser>
  <AuthenticationMethod>None</AuthenticationMethod>
  <UrlBase>radarr4k</UrlBase>
  <UpdateAutomatically>False</UpdateAutomatically>
</Config>
EOSC

chown -R ${user}:${user} /home/${user}/.config/radarr4k/config.xml
systemctl enable --now radarr.service >>$log 2>&1
sleep 10
systemctl enable --now radarr4k.service >>$log 2>&1

echo_progress_start "Patching panel."
systemctl start radarr4k.service >>$log 2>&1
#Install Swizzin Panel Profiles
if [[ -f /install/.panel.lock ]]; then
    cat <<EOF >>/opt/swizzin/core/custom/profiles.py
class radarr4k_meta:
    name = "radarr4k"
    pretty_name = "Radarr 4K"
    baseurl = "/radarr4k"
    systemd = "radarr4k"
    check_theD = False
    img = "radarr"
class radarr_meta(radarr_meta):
    systemd = "radarr"
    check_theD = False
EOF
fi
touch /install/.radarr4k.lock >>$log 2>&1
echo_progress_done "Panel patched."
systemctl restart panel >>$log 2>&1
echo_progress_done "Done."
