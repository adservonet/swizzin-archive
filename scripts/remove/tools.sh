#!/bin/bash

#rm -rf /srv/tools
echo "/srv/tools/*.*"
rm /srv/tools/*.*

if [[ ! -d /srv/tools/vendor ]]; then
  echo "/srv/tools/vendor"
  rm -rf /srv/tools/vendor
fi

if [[ ! -f /etc/nginx/apps/tools.conf ]]; then
  echo "/etc/nginx/apps/tools.conf"
  rm -f /etc/nginx/apps/tools.conf
fi

if [[ ! -d /etc/sudoers.d/tools ]]; then
  echo "/etc/sudoers.d/tools"
  rm -f /etc/sudoers.d/tools
fi

if [[ ! -f /etc/cron.d/set_interface_tools ]]; then
  echo "/etc/cron.d/set_interface_tools"
  rm /etc/cron.d/set_interface_tools
fi

if [[ ! -f /install/.tools.lock ]]; then
  echo "/install/.tools.lock"
  rm /install/.tools.lock
fi