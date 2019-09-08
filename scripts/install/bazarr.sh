#!/bin/bash
user=$(cut -d: -f1 < /root/.master.info )
apt-get -y -q install python-pip > /dev/null 2>&1
cd /home/${user}
echo "Cloning into 'bazarr'"
git clone https://github.com/morpheus65535/bazarr.git > /dev/null 2>&1
chown -R ${user}: bazarr
cd bazarr
echo "Checking python depends"
sudo -u ${user} bash -c "pip install --user -r requirements.txt" > /dev/null 2>&1

cat > /etc/systemd/system/bazarr.service <<BAZ
[Unit]
Description=Bazarr for ${user}
After=syslog.target network.target

[Service]
WorkingDirectory=/home/${user}/bazarr
User=${user}
Group=${user}
UMask=0002
Restart=on-failure
RestartSec=5
Type=simple
ExecStart=/usr/bin/python /home/${user}/bazarr/bazarr.py
KillSignal=SIGINT
TimeoutStopSec=20
SyslogIdentifier=bazarr.${user}

[Install]
WantedBy=multi-user.target
BAZ

systemctl enable --now bazarr

if [[ -f /install/.nginx.lock ]]; then
    sleep 10
    bash /usr/local/bin/swizzin/nginx/bazarr.sh
    service nginx reload
fi

touch /install/.bazarr.lock