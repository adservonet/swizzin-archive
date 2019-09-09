#!/bin/bash

MASTER=$(cut -d: -f1 < /root/.master.info)

systemctl stop lazylibrarian@${MASTER}.service >/dev/null 2>&1
systemctl disable lazylibrarian@${MASTER}.service >/dev/null 2>&1

rm /etc/systemd/system/lazylibrarian.service

rm -rf /srv/lazylibrarian
rm -rf /etc/nginx/apps/lazylibrarian.conf
rm /install/.lazylibrarian.lock

