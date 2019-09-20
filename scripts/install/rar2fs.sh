#!/bin/bash

. /etc/swizzin/sources/functions/waitforapt.sh
waitforapt

sudo apt-get install make g++ autoconf libfuse-dev --yes
git clone https://github.com/hasse69/rar2fs.git
cd rar2fs
wget http://www.rarlab.com/rar/unrarsrc-5.4.5.tar.gz
tar -zxvf unrarsrc-5.4.5.tar.gz
cd unrar
make lib
sudo make install-lib
cd ..
autoreconf -f -i
./configure && make
sudo make install

cd /home/seedit4me
sudo mkdir rar2fsmount
cd rar2fsmount
sudo mkdir torrents

cat > /usr/local/bin/mountrar2fs.sh <<R2FS
#!/bin/bash
# script to mount rar2fs mounts

/usr/local/bin/rar2fs -o allow_other --seek-length=0 /home/seedit4me/torrents /home/seedit4me/rar2fsmount/torrents

exit 0
R2FS

sudo chmod +x /usr/local/bin/mountrar2fs.sh

cat > /etc/systemd/system/mountrar2fs.service <<R2FSSVC
[Unit]
Description=mountrar2fs
After=network.target

[Service]

Type=oneshot
ExecStartPre=/bin/sleep 30
ExecStart=/bin/bash /usr/local/bin/mountrar2fs.sh
RemainAfterExit=yes

[Install]
WantedBy=default.target
R2FSSVC

sudo systemctl --system daemon-reload
sudo systemctl enable mountrar2fs.service
sudo systemctl start mountrar2fs.service