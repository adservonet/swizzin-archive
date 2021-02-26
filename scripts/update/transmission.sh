#!/bin/bash

if [[ -f /etc/nginx/apps/transmission.conf ]]; then
    cat > /etc/nginx/apps/transmission.conf << TCONF
location /transmission {
    include /etc/nginx/snippets/proxy.conf;

    proxy_pass_header  X-Transmission-Session-Id;
    proxy_set_header   X-Forwarded-Host   \$host;
    proxy_set_header   X-Forwarded-Server \$host;
    proxy_set_header   X-Forwarded-For    \$proxy_add_x_forwarded_for;

    proxy_pass        http://127.0.0.1:9091/transmission/web;
    auth_basic "What's the password?";
    auth_basic_user_file /etc/htpasswd;
}

location /rpc {
    proxy_pass_header  X-Transmission-Session-Id;
    proxy_pass         http://127.0.0.1:9091/transmission/rpc;
}

location /upload {
    proxy_pass_header  X-Transmission-Session-Id;
    proxy_pass         http://127.0.0.1:9091/transmission/upload;
}
TCONF

systemctl reload nginx

fi
