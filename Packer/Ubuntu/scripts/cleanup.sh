#!/bin/bash -eux

SSH_USER=${SSH_USERNAME:-ansible}
DISK_USAGE_BEFORE_CLEANUP=$(df -h)

#UBUNTU_VERSION=$(lsb_release -sr)
# Add delay to prevent "vagrant reload" from failing
echo "pre-up sleep 2" >> /etc/network/interfaces

echo "==> Cleaning up tmp"
rm -rf /tmp/*

echo "==> Installed packages before cleanup"
dpkg --get-selections | grep -v deinstall

# Remove some packages to get a minimal install
echo "==> Removing all linux kernels except the currrent one"
dpkg --list | awk '{ print $2 }' | grep -e 'linux-\(headers\|image\)-.*[0-9]\($\|-generic\)' | grep -v "$(uname -r | sed 's/-generic//')" | xargs apt -y purge
echo "==> Removing linux source"
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt -y purge
echo "==> Removing development packages"
dpkg --list | awk '{ print $2 }' | grep -- '-dev$' | xargs apt -y purge
echo "==> Removing documentation"
dpkg --list | awk '{ print $2 }' | grep -- '-doc$' | xargs apt -y purge
#echo "==> Removing development tools"
#dpkg --list | grep -i compiler | awk '{ print $2 }' | xargs apt -y purge
#apt -y purge cpp gcc g++ 
#apt -y purge build-essential git
echo "==> Removing default system Ruby"
apt -y purge ruby ri
echo "==> Removing X11 libraries"
apt -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6
echo "==> Removing other oddities"
apt -y purge popularity-contest installation-report landscape-common wireless-tools wpasupplicant 

echo "==> Cleaning up the apt cache..."
apt -y autoremove --purge
apt -y autoclean
apt -y clean

#echo "==> Clean up orphaned packages with deborphan"
#apt -y install deborphan
#while [ -n "$(deborphan --guess-all --libdevel)" ]; do
#    deborphan --guess-all --libdevel | xargs apt -y purge
#done
#apt -y purge deborphan dialog

echo "==> Removing man pages"
rm -rf /usr/share/man/*
#echo "==> Removing APT files"
#find /var/lib/apt -type f | xargs rm -f
echo "==> Removing any docs"
rm -rf /usr/share/doc/*
echo "==> Removing caches"
find /var/cache -type f -exec rm -rf {} \;
# delete any logs that have built up during the install
find /var/log/ -name *.log -exec rm -f {} \;

# Remove Bash history
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/${SSH_USER}/.bash_history

# Clean up log files
#find /var/log -type f | while read f; do echo -ne '' > "${f}"; done;

echo "==> Clearing last login information"
>/var/log/lastlog
>/var/log/wtmp
>/var/log/btmp

# Whiteout root
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
let count--
#$((count -= 1))
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count
rm /tmp/whitespace

# Whiteout /boot (using atomic in preseed, less necessary)
#count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
#let count--
#dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count
#rm /boot/whitespace

echo '==> Clear out swap and disable until reboot'
set +e
swapuuid=$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)
case "$?" in
    2|0) ;;
    *) exit 1 ;;
esac
set -e
if [ "x${swapuuid}" != "x" ]; then
    # Whiteout the swap partition to reduce box size
    # Swap is disabled till reboot
    swappart=$(readlink -f /dev/disk/by-uuid/$swapuuid)
    /sbin/swapoff "${swappart}"
    dd if=/dev/zero of="${swappart}" bs=1M || echo "dd exit code $? is suppressed"
    /sbin/mkswap -U "${swapuuid}" "${swappart}"
fi

# Zero out the free space to save space in the final image
dd if=/dev/zero of=/EMPTY bs=1M  || echo "dd exit code $? is suppressed"
rm -f /EMPTY

# Make sure we wait until all the data is written to disk, otherwise
# Packer might quite too early before the large files are deleted
sync

echo "==> Disk usage before cleanup"
echo "${DISK_USAGE_BEFORE_CLEANUP}"

echo "==> Disk usage after cleanup"
df -h
