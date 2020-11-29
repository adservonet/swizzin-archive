#!/bin/bash

function update_nginx() {
	codename=$(lsb_release -cs)
	#if [[ -f /tmp/.install.lock ]]; then
	#  log="/root/logs/install.log"
	#else
	#  log="/dev/null"
	#fi
	#
	#if [[ $codename == "jessie" ]]; then
	#  geoip=php7.0-geoip
	#else
	#  geoip=php-geoip
	#fi
	#
	#
	#if [[ $codename == "bionic" ]]; then
	#  mcrypt=
	#else
	#  mcrypt=php-mcrypt
	#fi

	#  #LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
	#  #sudo dpkg --configure -a
	#  #apt-get -y -f install
	#apt-get -y -qq update > /dev/null  2>&1
	APT='php7.3-fpm php7.3-common php7.3-cli php7.3-dev php7.3-xml php7.3-curl php7.3-xmlrpc php7.3-json php7.3-mbstring php7.3-opcache php-geoip php7.3-xml php7.3-gd php7.3-sqlite3 php7.3-zip'
	#for depends in $APT; do
	#    apt-get -y install "$depends" >>  "${log}"  2>&1
	#done

	cd /etc/php
	phpv=$(ls -d */ | cut -d/ -f1)

	#  sudo apt-get -y -q  purge php7.0.*
	#  sudo apt-get -y -q  purge php7.1.*
	#  sudo apt-get -y -q  purge php7.2.*
	#  sudo apt-get -y -q  purge php7.4.*
	#  sudo dpkg --remove --force-remove-reinstreq php-mcrypt
	#  apt-get -y -q install libmcrypt-dev
	#  #pear config-set php_dir /usr/bin/php
	#  pear config-set ext_dir /usr/lib/php/20180731
	#  pear config-set php_bin /usr/bin/php7.3
	#  pear config-set php_suffix 7.3
	#  pear config-set php_ini /etc/php/7.3/fpm/php.ini
	#  printf "\n" | pecl install mcrypt-1.0.2
	#  echo extension=mcrypt.so > /etc/php/7.3/mods-available/mcrypt.ini
	#  echo extension=mcrypt.so > /etc/php/7.3/fpm/conf.d/20-mcrypt.ini
	#  echo extension=mcrypt.so > /etc/php/7.3/cli/conf.d/20-mcrypt.ini
	#  #systemctl restart php7.3-fpm
	#  sudo update-alternatives --set php /usr/bin/php7.3
	#
	#  sed -i "s/php7.0-fpm/php7.3-fpm/g" /etc/nginx/apps/*.conf

	if [[ -f /lib/systemd/system/php7.3-fpm.service ]]; then
		sock=php7.3-fpm
	elif [[ -f /lib/systemd/system/php7.2-fpm.service ]]; then
		sock=php7.2-fpm
	elif [[ -f /lib/systemd/system/php7.1-fpm.service ]]; then
		sock=php7.1-fpm
	else
		sock=php7.0-fpm
	fi

	for version in $phpv; do
		if [[ -f /etc/php/$version/fpm/php.ini ]]; then
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
		fi
	done

	if [[ -f /lib/systemd/system/php7.3-fpm.service ]]; then
		v=$(find /etc/nginx -type f -exec grep -l "fastcgi_pass unix:/run/php/php7.3-fpm.sock" {} \;)
		if [[ -z $v ]]; then
			oldv=$(find /etc/nginx -type f -exec grep -l "fastcgi_pass unix:/run/php/" {} \;)
			for upgrade in $oldv; do
				sed -i 's/fastcgi_pass .*/fastcgi_pass unix:\/run\/php\/php7.3-fpm.sock;/g' $upgrade
			done
		fi
	elif [[ -f /lib/systemd/system/php7.2-fpm.service ]]; then
		v=$(find /etc/nginx -type f -exec grep -l "fastcgi_pass unix:/run/php/php7.2-fpm.sock" {} \;)
		if [[ -z $v ]]; then
			oldv=$(find /etc/nginx -type f -exec grep -l "fastcgi_pass unix:/run/php/" {} \;)
			for upgrade in $oldv; do
				sed -i 's/fastcgi_pass .*/fastcgi_pass unix:\/run\/php\/php7.2-fpm.sock;/g' $upgrade
			done
		fi
	elif [[ -f /lib/systemd/system/php7.1-fpm.service ]]; then
		v=$(find /etc/nginx -type f -exec grep -l "fastcgi_pass unix:/run/php/php7.1-fpm.sock" {} \;)
		if [[ -z $v ]]; then
			oldv=$(find /etc/nginx -type f -exec grep -l "fastcgi_pass unix:/run/php/" {} \;)
			for upgrade in $oldv; do
				sed -i 's/fastcgi_pass .*/fastcgi_pass unix:\/run\/php\/php7.1-fpm.sock;/g' $upgrade
			done
		fi
	fi

	if grep -q -e "-dark" -e "Nginx-Fancyindex" /srv/fancyindex/header.html; then
		sed -i 's/href="\/[^\/]*/href="\/fancyindex/g' /srv/fancyindex/header.html
	fi

	if grep -q "Nginx-Fancyindex" /srv/fancyindex/footer.html; then
		sed -i 's/src="\/[^\/]*/src="\/fancyindex/g' /srv/fancyindex/footer.html
	fi

	if grep -q "php" /etc/nginx/apps/rindex.conf; then
		:
	else
		cat > /etc/nginx/apps/rindex.conf << EOR
location /rtorrent.downloads {
  alias /home/\$remote_user/torrents/rtorrent;
  include /etc/nginx/snippets/fancyindex.conf;
  auth_basic "What's the password?";
  auth_basic_user_file /etc/htpasswd;
  
  location ~* \.php$ {

  } 
}
EOR
	fi

	echo "UPDATING client_max_body_size"

	cat > /etc/nginx/snippets/proxy.conf << PROX
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

	if grep -q "php" /etc/nginx/apps/dindex.conf; then
		:
	else
		cat > /etc/nginx/apps/dindex.conf << DIN
location /deluge.downloads {
  alias /home/\$remote_user/torrents/deluge;
  include /etc/nginx/snippets/fancyindex.conf;
  auth_basic "What's the password?";
  auth_basic_user_file /etc/htpasswd;

  location ~* \.php$ {

  } 
}
DIN
	fi

	. /etc/swizzin/sources/functions/php
	restart_php_fpm
	systemctl reload nginx
}

if [[ -f /install/.nginx.lock ]]; then update_nginx; fi
