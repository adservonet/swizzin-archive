#!/bin/bash

if [[ ! -f /install/.sonarrv3.lock ]]; then
    echo_error "Sonarr not detected. Exiting!"
    exit 1
else
    rm /install/.sonarrv3.lock
    box install sonarrv3
    box remove sonarrv3
    box install sonarrv3
fi

