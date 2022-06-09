#!/bin/bash
# btsync nginx conf

#shellcheck source=sources/functions/utils
. /etc/swizzin/sources/functions/utils
port=$(cat /home/seedit4me/.btsync_port)

cat > /etc/nginx/apps/btsync.conf << BTSYNC
 location /btsync/ {
         rewrite ^/btsync/gui(.*) /btsync\$1 last;
         proxy_pass              http://127.0.0.1:$port/gui/;
         proxy_redirect  /gui/ /btsync/;
         proxy_buffering         off;
         proxy_set_header Host           \$host;
         proxy_set_header X-Real-IP      \$remote_addr;
}

location /gui/ {
    proxy_pass http://127.0.0.1:$port/gui/;
}
BTSYNC
