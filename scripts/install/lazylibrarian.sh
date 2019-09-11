#!/bin/bash
#

if [[ -f /install/.tools.lock ]]; then
  OUTTO="/srv/tools/logs/output.log"
else
  OUTTO="/dev/null"
fi
MASTER=$(cut -d: -f1 < /root/.master.info)


echo "Creating lazylibrarian-tmp install directory ... " >>"${OUTTO}" 2>&1;

mkdir /srv/lazylibrarian
chown ${MASTER}: /srv/lazylibrarian


echo "Downloading lazylibrarian installing ... " >>"${OUTTO}" 2>&1;

apt-get update -y -q >>"${OUTTO}" 2>&1;
apt-get install -y -q python python-setuptools python-pip
git clone https://gitlab.com/LazyLibrarian/LazyLibrarian.git  /srv/lazylibrarian


touch /install/.lazylibrarian.lock


echo "Enabling lazylibrarian Systemd configuration" >>"${OUTTO}" 2>&1;
service stop lazylibrarian >/dev/null 2>&1
cat > /etc/systemd/system/lazylibrarian@.service <<SUBSD
[Unit]
Description=lazylibrarian
After=network.target

[Service]
Type=forking
KillMode=process
User=%I
ExecStart=/usr/bin/python /srv/lazylibrarian/LazyLibrarian.py -d
ExecStop=-/bin/kill -HUP
WorkingDirectory=/srv/lazylibrarian/

[Install]
WantedBy=multi-user.target

SUBSD



systemctl enable lazylibrarian@${MASTER}.service >/dev/null 2>&1
systemctl start lazylibrarian@${MASTER}.service >/dev/null 2>&1

if [[ -f /install/.nginx.lock ]]; then
  bash /usr/local/bin/swizzin/nginx/lazylibrarian.sh
  service nginx reload
fi

echo "lazylibrarian Install Complete!" >>"${OUTTO}" 2>&1;
sleep 2
echo >>"${OUTTO}" 2>&1;
echo >>"${OUTTO}" 2>&1;
echo "Close this dialog box to refresh your browser" >>"${OUTTO}" 2>&1;
