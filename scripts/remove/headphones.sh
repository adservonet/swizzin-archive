#!/bin/bash
#if [[ -f /tmp/.install.lock ]]; then
#  OUTTO="/root/logs/install.log"
#else
#  OUTTO="/root/logs/swizzin.log"
#fi
USERNAME=$(cut -d: -f1 < /root/.master.info)
APPNAME='headphones'
APPPATH='/home/'$USERNAME'/.headphones'
APPTITLE='Headphones'

echo
sleep 1
# for output to box
echo -e "Disabling and stopping $APPTITLE ..."
# for output to dashboard
echo -e "Disabling and stopping $APPTITLE ..." >> "${log}"  2>&1;
systemctl disable $APPNAME
systemctl stop $APPNAME

# for output to box
echo -e "Removing service and configuration files for $APPTITLE ..."
# for output to dashboard
echo -e "Removing service and configuration files for $APPTITLE ..." >> "${log}"  2>&1;
rm /etc/systemd/system/$APPNAME.service
rm -f /etc/nginx/apps/$APPNAME.conf
rm -rf /etc/default/$APPNAME
rm -rf $APPPATH

# for output to box
echo -e "Removing $APPTITLE lock file ..."
# for output to dashboard
echo -e "Removing $APPTITLE lock file ..." >> "${log}"  2>&1;
rm -f /install/.$APPNAME.lock

# for output to box
echo -e "Reloading nginx ..."
# for output to dashboard
echo -e "Reloading nginx ..." >> "${log}"  2>&1;
service nginx reload

# for output to box
echo "$APPTITLE has been removed"
echo
echo
# for output to dashboard
echo "$APPTITLE has been removed" >> "${log}"  2>&1;
echo >> "${log}"  2>&1;
echo >> "${log}"  2>&1;
