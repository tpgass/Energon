#!/bin/bash -eux

echo "==> Applying updates"
sudo yum -y update

# reboot
echo "Rebooting the machine..."
reboot
sleep 60