#!/bin/bash
# nginx setup for qbittorrent
. /etc/swizzin/sources/functions/utils
users=($(_get_user_list))
MASTER=$(cut -d: -f1 < /root/.master.info)

if [[ ! -f /etc/nginx/apps/qbtindex.conf ]]; then
    cat > /etc/nginx/apps/qbtindex.conf << DIN
location /qbittorrent.downloads {
    alias /home/\$remote_user/torrents/qbittorrent;
    include /etc/nginx/snippets/fancyindex.conf;
    auth_basic "What's the password?";
    auth_basic_user_file /etc/htpasswd;

  location ~* \.php\$ {

  }
}
DIN
fi

if [[ ! -f /etc/nginx/apps/qbittorrent.conf ]]; then
    cat > /etc/nginx/apps/qbittorrent.conf << 'QBTN'
location /qbittorrent {
    rewrite ^(.*[^/])$ $1/ redirect;
}
location ~ ^/qbittorrent/(?<url>.*) {
    include /etc/nginx/snippets/proxy.conf;
    proxy_set_header   X-Forwarded-Host   \$host;
    proxy_set_header   X-Forwarded-Server \$host;
    proxy_set_header   X-Forwarded-For    \$proxy_add_x_forwarded_for;
    http2_push_preload on;

    proxy_pass http://127.0.0.1:9148/\$url;
    proxy_hide_header Referer;
    proxy_hide_header Origin;
    proxy_set_header Referer '';
    proxy_set_header Origin '';
    add_header X-Frame-Options "SAMEORIGIN";

    auth_basic "What's the password?";
    auth_basic_user_file /etc/htpasswd.d/htpasswd.${MASTER};
}
QBTN
fi

#for user in ${users[@]}; do
#    port=$(grep 'WebUI\\Port' /home/${user}/.config/qBittorrent/qBittorrent.conf | cut -d= -f2)
#    cat > /etc/nginx/conf.d/${user}.qbittorrent.conf << QBTUC
#upstream ${user}.qbittorrent {
#  server 127.0.0.1:${port};
#}
#QBTUC
#done
