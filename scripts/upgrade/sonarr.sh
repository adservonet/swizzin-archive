#!/bin/bash

#if [[ ! -f /install/.sonarrold.lock ]]; then
#    echo_error "Sonarr v2 not detected. Exiting!"
#    exit 1
#fi
bash /etc/swizzin/scripts/box remove sonarr
rm /install/.sonarr.lock
sleep 5
bash /etc/swizzin/scripts/box install sonarr
