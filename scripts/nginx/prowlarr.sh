#!/bin/bash
# Nginx conf for *Arr
# Flying sausages 2020
# Refactored by Bakerboy448 2021
master=$(_get_master_username)
app_name="prowlarr"

if ! PROWLARR_OWNER="$(swizdb get $app_name/owner)"; then
    PROWLARR_OWNER=$master
fi
user="$PROWLARR_OWNER"

app_port="9696"
app_sslport="6969"
user="$PROWLARR_OWNER"
app_servicefile="${app_name}.service"
app_configdir="/home/$user/.config/${app_name^}"
app_baseurl="$app_name"
app_branch="develop"


cat > /etc/nginx/apps/$app_name.conf << PROWLARR
location /$app_baseurl {
  proxy_pass        http://127.0.0.1:$app_port/$app_baseurl;
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
  # Allow the App API
  location /$app_baseurl/api { auth_request off;
    proxy_pass http://127.0.0.1:$app_port/$app_baseurl/api;
 }
  # Allow Content
  location /$app_baseurl/Content { auth_request off;
    proxy_pass http://127.0.0.1:$app_port/$app_baseurl/Content;
}
  # Allow Indexers  $1 matches the regex
  location ~ /$app_baseurl/[0-9]+/api { auth_request off;
    proxy_pass       http://127.0.0.1:$app_port/$app_baseurl/\$1/api;
}

PROWLARR

wasActive=$(systemctl is-active $app_servicefile)

if [[ $wasActive == "active" ]]; then
    echo_log_only "Stopping $app_name"
    systemctl stop -q "$app_servicefile"
fi
apikey=$(grep -oPm1 "(?<=<ApiKey>)[^<]+" "$app_configdir"/config.xml)

# Set to Debug as this is alpha software
# ToDo: Logs back to Info
cat > "$app_configdir"/config.xml << PROWLARR
<Config>
  <LogLevel>debug</LogLevel>
  <UpdateMechanism>BuiltIn</UpdateMechanism>
  <BindAddress>127.0.0.1</BindAddress>
  <Port>$app_port</Port>
  <SslPort>$app_sslport</SslPort>
  <EnableSsl>False</EnableSsl>
  <LaunchBrowser>False</LaunchBrowser>
  <ApiKey>${apikey}</ApiKey>
  <AuthenticationMethod>None</AuthenticationMethod>
  <SslCertHash></SslCertHash>
  <UrlBase>$app_baseurl</UrlBase>
  <Branch>$app_branch</Branch>
</Config>
PROWLARR

if [[ -f /install/.rutorrent.lock ]]; then
    sqlite3 /home/"$user"/.config/Prowlarr/prowlarr.db "INSERT or REPLACE INTO Config VALUES('6', 'certificatevalidation', 'DisabledForLocalAddresses');"
fi


chown -R "$user":"$user" "$app_configdir"

# Switch app back off if it was dead before; otherwise start it
if [[ $wasActive == "active" ]]; then
    systemctl start "$app_servicefile" -q
fi
