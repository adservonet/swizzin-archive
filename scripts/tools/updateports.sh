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
