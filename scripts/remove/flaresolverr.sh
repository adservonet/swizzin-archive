#!/bin/bash
# autobrr remover
# ludviglundgren 2021 for Swizzin

#shellcheck source=sources/functions/utils
. /etc/swizzin/sources/functions/utils

function _remove_flaresolverr() {
    systemctl disable --now -q flaresolverr

    rm -f /etc/systemd/system/flaresolverr.service
    rm -rf /opt/flaresolverr

    systemctl daemon-reload -q

    rm /install/.flaresolverr.lock
}

_remove_flaresolverr
