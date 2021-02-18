#! /bin/bash

#always install tools
echo "Updating tools"

#if type apt_upgrade | grep -q '^function$' 2>/dev/null; then
#    apt_upgrade
#else
#  waitforapt
#  sudo apt update >> "${SEEDIT_LOG}"  2>&1;
#  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y >> "${SEEDIT_LOG}"  2>&1;
#  sudo apt upgrade -y >> "${SEEDIT_LOG}"  2>&1;
#  sudo apt autoremove -y >> "${SEEDIT_LOG}"  2>&1;
#fi

/usr/local/bin/swizzin/remove/tools.sh
/usr/local/bin/swizzin/install/tools.sh
