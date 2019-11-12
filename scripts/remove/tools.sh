#!/bin/bash

#rm -rf /srv/tools
rm /srv/tools/*.*
rm -rf /srv/tools/vendor

rm -f /etc/nginx/apps/tools.conf
rm -f /etc/sudoers.d/tools
rm /etc/cron.d/set_interface_tools
rm /install/.tools.lock
