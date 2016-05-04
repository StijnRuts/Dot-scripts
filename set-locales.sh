#!/usr/bin/env bash

# Generate the locales
sed -i "s/#en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen
sed -i "s/#nl_BE.UTF-8/nl_BE.UTF-8/" /etc/locale.gen
locale-gen

# Set the locales
localectl set-locale \
  LANG=en_US.UTF-8 \
  LANGUAGE=en_US.UTF-8:nl_BE.UTF-8 \
  LC_MONETARY=nl_BE.UTF-8 \
  LC_MEASUREMENT=nl_BE.UTF-8 \
  LC_NUMERIC=nl_BE.UTF-8 \
  LC_PAPER=nl_BE.UTF-8 \
  LC_TIME=nl_BE.UTF-8

# Set virtual console and X11 keymaps
localectl set-keymap --no-convert be-latin1
localectl set-x11-keymap --no-convert be

# Set timezone
ln -s /usr/share/zoneinfo/Europe/Brussels /etc/localtime
