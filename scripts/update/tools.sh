#! /bin/bash

#always install tools
#if [[ -d /srv/tools ]]; then
  echo "Updating tools"

  apt_upgrade;

  /usr/local/bin/swizzin/remove/tools.sh
  /usr/local/bin/swizzin/install/tools.sh
#fi
