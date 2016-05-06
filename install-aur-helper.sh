#!/usr/bin/env bash
source ./shared-functions.sh

# ensure that the necessary tools are installed
package_install "base-devel"

# install yaourt (and package-query dependency) though the aur.sh helper
su - $(logname) -c "sh ./aur.sh -si package-query yaourt"
