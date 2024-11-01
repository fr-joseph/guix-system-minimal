#!/bin/sh

note () {
    txt_color='\e[33m'
    txt_reset='\e[0m'
    echo -e "${txt_color}===========> ${1}${txt_reset}"
}

if [ $# -ne 1 ]; then
    note "ERROR: Must provide phase number to run."
    exit 1
fi

cd

if [ "$1" = "1" ]; then
    note "partition the disk"
    gdisk /dev/nvme0n1
    note "now verify the disk is partitioned correctly, and continue with './install.sh 2'"
elif [ "$1" = "2" ]; then
    note "set up luks"
    cryptsetup -v --use-random luksFormat --type luks2 --pbkdf pbkdf2 /dev/nvme0n1p2
    cryptsetup open /dev/nvme0n1p2 main
    note "now verify luks is set up correctly"
    note "then edit 'system.scm' and fill in the UUID below:"
    cryptsetup luksUUID /dev/nvme0n1p2
    note "and then continue with './install.sh 3'"
elif [ "$1" = "3" ]; then
    note "main partition"
    mkfs.ext4 -L main /dev/mapper/main
    mkdir -p /mnt
    mount LABEL=main /mnt

    note "boot partition"
    mkfs.fat -F32 -n BOOT /dev/nvme0n1p1
    mkdir -p /mnt/boot/efi
    mount LABEL=BOOT /mnt/boot/efi

    mkdir -p /mnt/etc
    cd

    note "start cow-store"
    herd start cow-store /mnt

    note "now copy the config file to /mnt/etc/system.scm, and edit it as needed."
    note "finish the installation with './install.sh 4'"
    note "and then you can reboot into the new system"
elif [ "$1" = "4" ]; then
    guix system \
      --substitute-urls='https://ci.guix.gnu.org https://bordeaux.guix.gnu.org https://substitutes.nonguix.org' \
      --cores=0 \
      init /mnt/etc/system.scm /mnt
else
    note "ERROR: Invalid phase number."
    exit 1
fi
