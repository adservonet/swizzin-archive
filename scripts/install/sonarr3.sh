#!/bin/bash

waitforapt
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF >>  "${SEEDIT_LOG}"  2>&1
waitforapt
sudo apt -y install apt-transport-https ca-certificates >>  "${SEEDIT_LOG}"  2>&1
echo "deb https://download.mono-project.com/repo/ubuntu stable-xenial main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list >>  "${SEEDIT_LOG}"  2>&1
waitforapt
sudo apt update >>  "${SEEDIT_LOG}"  2>&1

waitforapt
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 2009837CBFFD68F45BC180471F4F90DE2A9B4BF8 >>  "${SEEDIT_LOG}"  2>&1
echo "deb https://apt.sonarr.tv/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/sonarr.list >>  "${SEEDIT_LOG}"  2>&1
waitforapt
sudo apt update
waitforapt
sudo apt -y install sonarr >>  "${SEEDIT_LOG}"  2>&1

systemctl stop sonarr

sleep 1

sed -i "s/<UrlBase>.*<\/UrlBase>/<UrlBase>sonarr<\/UrlBase>/g" /var/lib/sonarr/config.xml
sed -i "s/<BindAddress>.*<\/BindAddress>/<BindAddress>127\.0\.0\.1<\/BindAddress>/g" /var/lib/sonarr/config.xml

sleep 1

systemctl start sonarr

touch /install/.sonarr3.lock

