#!/bin/bash
# Nginx Configuration for Subsonic
# Author: liara
# Copyright (C) 2017 Swizzin
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
MASTER=$(cut -d: -f1 < /root/.master.info)

if [[ ! -f /etc/nginx/apps/subsonic.conf ]]; then
cat > /etc/nginx/apps/subsonic.conf <<SUB
location /subsonic {
  include /etc/nginx/snippets/proxy.conf;
  proxy_pass              http://127.0.0.1:18040;
}
SUB
fi
systemctl try-restart subsonic
