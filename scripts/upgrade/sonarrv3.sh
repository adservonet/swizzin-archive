#!/bin/bash

if [[ ! -f /install/.sonarrv3.lock ]]; then
    echo_error "Sonarr not detected. Exiting!"
    exit 1
else
    rm /install/.sonarrv3.lock
    /usr/local/bin/swizzin/install/sonarrv3.sh
    /usr/local/bin/swizzin/remove/sonarrv3.sh
    /usr/local/bin/swizzin/install/sonarrv3.sh
fi

