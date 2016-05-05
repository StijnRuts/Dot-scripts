#!/usr/bin/env bash

# ensure that the necessary tools are installed
pacman -S --needed base-devel

# install yaourt (and package-query dependency) though the aur.sh helper
bash <(curl aur.sh) -si package-query yaourt
