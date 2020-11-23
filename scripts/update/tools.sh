#! /bin/bash

#always install tools
#if [[ -d /srv/tools ]]; then
  cat /etc/swizzin/sources/logo/logo1
  cat /etc/swizzin/sources/logo/logo1 > "${log}"  2>&1;
  /usr/local/bin/swizzin/remove/tools.sh
  /usr/local/bin/swizzin/install/tools.sh
#fi
