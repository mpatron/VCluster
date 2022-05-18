#!/bin/bash

# This script has been tested on Ubuntu 20.04
# For other versions of Ubuntu, you might need some tweaking

echo "[TASK 1] Install commons tools"
apt update -qq >/dev/null 2>&1
apt install -qq -y ca-certificates apt-transport-https curl gnupg lsb-release software-properties-common >/dev/null 2>&1

echo "[TASK 2] Hack for kube"
mknod /dev/kmsg c 1 11
echo 'mknod /dev/kmsg c 1 11' >> /etc/rc.local
chmod +x /etc/rc.local
