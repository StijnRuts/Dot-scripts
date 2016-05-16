#!/usr/bin/env bash
source ./shared-functions.sh

# Install xorg
package_install "xorg-server xorg-server-common xorg-server-utils xorg-apps xorg-xinit numlockx"

# Install input drivers
package_install "xf86-input-libinput xorg-xinput"
# package_install "xf86-input-evdev xf86-input-joystick xf86-input-keyboard xf86-input-mouse xf86-input-synaptics xf86-input-wacom"

# Touchpad configuration; Tapping may be disabled by default. To enable it, add a configuration file:
# /etc/X11/xorg.conf.d/30-touchpad.conf
# Section "InputClass"
#     Identifier "MyTouchpad"
#     MatchIsTouchpad "on"
#     Driver "libinput"
#     Option "Tapping" "on"
# EndSection

# Copy the xinit configuration file
ln ./xinitrc ~/.xinitrc

# Install compositor
# (no compositor at the moment)
# package_install "compton"
# package_install "xcompmgr"

# Enable rootless Xorg
# echo "needs_root_rights = no" > /etc/X11/Xwrapper.config
