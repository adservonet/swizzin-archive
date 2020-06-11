#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
username=$(cut -d: -f1 < /root/.master.info)

waitforapt
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF >>  "${log}"  2>&1

waitforapt
apt -y install apt-transport-https ca-certificates >>  "${log}"  2>&1

echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list >>  "${log}"  2>&1

waitforapt
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 2009837CBFFD68F45BC180471F4F90DE2A9B4BF8 >>  "${log}"  2>&1

echo "deb https://apt.sonarr.tv/ubuntu bionic main" | sudo tee /etc/apt/sources.list.d/sonarr.list >>  "${log}"  2>&1

waitforapt
apt update

waitforapt
apt -y -f install sonarr >>  "${log}"  2>&1
usermod -a -G seedit4me sonarr
usermod -a -G sonarr seedit4me
systemctl stop sonarr

mv /lib/systemd/system/sonarr.service /lib/systemd/system/sonarr@.service

chown -R "${username}":"${username}" /usr/lib/sonarr/
chown -R "${username}":"${username}" /var/lib/sonarr/

cat > /lib/systemd/system/sonarr@.service <<SONARR
[Unit]
Description=Sonarr Daemon
After=network.target

[Service]
User=%i
Group=%i
UMask=002

Type=simple
ExecStart=/usr/bin/mono --debug /usr/lib/sonarr/bin/Sonarr.exe -nobrowser -data=/var/lib/son$
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
SONARR

#[Unit]
#Description=Sonarr Daemon
#After=network.target
#
#[Service]
#User=sonarr
#Group=sonarr
#UMask=002
#
#Type=simple
#ExecStart=/usr/bin/mono --debug /usr/lib/sonarr/bin/Sonarr.exe -nobrowser -data=/var/lib/son$
#TimeoutStopSec=20
#KillMode=process
#Restart=on-failure
#
#[Install]
#WantedBy=multi-user.target

cat > /var/lib/sonarr/config.xml <<SONN
<Config>
  <LogLevel>Info</LogLevel>
  <EnableSsl>False</EnableSsl>
  <Port>8989</Port>
  <SslPort>9898</SslPort>
  <UrlBase>sonarr</UrlBase>
  <BindAddress>127.0.0.1</BindAddress>
  <ApiKey>23195f535ee8406fb4b82637dc94db06</ApiKey>
  <AuthenticationMethod>None</AuthenticationMethod>
  <UpdateMechanism>BuiltIn</UpdateMechanism>
  <Branch>master</Branch>
</Config>
SONN

  systemctl enable --now sonarr@${username} >> ${log} 2>&1
  sleep 10

touch /install/.sonarr3.lock

if [[ -f /install/.nginx.lock ]]; then
  sleep 3
  bash /usr/local/bin/swizzin/nginx/sonarr3.sh
  systemctl reload nginx
fi