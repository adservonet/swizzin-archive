#!/bin/bash

MASTER=$(cut -d: -f1 < /root/.master.info)

if [[ ! -f /etc/nginx/apps/qbittorrent.conf ]]; then
  cat > /etc/nginx/apps/qbittorrent.conf <<CFG


location /qbittorrent {
    rewrite ^(.*[^/])$ $1/ redirect;
}
location ~ ^/qbittorrent/(?<url>.*) {
    proxy_pass http://127.0.0.1:9148/$url;
    include /config/proxy.conf;
    proxy_hide_header Referer;
    proxy_hide_header Origin;
    proxy_set_header Referer '';
    proxy_set_header Origin '';

    #    proxy_pass_header  X-Transmission-Session-Id;
    proxy_set_header   X-Forwarded-Host   \$host;
    proxy_set_header   X-Forwarded-Server \$host;
    proxy_set_header   X-Forwarded-For    \$proxy_add_x_forwarded_for;

    auth_basic "What's the password?";
    auth_basic_user_file /etc/htpasswd.d/htpasswd.${MASTER};

}

CFG
fi

systemctl reload nginx
