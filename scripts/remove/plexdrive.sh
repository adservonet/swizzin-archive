#!/bin/bash

username=$(cut -d: -f1 < /root/.master.info)

# systemctl disable --now plexdrive -q
rm -rf /home/$username/plexdrive

# if [[ -f /install/.nginx.lock ]]; then
#     rm /etc/nginx/apps/airsonic.conf
#     systemctl reload nginx
# fi

rm /install/.plexdrive.lock
