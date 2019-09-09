#!/bin/bash

sudo rm -r  /srv/organizr
sudo rm /etc/nginx/apps/organizr.conf
sudo rm /install/.rapidleech.lock
service nginx reload
