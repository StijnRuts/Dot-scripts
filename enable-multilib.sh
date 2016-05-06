#!/usr/bin/env bash

sed -i 's/#\[multilib\]/[multilib]/' /etc/pacman.conf
sed -i '/\[multilib\]/!b;n;cInclude = /etc/pacman.d/mirrorlist' /etc/pacman.conf
pacman -Syu
