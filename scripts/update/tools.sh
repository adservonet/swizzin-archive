#! /bin/bash

#always install tools
#if [[ -d /srv/tools ]]; then

#!/bin/bash
  print_logo
  /usr/local/bin/swizzin/remove/tools.sh
  /usr/local/bin/swizzin/install/tools.sh
#fi
