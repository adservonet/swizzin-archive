#!/bin/bash

apt_remove unpackerr
deluser unpackerr --system --quiet

rm /install/.unpackerr.lock
