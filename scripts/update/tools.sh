#! /bin/bash

if [[ -d /srv/tools ]]; then
  echo "Updating tools"

if [[ -f /lib/systemd/system/php7.3-fpm.service ]]; then
  echo "php setup seems ok"
else
  apt -y -q  remove php7.0 php7.0-fpm php7.0-cli php7.0-common
  LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
  apt -y -q  update
  apt -y -q  install nano php7.3 php7.3-fpm php7.3-cli php7.3-common php7.3-zip php7.3-sqlite3 php7.3-curl php7.3-simplexml
  update-alternatives --set php /usr/bin/php7.3
  sed -i "s/php7.0-fpm/php7.3-fpm/g" /etc/nginx/apps/*.conf
fi

  /usr/local/bin/swizzin/remove/tools.sh
  /usr/local/bin/swizzin/install/tools.sh

fi
