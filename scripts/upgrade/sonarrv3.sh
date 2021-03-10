#!/bin/bash

if [[ ! -f /install/.sonarrv3.lock ]]; then
    echo_error "Sonarr not detected. Exiting!"
    exit 1
else
    rm /install/.sonarrv3.lock
    cp /home/seedit4me/.config/sonarr/config.xml /tmp
    /usr/local/bin/swizzin/install/sonarrv3.sh
    /usr/local/bin/swizzin/remove/sonarrv3.sh
    /usr/local/bin/swizzin/install/sonarrv3.sh
    cp /tmp/config.xml /home/seedit4me/.config/sonarr
    systemctl restart sonarr
fi

