#!/usr/bin/env bash
source ./shared-functions.sh

# Setup pacman keyring
# package_install "haveged"
# haveged -w 1024
# pacman-key --init
# pacman-key --populate archlinux
# pacman-key --refresh-keys

# Backup original mirrorlist
mv --backup=numbered /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
MIRROR_TEMP="/tmp/mirrorlist"

# Get list of mirrors for BE and NL
curl -o ${MIRROR_TEMP} https://www.archlinux.org/mirrorlist/?use_mirror_status=on&country=BE&country=NL
sed -i 's/^#Server/Server/g' ${MIRROR_TEMP}

# Run RankMirrors
rankmirrors -n 10 ${MIRROR_TEMP} > /etc/pacman.d/mirrorlist

# Force pacman to refresh the package lists
pacman -Syyu
