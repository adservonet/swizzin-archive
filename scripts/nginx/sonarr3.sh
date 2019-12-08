#!/bin/bash

MASTER=$(cut -d: -f1 < /root/.master.info)

if [[ ! -f /etc/nginx/apps/sonarr3.conf ]]; then
cat > /etc/nginx/apps/sonarr3.conf <<SONARR
location /sonarr {
  proxy_pass        http://127.0.0.1:8989/sonarr;
  proxy_set_header Host \$proxy_host;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto \$scheme;
  proxy_set_header X-Forwarded-Host \$host:\$server_port;
  #proxy_redirect off;
  auth_basic "What's the password?";
  auth_basic_user_file /etc/htpasswd.d/htpasswd.${MASTER};
}
SONARR
fi

cat > /var/lib/sonarr/config.xml <<SONN
<Config>
  <LogLevel>Info</LogLevel>
  <EnableSsl>False</EnableSsl>
  <Port>8989</Port>
  <SslPort>9898</SslPort>
  <UrlBase>sonarr</UrlBase>
  <BindAddress>127.0.0.1</BindAddress>
  <ApiKey>23195f535ee8406fb4b82637dc94db06</ApiKey>
  <AuthenticationMethod>None</AuthenticationMethod>
  <UpdateMechanism>BuiltIn</UpdateMechanism>
  <Branch>master</Branch>
</Config>
SONN

chown sonarr:sonarr /var/lib/sonarr/config.xml

systemctl enable sonarr
systemctl start sonarr

systemctl restart sonarr

sleep 10

echo "we are done i guess"  >>  "${SEEDIT_LOG}"  2>&1
