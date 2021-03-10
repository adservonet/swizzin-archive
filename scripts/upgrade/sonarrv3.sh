#!/bin/bash

if [[ ! -f /install/.sonarrv3.lock ]]; then
    echo_error "Sonarr not detected. Exiting!"
    exit 1
else
    systemctl stop sonarr
    rm -rf /tmp/sonarrv3
    mkdir -p /tmp/sonarrv3
    cp -rp /home/seedit4me/.config/sonarr/* /tmp/sonarrv3
    rm /install/.sonarrv3.lock
    /usr/local/bin/swizzin/install/sonarrv3.sh
    /usr/local/bin/swizzin/remove/sonarrv3.sh
    /usr/local/bin/swizzin/install/sonarrv3.sh
    /bin/cp -rfp /tmp/sonarrv3/* /home/seedit4me/.config/sonarr
    rm -rf /tmp/sonarrv3
    systemctl start sonarr
fi

