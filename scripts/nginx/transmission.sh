#!/bin/bash
# nginx setup for transmission
# by liara for swizzin
# copyright 2020 swizzin.ltd

users=($(cut -d: -f1 < /etc/htpasswd))

apt_install jq

if [[ ! -f /etc/nginx/apps/transmission.conf ]]; then
    cat > /etc/nginx/apps/transmission.conf <<TCONF
location /transmission {
    return 301 /transmission/web/;
}

location /transmission/ {
    include /etc/nginx/snippets/proxy.conf;

    proxy_pass_header  X-Transmission-Session-Id;
    proxy_set_header   X-Forwarded-Host   \$host;
    proxy_set_header   X-Forwarded-Server \$host;
    proxy_set_header   X-Forwarded-For    \$proxy_add_x_forwarded_for;

    proxy_pass        http://127.0.0.1:9091/transmission/web;
    auth_basic "What's the password?";
    auth_basic_user_file /etc/htpasswd.d/htpasswd.${MASTER};
}

location /rpc {
    proxy_pass_header  X-Transmission-Session-Id;
    proxy_pass         http://127.0.0.1:9091/transmission/rpc;
}

location /upload {
    proxy_pass_header  X-Transmission-Session-Id;
    proxy_pass         http://127.0.0.1:9091/transmission/upload;
}

TCONF
fi

#for u in ${users[@]}; do
#    active=$(systemctl is-active transmission@$u)
#    if [[ $active == "active" ]]; then
#        systemctl stop transmission@${u}
#    fi
#
#    timeout=0
#    while systemctl is-active transmission@"$u" > /dev/null ;do
#        # echo "is active"
#        timeout+=0.3
#        if [[ $timeout -ge 20 ]]; then
#            echo "The service transmission@$u took too long to shut down. Aborting."
#            exit 1
#        fi
#        sleep 0.3
#    done
#
#    confpath="/home/${u}/.config/transmission-daemon/settings.json"
#    jq '.["rpc-bind-address"] = "127.0.0.1"' "$confpath" >> /root/logs/swizzin.log
#    RPCPORT=$(jq -r '.["rpc-port"]' < "$confpath")
#    echo "RPC-port = $RPCPORT"
#    if [[ ! -f /etc/nginx/conf.d/${u}.transmission.conf ]]; then
#        cat > /etc/nginx/conf.d/${u}.transmission.conf <<TDCONF
#upstream ${u}.transmission {
#    server 127.0.0.1:${RPCPORT};
#}
#TDCONF
#    fi
#    if [[ $active == "active" ]]; then
#        systemctl start transmission@${u}
#fi
#done

