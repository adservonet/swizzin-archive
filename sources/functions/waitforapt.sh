#!/bin/bash

function waitforapt {
  i=0
  echo i$i
  echo "waiting for apt locks"
  echo "waiting for apt locks"  >> "${SEEDIT_LOG}" 2>&1;
  while sudo fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/lock >/dev/null 2>&1; do
    ((i++))
    echo $i
    echo $i >> "${SEEDIT_LOG}" 2>&1;

    if [ $i == 30 ]
    then
      echo "killall apt-get"
      echo "killall apt-get" >> "${SEEDIT_LOG}" 2>&1;
      echo "waiting another 30 seconds till i delete locks"
      echo "waiting another 30 seconds till i delete locks" >> "${SEEDIT_LOG}" 2>&1;
      sudo killall apt-get >> "${SEEDIT_LOG}" 2>&1;
    fi

    if [ $i == 60 ]
    then
      echo "deleting locks"
      echo "deleting locks" >> "${SEEDIT_LOG}" 2>&1;
      sudo rm /var/lib/dpkg/lock
      sudo rm /var/lib/dpkg/lock-frontend
      sudo rm /var/cache/apt/archives/lock
      sudo rm /var/cache/debconf/*.dat

      sudo rm /var/lib/apt/lists/lock
      sudo rm /var/cache/apt/archives/lock
      sudo rm /var/lib/dpkg/updates/*
      sudo apt-get update
    fi

    sleep 1
  done
}
