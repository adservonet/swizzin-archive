#!/bin/bash
# proftpd installer
# Author: Nobody
# Copyright (C) 2017 Nobody
# Licensed under DWYW (Do Whatever you want).
#
#   You may copy, distribute and modify the software.

log="/install/.proftpd.log"

#. /etc/swizzin/sources/functions/waitforapt.sh
waitforapt

apt remove vsftpd -y

waitforapt

apt install debconf-utils -y  >>  "${SEEDIT_LOG}"  2>&1
echo "proftpd-basic shared/proftpd/inetd_or_standalone select standalone" | debconf-set-selections  >>  "${SEEDIT_LOG}"  2>&1

waitforapt
apt install proftpd-basic -y  >>  "${SEEDIT_LOG}"  2>&1


cat > /etc/proftpd/proftpd.conf <<PFC

Include /etc/proftpd/modules.conf

### ECM CUSTOM ###
PassivePorts            %%%PASSIVE PORTS%%%
MasqueradeAddress		%%%MASQ ADDR%%%
AllowForeignAddress		on
RequireValidShell		off
Port				21
### ECM CUSTOM ###

UseIPv6				on
IdentLookups			off
ServerName			"Debian"
ServerType			standalone
DeferWelcome			off
MultilineRFC2228		on
DefaultServer			on
ShowSymlinks			on
TimeoutNoTransfer		600
TimeoutStalled			600
TimeoutIdle			1200
TLSRenegotiate none
DisplayLogin                    welcome.msg
DisplayChdir               	.message true
ListOptions                	"-l"
DenyFilter			\*.*/
<IfModule mod_dynmasq.c>
# DynMasqRefresh 28800
</IfModule>
MaxInstances			30
User				proftpd
Group				nogroup
Umask				022  022
AllowOverwrite			on
AllowStoreRestart on
AllowRetrieveRestart on
AuthOrder			mod_auth_pam.c* mod_auth_unix.c
TransferLog /var/log/proftpd/xferlog
SystemLog   /var/log/proftpd/proftpd.log
<IfModule mod_quotatab.c>
QuotaEngine off
</IfModule>
<IfModule mod_ratio.c>
Ratios off
</IfModule>
<IfModule mod_delay.c>
DelayEngine on
</IfModule>

<IfModule mod_ctrls.c>
ControlsEngine        off
ControlsMaxClients    2
ControlsLog           /var/log/proftpd/controls.log
ControlsInterval      5
ControlsSocket        /var/run/proftpd/proftpd.sock
</IfModule>
<IfModule mod_ctrls_admin.c>
AdminControlsEngine off
</IfModule>
Include /etc/proftpd/conf.d/

PFC

waitforapt
apt install -y openssl

echo 'DefaultRoot ~' >> /etc/proftpd/proftpd.conf

echo 'ServerIdent on "FTP Server ready."' >> /etc/proftpd/proftpd.conf

mkdir /etc/proftpd/ssl

#Required
domain='ftp.seedit4.me'
commonname=$domain

#Change to your company details
country=GB
state=Nottingham
locality=Nottinghamshire
organization='SeedIt4Me'
organizationalunit=IT
email=support@seedit4.me

openssl req -new -x509 -days 365 -nodes -out /etc/proftpd/ssl/proftpd.cert.pem -keyout /etc/proftpd/ssl/proftpd.key.pem -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"

chmod 600 /etc/proftpd/ssl/proftpd.*

echo 'Include /etc/proftpd/tls.conf' >> /etc/proftpd/proftpd.conf
echo '<IfModule mod_tls.c>' > /etc/proftpd/tls.conf
echo 'TLSEngine on' >> /etc/proftpd/tls.conf
echo 'TLSLog /var/log/proftpd/tls.log' >> /etc/proftpd/tls.conf
echo 'TLSProtocol TLSv1.2' >> /etc/proftpd/tls.conf
echo 'TLSCipherSuite AES128+EECDH:AES128+EDH' >> /etc/proftpd/tls.conf
echo 'TLSOptions NoCertRequest AllowClientRenegotiations' >> /etc/proftpd/tls.conf
echo 'TLSRSACertificateFile /etc/proftpd/ssl/proftpd.cert.pem' >> /etc/proftpd/tls.conf
echo 'TLSRSACertificateKeyFile /etc/proftpd/ssl/proftpd.key.pem' >> /etc/proftpd/tls.conf
echo 'TLSVerifyClient off' >> /etc/proftpd/tls.conf
echo 'TLSRequired off' >> /etc/proftpd/tls.conf
echo 'RequireValidShell no' >> /etc/proftpd/tls.conf
echo '</IfModule>' >> /etc/proftpd/tls.conf
systemctl restart proftpd.service

touch /install/.proftpd.lock
