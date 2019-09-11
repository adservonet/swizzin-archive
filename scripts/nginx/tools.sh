#!/bin/bash
# QuickBox dashboard installer for Swizzin
# Author: liara
# Copyright (C) 2017 Swizzin
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
IFACE=$(ip link show|grep -i broadcast|grep -m1 UP|cut -d: -f 2|cut -d@ -f 1|sed -e 's/ //g');
user=$(cat /root/.master.info | cut -d: -f1)
if [[ -f /tmp/.install.lock ]]; then
  log="/root/logs/install.log"
else
  log="/dev/null"
fi

cd /srv/
mkdir tools
mkdir tools/logs
touch /srv/tools/logs/output.log

chmod -R 777 tools/logs

cp -r /usr/local/bin/swizzin/tools/php/* /srv/tools/

chown -R www-data: /srv/tools

printf "${IFACE}" > /srv/tools/interface.txt
printf "${user}" > /srv/tools/master.txt
LOCALE=en_GB.UTF-8
LANG=lang_en
echo "*/1 * * * * root bash /usr/local/bin/swizzin/tools/set_interface_tools" > /etc/cron.d/set_interface_tools

if [[ -f /lib/systemd/system/php7.3-fpm.service ]]; then
  sock=php7.3-fpm
elif [[ -f /lib/systemd/system/php7.2-fpm.service ]]; then
  sock=php7.2-fpm
elif [[ -f /lib/systemd/system/php7.1-fpm.service ]]; then
  sock=php7.1-fpm
else
  sock=php7.0-fpm
fi


cat > /etc/nginx/apps/tools.conf <<PAN
location /tools {
alias /srv/tools/ ;
try_files \$uri \$uri/ /index.php?q=\$uri&\$args;
index index.php;
allow all;

add_header 'Access-Control-Allow-Origin' '*' always;
add_header 'Access-Control-Allow-Credentials' 'true';
add_header 'Access-Control-Allow-Methods' '*';
add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization,accept,origin,X-Requested-With,X-CSRF-Token' always;
add_header 'Cache-Control' 'no-store, no-cache, must-revalidate';
#add_header 'Access-Control-Max-Age' 1728000;
#add_header 'Content-Length' 0;
add_header 'Content-Type' 'text/plain';


location ~ \.php$
  {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/$sock.sock;
    #fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME /srv\$fastcgi_script_name;
  }
}

PAN

cat > /etc/sudoers.d/tools <<SUD
#secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin/swizzin:/usr/local/bin/swizzin/scripts:/usr/local/bin/swizzin/scripts/install:/usr/local/bin/swizzin/scripts/remove:/usr/local/bin/swizzin/tools"
#Defaults  env_keep -="HOME"

# Host alias specification

# User alias specification

# Cmnd alias specification
Cmnd_Alias   S4CLEANMEM = /usr/local/bin/swizzin/tools/clean_mem
Cmnd_Alias   S4GENERALCMNDS = /usr/sbin/repquota, /bin/systemctl

www-data     ALL = (ALL) NOPASSWD: S4CLEANMEM, S4GENERALCMNDS

SUD
service nginx force-reload

