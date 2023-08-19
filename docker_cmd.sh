#!/bin/sh
# This script is run by the dockerfile
mkdir -p /app/build /app/output
chown docker /app/build /app/output
sudo -E -H -u docker -- ./build.sh
