#!/bin/bash
# proftpd installer
# Author: Nobody
# Copyright (C) 2017 Nobody
# Licensed under DWYW (Do Whatever you want).
#
#   You may copy, distribute and modify the software.

log="/install/.proftpd.log"

apt remove vsftpd -y

apt install debconf-utils -y  >> $log 2>&1
echo "proftpd-basic shared/proftpd/inetd_or_standalone select standalone" | debconf-set-selections  >> $log 2>&1
apt install proftpd-basic -y  >> $log 2>&1


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

touch /install/.proftpd.lock
