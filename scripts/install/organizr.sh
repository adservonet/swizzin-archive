#!/bin/bash
#

if [[ -f /tmp/.install.lock ]]; then
  OUTTO="/root/logs/install.log"
elif [[ -f /install/.panel.lock ]]; then
  OUTTO="/srv/panel/db/output.log"
else
  OUTTO="/dev/null"
fi
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

echo "organizr Install Complete!" >>"${OUTTO}" 2>&1;
sleep 2
echo >>"${OUTTO}" 2>&1;
echo >>"${OUTTO}" 2>&1;
echo "Close this dialog box to refresh your browser" >>"${OUTTO}" 2>&1;
