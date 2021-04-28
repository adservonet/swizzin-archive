#!/bin/bash
user=$(cut -d: -f1 < /root/.master.info)

app="rtorrent"
if [[ -f /install/.$app.lock ]]; then
  echo_info "updating ports for ${app}."
  port=$(cat /home/seedit4me/.rtorrent_port)
  portend=$(cat /home/seedit4me/.rtorrent_port)
  sed -i "s/network.port_range.set.*/network.port_range.set = ${port}-${portend}/g" /home/${user}/.rtorrent.rc
  systemctl restart rtorrent@${user}
  echo_success "${app} ports updated."
fi

app="transmission"
if [[ -f /install/.$app.lock ]]; then
  echo_info "updating ports for ${app}."
  port=$(cat /home/seedit4me/.transmission_port)

  . /etc/swizzin/sources/functions/transmission
  [[ -z $peer_port ]] && export peer_port=$(_get_next_port_from_json 'peer-port' $port)
  echo_info "peer_port = $peer_port"
  sed -i "s/\"peer-port\":.*/\"peer-port\": ${peer_port},/g" /home/${user}/.config/transmission-daemon/settings.json
  sed -i "s/\"peer-port-random-high\":.*/\"peer-port-random-high\": ${peer_port},/g" /home/${user}/.config/transmission-daemon/settings.json
  sed -i "s/\"peer-port-random-low\":.*/\"peer-port-random-low\": ${peer_port},/g" /home/${user}/.config/transmission-daemon/settings.json
  systemctl restart transmission@${user}
  echo_success "${app} ports updated."
fi

app="qbittorrent"
if [[ -f /install/.$app.lock ]]; then
  echo_info "updating ports for ${app}."
  xport=$(cat /home/seedit4me/.qbittorrent_port)
  sed -i "s/Connection\PortRangeMin.*/Connection\PortRangeMin=${xport}/g" /home/${user}/.config/qBittorrent/qBittorrent.conf
  systemctl restart qbittorrent@${user}
  echo_success "${app} ports updated."
fi

app="btsync"
if [[ -f /install/.$app.lock ]]; then
  echo_info "updating ports for ${app}."
  port=$(cat /home/seedit4me/.btsync_port)
  port2=$(cat /home/seedit4me/.btsync2_port)
  sed -i "s/\"listen\" : \"0.0.0.0:.*/\"listen\" : \"0.0.0.0:${port}\"/g" /etc/resilio-sync/config.json
  sed -i "s/\"listening_port\" : .*/\"listening_port\" : ${port2},/g" /etc/resilio-sync/config.json
  systemctl restart resilio-sync
  echo_success "${app} ports updated."
fi
