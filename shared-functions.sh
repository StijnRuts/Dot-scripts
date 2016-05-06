#!/usr/bin/env bash

package_install() {
    pacman -S --noconfirm --needed ${1}
}

aur_package_install() {
    # run yaourt through su
    # because this drops sudo
    su - $(logname) -c "yaourt -S --noconfirm --needed ${1}"
}

is_package_installed() {
    for PKG in $1; do
        pacman -Q $PKG &> /dev/null && return 0;
    done
    return 1
}
