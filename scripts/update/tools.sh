#! /bin/bash

if [[ -d /srv/tools ]]; then
  echo "Updating tools"

  apt -y -q  remove php7.0 php7.0-fpm php7.0-cli php7.0-common
  LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
  apt -y -q  update
  apt -y -q  install nano php7.3 php7.3-fpm php7.3-cli php7.3-common php7.3-zip php7.3-sqlite3 php7.3-curl php7.3-simplexml
  update-alternatives --set php /usr/bin/php7.3
  sed -i "s/php7.0-fpm/php7.3-fpm/g" /etc/nginx/apps/*.conf

  cp -r /usr/local/bin/swizzin/tools/php/* /srv/tools/

  chown -R www-data: /srv/tools
  restart_php_fpm
  systemctl restart nginx
fi
