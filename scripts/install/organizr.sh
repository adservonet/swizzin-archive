#!/bin/bash
#

#if [[ -f /install/.tools.lock ]]; then
#  log="/srv/tools/logs/output.log"
#else
#  log="/dev/null"
#fi
MASTER=$(cut -d: -f1 < /root/.master.info)


mkdir /srv/organizr
chown ${MASTER}: /srv/organizr

git clone https://github.com/causefx/Organizr /srv/organizr

chown -R www-data:www-data /srv/organizr

touch /install/.organizr.lock

if [[ -f /install/.nginx.lock ]]; then
  bash /usr/local/bin/swizzin/nginx/organizr.sh
  service nginx reload
fi

echo "organizr Install Complete!" >> "${SEEDIT_LOG}"  2>&1;
