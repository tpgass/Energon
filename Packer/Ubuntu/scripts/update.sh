#!/bin/bash -eux

# Disable the release upgrader
echo "==> Disabling daily apt services"
systemctl mask apt-daily.service apt-daily-upgrade.service

echo "==> Setting noninteractive terminal so we can fix debconf errors"
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

echo "==> Updating list of repositories"
# apt-get update does not actually perform updates, it just downloads and indexes the list of packages
apt -y update

echo "==> Performing dist-upgrade (all packages and kernel)"
apt full-upgrade -y --allow-remove-essential

echo "==> Reboot + wait...."
reboot
sleep 60

echo "==> Setting debconf back to normal"
echo 'debconf debconf/frontend select Dialog' | debconf-set-selections