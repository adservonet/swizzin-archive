
app="rtorrent"
if [[ -f /install/.$app.lock ]]; then
  echo_info "updating ports for ${app}."
  user=$(cut -d: -f1 < /root/.master.info)
  port=$(cat /home/seedit4me/.rtorrent_port)
  portend=$(cat /home/seedit4me/.rtorrent_port)
  sed -i "s/network.port_range.set.*/network.port_range.set = ${port}-${portend}/g" /home/${user}/.rtorrent.rc
  echo_success "${app} ports updated."
fi
