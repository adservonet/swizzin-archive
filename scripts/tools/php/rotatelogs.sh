#!/bin/bash
mv /srv/tools/logs/output.log /srv/tools/logs/output_$(date +%F-%H:%M:%S).log
touch /srv/tools/logs/output.log
chmod 777 /srv/tools/logs/output.log