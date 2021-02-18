#! /bin/bash

#always install tools
#if [[ -d /srv/tools ]]; then
  echo "Updating tools"


   waitforapt
   sudo apt update
   sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y;
   sudo apt upgrade -y
   sudo apt autoremove

  /usr/local/bin/swizzin/remove/tools.sh
  /usr/local/bin/swizzin/install/tools.sh
#fi
