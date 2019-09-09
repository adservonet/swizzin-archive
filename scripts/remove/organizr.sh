#!/bin/bash

sudo rm -r  /srv/organizr
sudo rm /etc/nginx/apps/organizr.conf
sudo rm /install/.organizr.lock
service nginx reload
