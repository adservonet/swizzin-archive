#!/bin/bash

if [[ ! -f /install/.sonarr.lock ]]; then
    echo_error "Sonarr not detected. Exiting!"
    exit 1
else
    rm /install/.sonarr.lock
    box remove sonarrv3
    box install sonarrv3
fi

