#!/bin/bash

MASTER=$(cut -d: -f1 < /root/.master.info)

if [[ ! -f /etc/nginx/apps/transmission.conf ]]; then
  cat > /etc/nginx/apps/transmission.conf <<CFG
location /transmission {
    include /etc/nginx/snippets/proxy.conf;
    proxy_pass        http://127.0.0.1:9091/transmission;
    auth_basic "What's the password?";
    auth_basic_user_file /etc/htpasswd.d/htpasswd.${MASTER};
}
CFG
fi

systemctl reload nginx
