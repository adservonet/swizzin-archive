#!/bin/bash

apt remove -y proftpd proftpd-basic
rm -rf /etc/proftpd/
rm /install/.proftpd.lock


