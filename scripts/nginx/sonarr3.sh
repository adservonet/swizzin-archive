#!/bin/bash

MASTER=$(cut -d: -f1 < /root/.master.info)

if [[ ! -f /etc/nginx/apps/sonarr3.conf ]]; then
cat > /etc/nginx/apps/sonarr3.conf <<SONARR
location /sonarr {
  proxy_pass        http://127.0.0.1:8989/sonarr;
  proxy_set_header Host \$proxy_host;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto \$scheme;
  proxy_redirect off;
  auth_basic "What's the password?";
  auth_basic_user_file /etc/htpasswd.d/htpasswd.${MASTER};
}
SONARR
fi
