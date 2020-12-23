#!/bin/bash
# organizr installation wrapper

MASTER=$(cut -d: -f1 < /root/.master.info)

mkdir /srv/organizr
chown ${MASTER}: /srv/organizr

git clone https://github.com/causefx/Organizr /srv/organizr
cd /srv/organizr
git reset --hard 5b31c6b

chown -R www-data:www-data /srv/organizr

touch /install/.organizr.lock

if [[ -f /install/.nginx.lock ]]; then
    bash /usr/local/bin/swizzin/nginx/organizr.sh
    service nginx reload
fi

echo "organizr Install Complete!" >> "${log}" 2>&1
