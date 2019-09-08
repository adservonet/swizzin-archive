#! /bin/bash

if [[ -d /srv/tools ]]; then
  echo "Updating tools"
  cp -r /usr/local/bin/swizzin/tools/php/* /srv/tools/

  chown -R www-data: /srv/tools
  restart_php_fpm
  systemctl restart nginx
fi