#! /bin/bash

#always install tools
#if [[ -d /srv/tools ]]; then
  echo_info  /etc/swizzin/sources/logo/logo1
  echo_info  /etc/swizzin/sources/logo/logo1 > "${log}"  2>&1;
  /usr/local/bin/swizzin/remove/tools.sh
  /usr/local/bin/swizzin/install/tools.sh
#fi
