#! /bin/bash

#always install tools
#if [[ -d /srv/tools ]]; then
  echo "Updating tools"

  export SEEDIT_LOG=/root/logs/install.log

  waitforapt
  sudo apt update >> "${SEEDIT_LOG}"  2>&1;
  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y >> "${SEEDIT_LOG}"  2>&1;
  sudo apt upgrade -y >> "${SEEDIT_LOG}"  2>&1;
  sudo apt autoremove -y >> "${SEEDIT_LOG}"  2>&1;

  /usr/local/bin/swizzin/remove/tools.sh
  /usr/local/bin/swizzin/install/tools.sh
#fi
