#!/bin/bash

function update_nginx() {
    codename=$(lsb_release -cs)

    if [[ $codename =~ ("xenial"|"stretch") ]]; then
        mcrypt=php-mcrypt
    else
        mcrypt=
    fi

    #Deprecate nginx-extras in favour of installing fancyindex alone
    # (unless you use xenial)
    if [[ ! $codename == "xenial" ]]; then
        if dpkg -s nginx-extras > /dev/null 2>&1; then
            apt_remove nginx-extras
            apt_install nginx libnginx-mod-http-fancyindex
            apt_autoremove
            rm $(ls -d /etc/nginx/modules-enabled/*.removed)
            systemctl reload nginx
        fi
    fi

#    LIST="php7.4-fpm php7.4-cli php7.4-dev php7.4-xml php7.4-curl php7.4-xmlrpc php7.4-json php7.4-mcrypt php7.4-mbstring php7.4-opcache php7.4-geoip php7.4-xml php7.4-zip"
#
#    missing=()
#    for dep in $LIST; do
#        if ! check_installed "$dep"; then
#            missing+=("$dep")
#        fi
#    done
#
#    if [[ ${missing[1]} != "" ]]; then
#        # echo_inf "Installing the following dependencies: ${missing[*]}" | tee -a $log
#        apt_install "${missing[@]}"
#    fi
#
#    cd /etc/php
#    phpv=$(ls -d */ | cut -d/ -f1)
#    if [[ $phpv =~ 7\\.1 ]]; then
#        if [[ $phpv =~ 7\\.0 ]]; then
#            apt_remove purge php7.0-fpm
#        fi
#    fi

    INSTALL="fpm cli dev xml curl xmlrpc json mcrypt mbstring opcache geoip zip";
    for x in $INSTALL; do
      if ! check_installed "php7.4-$x"; then
        echo "installing php7.4-$x";
        apt_install "php7.4-$x";
      fi
    done

    OPT="common gd mysql sqlite3"
    for x in $OPT; do
      if check_installed "php-$x"; then
        echo "installing php7.4-$x";
        apt_install "php7.4-$x";
      fi
      if check_installed "php8.0-$x"; then
        echo "installing php7.4-$x";
        apt_install "php7.4-$x";
      fi
    done

    PURGE="7.0 7.1 7.2 7.3 8.0";
    for ver in $PURGE; do
        if check_installed "php$ver-fpm"; then
          echo "purging php$ver*";
          apt_remove --purge "php$ver*";
          rm -rf "/etc/php/$ver";
        fi
        if check_installed "php$ver-cli"; then
          echo "purging php$ver*";
          apt_remove --purge "php$ver*";
          rm -rf "/etc/php/$ver";
        fi
    done;


    if [[ $phpversion != "7.4" ]]; then
      echo "wrong php version: $phpversion cleaning up";
      sudo update-alternatives --set php /usr/bin/php7.4;
    fi

    . /etc/swizzin/sources/functions/php
    phpversion=$(php_service_version)
    sock="php${phpversion}-fpm"


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

    if [[ ! -f /etc/nginx/modules-enabled/50-mod-http-fancyindex.conf ]]; then
        mkdir -p /etc/nginx/modules-enabled/
        ln -s /usr/share/nginx/modules-available/mod-http-fancyindex.conf /etc/nginx/modules-enabled/50-mod-http-fancyindex.conf
    fi

    phpversion=$(php_service_version)

    fcgis=($(find /etc/nginx -type f -exec grep -l "fastcgi_pass unix:/run/php/" {} \;))
    err=()
    for f in ${fcgis[@]}; do
        err+=($(grep -L "fastcgi_pass unix:/run/php/php${phpversion}-fpm.sock" $f))
    done
    for fix in ${err[@]}; do
        sed -i "s/fastcgi_pass .*/fastcgi_pass unix:\/run\/php\/php${phpversion}-fpm.sock;/g" $fix
    done

    if grep -q -e "-dark" -e "Nginx-Fancyindex" /srv/fancyindex/header.html; then
        sed -i 's/href="\/[^\/]*/href="\/fancyindex/g' /srv/fancyindex/header.html
    fi

    if grep -q "Nginx-Fancyindex" /srv/fancyindex/footer.html; then
        sed -i 's/src="\/[^\/]*/src="\/fancyindex/g' /srv/fancyindex/footer.html
    fi

    if [[ -f /install/.rutorrent.lock ]]; then
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
    fi

    if [[ -f /install/.deluge.lock ]]; then
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
    fi

    # Remove php directive at the root level since we no longer use php
    # on root and we define php manually for nested locations
    if grep -q '\.php\$' /etc/nginx/sites-enabled/default; then
        sed -i -e '/location ~ \\.php$ {/,/}/d' /etc/nginx/sites-enabled/default
    fi

    if grep -q 'index.html' /etc/nginx/sites-enabled/default; then
        sed -i '/index.html/d' /etc/nginx/sites-enabled/default
    fi

# we will do this in tools update
#    . /etc/swizzin/sources/functions/php
#    restart_php_fpm
#    systemctl reload nginx
}

if [[ -f /install/.nginx.lock ]]; then update_nginx; fi
