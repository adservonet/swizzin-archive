#!/bin/bash
# nginx installer
# Author: liara
# Copyright (C) 2017 Swizzin
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
distribution=$(lsb_release -is)
release=$(lsb_release -rs)
codename=$(lsb_release -cs)
#if [[ -f /tmp/.install.lock ]]; then
#  log="/root/logs/install.log"
#else
#  log="/dev/null"
#fi

if [[ -n $(pidof apache2) ]]; then
  if [[ -z $apache2 ]]; then
    if (whiptail --title "apache2 conflict" --yesno --yes-button "Purge it!" --no-button "Disable it" "WARNING: The installer has detected that apache2 is already installed. To continue, the installer must either purge apache2 or disable it." 8 78) then
      apache2=purge
    else
      apache2=disable
    fi
  fi
  if [[ $apache2 == "purge" ]]; then
    echo "Purging apache2 ... "
    systemctl disable apache2 >> /dev/null 2>&1
    systemctl stop apache2
    apt-get -y -q purge apache2 >>  "${SEEDIT_LOG}"  2>&1
  elif [[ $apache2 == "disable" ]]; then
    echo "Disabling apache2 ... "
    systemctl disable apache2 >> /dev/null 2>&1
    systemctl stop apache2
  fi
fi

LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
waitforapt
sudo dpkg --configure -a
apt-get -y -f install
apt-get -y -qq update
APT='nginx-extras subversion ssl-cert php7.3-fpm php7.3-common libfcgi0ldbl php7.3-cli php7.3-dev php7.3-xml php7.3-curl php7.3-xmlrpc php7.3-json php7.3-mbstring php7.3-opcache php-geoip php7.3-xml php7.3-gd'
for depends in $APT; do
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "$depends" >>  "${SEEDIT_LOG}"  2>&1 || { echo "ERROR: APT-GET could not install a required package: ${depends}. That's probably not good..."; }
done

cd /etc/php
phpv=$(ls -d */ | cut -d/ -f1)
for version in $phpv; do
  sed -i -e "s/post_max_size = 8M/post_max_size = 64M/" \
          -e "s/upload_max_filesize = 2M/upload_max_filesize = 92M/" \
          -e "s/expose_php = On/expose_php = Off/" \
          -e "s/128M/768M/" \
          -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" \
          -e "s/;opcache.enable=0/opcache.enable=1/" \
          -e "s/;opcache.memory_consumption=64/opcache.memory_consumption=128/" \
          -e "s/;opcache.max_accelerated_files=2000/opcache.max_accelerated_files=4000/" \
          -e "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=240/" /etc/php/$version/fpm/php.ini
  phpenmod -v $version opcache
done

  sudo apt-get -y -q  purge php7.0.*
  sudo apt-get -y -q  purge php7.1.*
  sudo apt-get -y -q  purge php7.2.*
  sudo apt-get -y -q  purge php7.4.*
  apt-get -y -q install libmcrypt-dev
  pear config-set php_dir /usr/bin/php
  pear config-set ext_dir /usr/lib/php/20180731
  pear config-set php_bin /usr/bin/php7.3
  pear config-set php_suffix 7.3
  pear config-set php_ini /etc/php/7.3/fpm/php.ini
  printf "\n" | pecl install mcrypt-1.0.2
  echo extension=mcrypt.so > /etc/php/7.3/mods-available/mcrypt.ini
  echo extension=mcrypt.so > /etc/php/7.3/fpm/conf.d/20-mcrypt.ini
  echo extension=mcrypt.so > /etc/php/7.3/cli/conf.d/20-mcrypt.ini
  systemctl restart php7.3-fpm
  sudo update-alternatives --set php /usr/bin/php7.3

  sed -i "s/php7.0-fpm/php7.3-fpm/g" /etc/nginx/apps/*.conf

if [[ -f /lib/systemd/system/php7.3-fpm.service ]]; then
  sock=php7.3-fpm
elif [[ -f /lib/systemd/system/php7.2-fpm.service ]]; then
  sock=php7.2-fpm
elif [[ -f /lib/systemd/system/php7.1-fpm.service ]]; then
  sock=php7.1-fpm
else
  sock=php7.0-fpm
fi

rm -rf /etc/nginx/sites-enabled/default
cat > /etc/nginx/sites-enabled/default <<NGC
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name _;

  location /.well-known {
    alias /srv/.well-known;
    allow all;
    default_type "text/plain";
    autoindex    on;
  }

  location / {
    return 301 https://\$host\$request_uri;
  }
}

# SSL configuration
server {
  listen 443 ssl http2 default_server;
  listen [::]:443 ssl http2 default_server;
  server_name _;

  send_timeout 100m;
  resolver 8.8.4.4 8.8.8.8 valid=300s;
  resolver_timeout 10s;

  ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
  ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
  include snippets/ssl-params.conf;

  #ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  #ssl_prefer_server_ciphers on;
  #ssl_ciphers \'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA\';
  ssl_stapling on;
  ssl_stapling_verify on;
  ssl_session_tickets off;

  gzip on;
  gzip_vary on;
  gzip_min_length 1000;
  gzip_proxied any;
  gzip_types text/plain text/css text/xml application/xml text/javascript application/x-javascript image/svg+xml;
  gzip_disable "MSIE [1-6]\.";


  client_max_body_size 512M;
  server_tokens off;
  root /srv/;

  proxy_set_header Sec-WebSocket-Extensions $http_sec_websocket_extensions;
  proxy_set_header Sec-WebSocket-Key $http_sec_websocket_key;
  proxy_set_header Sec-WebSocket-Version $http_sec_websocket_version;
  proxy_http_version 1.1;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection "Upgrade";
  proxy_redirect off;
  proxy_buffering off;

  index index.html index.php index.htm;

  location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/$sock.sock;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
  }

  include /etc/nginx/apps/*;

  location ~ /\.ht {
    deny all;
  }

  location /fancyindex {

  }
}
NGC

mkdir -p /etc/nginx/ssl/
mkdir -p /etc/nginx/snippets/
mkdir -p /etc/nginx/apps/

chmod 700 /etc/nginx/ssl

cd /etc/nginx/ssl
openssl dhparam -out dhparam.pem 2048 >> "${SEEDIT_LOG}"  2>&1

cat > /etc/nginx/snippets/ssl-params.conf <<SSC
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
ssl_ecdh_curve secp384r1;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 127.0.0.1 valid=300s;
resolver_timeout 5s;
# Disable preloading HSTS for now.  You can use the commented out header line that includes
# the "preload" directive if you understand the implications.
#add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";

#add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
#add_header X-Frame-Options DENY;
add_header X-Frame-Options SAMEORIGIN;
add_header X-Content-Type-Options nosniff;

ssl_dhparam /etc/nginx/ssl/dhparam.pem;
SSC

cat > /etc/nginx/snippets/proxy.conf <<PROX
client_max_body_size 512M;
client_body_buffer_size 128k;

#Timeout if the real server is dead
proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;

# Advanced Proxy Config
send_timeout 5m;
proxy_read_timeout 240;
proxy_send_timeout 240;
proxy_connect_timeout 240;

# Basic Proxy Config
proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto https;
#proxy_redirect  http://  \$scheme://;
proxy_http_version 1.1;
proxy_set_header Connection "";
proxy_cache_bypass \$cookie_session;
proxy_no_cache \$cookie_session;
proxy_buffers 32 4k;
PROX

svn export https://github.com/Naereen/Nginx-Fancyindex-Theme/trunk/Nginx-Fancyindex-Theme-dark /srv/fancyindex >>  "${SEEDIT_LOG}"  2>&1
cat > /etc/nginx/snippets/fancyindex.conf <<FIC
fancyindex on;
fancyindex_localtime on;
fancyindex_exact_size off;
fancyindex_header "/fancyindex/header.html";
fancyindex_footer "/fancyindex/footer.html";
#fancyindex_ignore "examplefile.html"; # Ignored files will not show up in the directory listing, but will still be public. 
#fancyindex_ignore "Nginx-Fancyindex-Theme"; # Making sure folder where files are don't show up in the listing. 
fancyindex_name_length 255; # Maximum file name length in bytes, change as you like.
FIC
sed -i 's/href="\/[^\/]*/href="\/fancyindex/g' /srv/fancyindex/header.html
sed -i 's/src="\/[^\/]*/src="\/fancyindex/g' /srv/fancyindex/footer.html


locks=($(find /usr/local/bin/swizzin/nginx -type f -printf "%f\n" | cut -d "." -f 1 | sort -d -r))
for i in "${locks[@]}"; do
  app=${i}
  if [[ -f /install/.$app.lock ]]; then
    echo "Installing nginx config for $app"
    /usr/local/bin/swizzin/nginx/$app.sh
  fi
done

systemctl restart nginx

. /etc/swizzin/sources/functions/php
restart_php_fpm


touch /install/.nginx.lock
