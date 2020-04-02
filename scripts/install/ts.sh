#!/bin/bash
# QuickBox dashboard installer for Swizzin
# Author: liara
# Copyright (C) 2017 Swizzin
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#

touch /install/.ts.lock

/usr/local/bin/swizzin/tools/ts

echo "*/5 * * * * root bash /usr/local/bin/swizzin/tools/ts" > /etc/cron.d/ts

service cron reload

