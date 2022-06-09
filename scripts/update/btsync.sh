#!/bin/bash
if [[ -f /install/.btsync.lock ]]; then

    if [[ ! -f /etc/nginx/apps/btsync.conf ]]; then
        if [[ -f /install/.nginx.lock ]]; then
            echo_progress_start "nginx not yet configured for btsync"
            sleep 3
            bash /usr/local/bin/swizzin/nginx/btsync.sh
            systemctl reload nginx
            systemctl restart resilo-sync
            echo_progress_done "nginx configured"
        fi
    fi


    if [[ ! -f /etc/systemd/system/resilio-sync.service ]]; then
        active=$(systemctl is-active resilo-sync)
        if [[ $active == "active" ]]; then
            systemctl stop resilo-sync
        fi
        MASTER=$(cut -d: -f1 < /root/.master.info)
        BTSYNCIP=$(ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p')
        cat > /etc/resilio-sync/config.json << RSCONF
{
    "listening_port" : 0,
    "storage_path" : "/home/${MASTER}/.config/resilio-sync/",
    "pid_file" : "/var/run/resilio-sync/sync.pid",
    "agree_to_EULA": "yes",

    "webui" :
    {
        "listen" : "BTSGUIP:8888"
    }
}
RSCONF
        cp -a /lib/systemd/system/resilio-sync.service /etc/systemd/system/
        sed -i "s/=rslsync/=${MASTER}/g" /etc/systemd/system/resilio-sync.service
        sed -i "s/rslsync:rslsync/${MASTER}:${MASTER}/g" /etc/systemd/system/resilio-sync.service
        systemctl daemon-reload
        sed -i "s/BTSGUIP/$BTSYNCIP/g" /etc/resilio-sync/config.json
        if [[ $active == "active" ]]; then
            systemctl start resilio-sync
        fi
    fi
fi
