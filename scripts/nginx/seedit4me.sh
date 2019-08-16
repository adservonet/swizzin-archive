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
mkdir seedit4me
cp /usr/local/bin/swizzin/seedit4me/php/* /srv/seedit4me/

chown -R www-data: /srv/seedit4me

printf "${IFACE}" > /srv/seedit4me/interface.txt
printf "${user}" > /srv/seedit4me/master.txt
LOCALE=en_GB.UTF-8
LANG=lang_en
echo "*/1 * * * * root bash /usr/local/bin/swizzin/seedit4me/set_interface_seedit4me" > /etc/cron.d/set_interface_seedit4me

if [[ -f /lib/systemd/system/php7.2-fpm.service ]]; then
  sock=php7.2-fpm
elif [[ -f /lib/systemd/system/php7.1-fpm.service ]]; then
  sock=php7.1-fpm
else
  sock=php7.0-fpm
fi

cat > /etc/nginx/apps/seedit4me.conf <<PAN
location /seedit4me {
alias /srv/seedit4me/ ;
try_files \$uri \$uri/ /index.php?q=\$uri&\$args;
index index.php;
allow all;
location ~ \.php$
  {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/$sock.sock;
    #fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME /srv\$fastcgi_script_name;
  }
}

PAN

cat > /etc/sudoers.d/seedit4me <<SUD
#secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin/swizzin:/usr/local/bin/swizzin/scripts:/usr/local/bin/swizzin/scripts/install:/usr/local/bin/swizzin/scripts/remove:/usr/local/bin/swizzin/seedit4me"
#Defaults  env_keep -="HOME"

# Host alias specification

# User alias specification

# Cmnd alias specification
Cmnd_Alias   S4CLEANMEM = /usr/local/bin/swizzin/seedit4me/clean_mem
Cmnd_Alias   S4GENERALCMNDS = /usr/sbin/repquota, /bin/systemctl

www-data     ALL = (ALL) NOPASSWD: S4CLEANMEM, S4GENERALCMNDS

SUD
service nginx force-reload

