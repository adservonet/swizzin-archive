#! /bin/bash

#always install tools
#if [[ -d /srv/tools ]]; then

#!/bin/bash
input="/etc/swizzin/sources/logo/logo1"
while IFS= read -r line; do
	colorprint "${green}${bold} $line"
done < "$input"
/usr/local/bin/swizzin/remove/tools.sh
/usr/local/bin/swizzin/install/tools.sh
#fi
