#! /bin/bash

if [[ -d /srv/tools ]]; then
  echo "Updating tools"

  bash /usr/local/bin/swizzin/remove/tools.sh
  bash /usr/local/bin/swizzin/install/tools.sh

fi
