#!/bin/bash
#################################################################################
# Installation script for swizzin
# Many credits to QuickBox for the package repo
#
# Package installers copyright QuickBox.io (2017) where applicable.
# All other work copyright Swizzin (2017)
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
#################################################################################

time=$(date +"%s")

if [[ $EUID -ne 0 ]]; then
  echo "Swizzin setup requires user to be root. su or sudo -s and run again ..."
  exit 1
fi

_os() {
  if [ ! -d /install ]; then mkdir /install ; fi
  if [ ! -d /root/logs ]; then mkdir /root/logs ; fi
  export log=/root/logs/install.log
  apt-get -y -qq update >> ${log} 2>&1
  apt-get -y -qq install lsb-release >> ${log} 2>&1
  distribution=$(lsb_release -is)
  release=$(lsb_release -rs)
  codename=$(lsb_release -cs)
}

function _preparation() {
  if [[ $distribution = "Ubuntu" ]]; then
    if [[ -z $(which add-apt-repository) ]]; then
      apt-get install -y -q software-properties-common >> ${log} 2>&1
    fi
    add-apt-repository universe >> ${log} 2>&1
    add-apt-repository multiverse >> ${log} 2>&1
    add-apt-repository restricted -u >> ${log} 2>&1
  fi
  apt-get -q -y update >> ${log} 2>&1
  apt-get -q -y upgrade >> ${log} 2>&1
apt-get -q -y install git sudo curl wget lsof fail2ban apache2-utils vnstat tcl tcl-dev build-essential dirmngr apt-transport-https python-pip >> ${log} 2>&1
  nofile=$(grep "DefaultLimitNOFILE=500000" /etc/systemd/system.conf)
  if [[ ! "$nofile" ]]; then echo "DefaultLimitNOFILE=500000" >> /etc/systemd/system.conf; fi
  git clone https://github.com/illnesse/swizzin.git /etc/swizzin >> ${log} 2>&1
  ln -s /etc/swizzin/scripts/ /usr/local/bin/swizzin
  chmod -R 700 /etc/swizzin/scripts
}

function _nukeovh() {
  grsec=$(uname -a | grep -i grs)
  if [[ -n $grsec ]]; then
    if [[ $DISTRO == Ubuntu ]]; then
      apt-get install -q -y linux-image-generic >>"${OUTTO}" 2>&1
    elif [[ $DISTRO == Debian ]]; then
      arch=$(uname -m)
      if [[ $arch =~ ("i686"|"i386") ]]; then
        apt-get install -q -y linux-image-686 >>"${OUTTO}" 2>&1
      elif [[ $arch == x86_64 ]]; then
        apt-get install -q -y linux-image-amd64 >>"${OUTTO}" 2>&1
      fi
    fi
    mv /etc/grub.d/06_OVHkernel /etc/grub.d/25_OVHkernel
    update-grub >>"${OUTTO}" 2>&1
  fi
}

function _skel() {
  rm -rf /etc/skel
  cp -R /etc/swizzin/sources/skel /etc/skel
}

function _intro() {
  whiptail --title "Swizzin seedbox installer" --msgbox "Yo, what's up? Let's install this swiz." 15 50
}

function _adduser() {
  while [[ -z $user ]]; do
    user='seedbox'
  done
  while [[ -z "${pass}" ]]; do
    pass='letmein123'
  done
  echo "$user:$pass" > /root/.master.info
  if [[ -d /home/"$user" ]]; then
    #_skel
    #cd /etc/skel
    #cp -R * /home/$user/
    chpasswd<<<"${user}:${pass}"
    htpasswd -b -c /etc/htpasswd $user $pass
    mkdir -p /etc/htpasswd.d/
    htpasswd -b -c /etc/htpasswd.d/htpasswd.${user} $user $pass
    chown -R $user:$user /home/${user}
  else
    #_skel
    useradd "${user}" -m -G www-data -s /bin/bash
    chpasswd<<<"${user}:${pass}"
    htpasswd -b -c /etc/htpasswd $user $pass
    mkdir -p /etc/htpasswd.d/
    htpasswd -b -c /etc/htpasswd.d/htpasswd.${user} $user $pass
  fi
  chmod 750 /home/${user}
  if grep ${user} /etc/sudoers.d/swizzin >/dev/null 2>&1 ; then echo "No sudoers modification made ... " ; else	echo "${user}	ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/swizzin ; fi
  echo "D /var/run/${user} 0750 ${user} ${user} -" >> /etc/tmpfiles.d/${user}.conf
  systemd-tmpfiles /etc/tmpfiles.d/${user}.conf --create
}

function _choices() {
  packages=()
  extras=()
  guis=()
  #locks=($(find /usr/local/bin/swizzin/install -type f -printf "%f\n" | cut -d "-" -f 2 | sort -d))
  locks=(nginx rtorrent deluge autodl panel ffmpeg quota)
  for i in "${locks[@]}"; do
    app=${i}
    if [[ ! -f /install/.$app.lock ]]; then
      packages+=("$i" '""')
    fi
  done
  #readarray packages < /root/results
  results=/root/results
}

function _install() {
  touch /tmp/.install.lock
  begin=$(date +"%s")
  readarray result < /root/results
  for i in "${result[@]}"; do
    result=$(echo $i)
    bash /usr/local/bin/swizzin/install/${result}.sh
    rm /tmp/.$result.lock
  done
  rm /root/results
  readarray result < /root/results2
  for i in "${result[@]}"; do
    result=$(echo $i)
    bash /usr/local/bin/swizzin/install/${result}.sh
  done
  rm /root/results2
  rm /tmp/.install.lock
  termin=$(date +"%s")
  difftimelps=$((termin-begin))
}

function _post {
  ip=$(ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p')
  echo "export PATH=\$PATH:/usr/local/bin/swizzin" >> /root/.bashrc
  #echo "export PATH=\$PATH:/usr/local/bin/swizzin" >> /home/$user/.bashrc
  #chown ${user}: /home/$user/.profile
  echo "Defaults    secure_path = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin/swizzin" > /etc/sudoers.d/secure_path
  if [[ $distribution = "Ubuntu" ]]; then
    echo 'Defaults  env_keep -="HOME"' > /etc/sudoers.d/env_keep
  fi
}

_os
_preparation
_skel
_adduser
_choices
_install
_post
