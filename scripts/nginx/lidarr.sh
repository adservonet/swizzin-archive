#!/bin/bash
# Nginx conf for Lidarr v3
# Flying sausages 2020
master=$(cut -d: -f1 < /root/.master.info)

cat > /etc/nginx/apps/lidarr.conf <<LIDN
location /lidarr {
  proxy_pass        http://127.0.0.1:8686/lidarr;
  proxy_set_header Host \$proxy_host;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto \$scheme;
  proxy_redirect off;
  auth_basic "What's the password?";
  auth_basic_user_file /etc/htpasswd.d/htpasswd.${master};

  proxy_http_version 1.1;
  proxy_set_header Upgrade \$http_upgrade;
  proxy_set_header Connection \$http_connection;
  proxy_cache_bypass \$http_upgrade;
  proxy_buffering off;
}
LIDN

isactive=$(systemctl is-active lidarr)

if [[ $isactive == "active" ]]; then
    echo_log_only "Stopping lidarr"
    systemctl stop lidarr
fi
user=$(grep User /etc/systemd/system/lidarr.service | cut -d= -f2)
echo_log_only "Lidarr user detected as $user"
apikey=$(grep -oPm1 "(?<=<ApiKey>)[^<]+" /home/"$user"/.config/Lidarr/config.xml)
echo_log_only "Apikey = $apikey" >> "$log"
#TODO cahnge Branch whenever that becomes relevant
cat > /home/"$user"/.config/Lidarr/config.xml << LIDARR
<Config>
  <LogLevel>info</LogLevel>
  <UpdateMechanism>BuiltIn</UpdateMechanism>
  <BindAddress>127.0.0.1</BindAddress>
  <Port>8686</Port>
  <SslPort>9696</SslPort>
  <EnableSsl>False</EnableSsl>
  <LaunchBrowser>False</LaunchBrowser>
  <ApiKey>${apikey}</ApiKey>
  <AuthenticationMethod>None</AuthenticationMethod>
  <UrlBase>lidarr</UrlBase>
</Config>
LIDARR

chown -R "$user":"$user" /home/"$user"/.config/Lidarr

#shellcheck source=sources/functions/utils
. /etc/swizzin/sources/functions/utils
systemctl start lidarr -q # Switch lidarr on regardless whether it was off before or not as we need to have it online to trigger this cahnge
if ! timeout 15 bash -c -- "while ! curl -fL \"http://127.0.0.1:7878/api/v1/system/status?apiKey=${apikey}\" >> \"$log\" 2>&1; do sleep 5; done"; then
    echo_error "Lidarr API did not respond as expected. Please make sure Lidarr is on v1 and running."
    exit 1
else
    urlbase="$(curl -sL "http://127.0.0.1:7878/api/v1/config/host?apikey=${apikey}" | jq '.urlBase' | cut -d '"' -f 2)"
    echo_log_only "Lidarr API tested and reachable"
fi

payload=$(curl -sL "http://127.0.0.1:7878/api/v1/config/host?apikey=${apikey}" | jq ".certificateValidation = \"disabledForLocalAddresses\"")
echo_log_only "Payload = \n${payload}"
echo_log_only "Return from lidarr after PUT ="
curl -s "http://127.0.0.1:7878${urlbase}/api/v1/config/host?apikey=${apikey}" -X PUT -H 'Accept: application/json, text/javascript, */*; q=0.01' --compressed -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' --data-raw "${payload}" >> "$log"

# Switch lidarr back off if it was dead before
if [[ $isactive != "active" ]]; then
    systemctl stop lidarr
fi
