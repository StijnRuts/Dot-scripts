#!/usr/bin/env bash
source ./shared-functions.sh

package_install "bspwm sxhkd feh rxvt-unicode dmenu"
package_install "polkit gnome-keyring gvfs xdg-utils xdg-user-dirs"

# ln ./xinitrc ~/.xinitrc
cp -f ./xinitrc /home/stijn/.xinitrc

mkdir -p ~/.config/bspwm
mkdir -p /home/stijn/.config/bspwm
# ln ./bspwmrc ~/.config/bspwm/bspwmrc
cp -f ./bspwmrc /home/stijn/.config/bspwm/bspwmrc

mkdir -p ~/.config/sxhkd
mkdir -p /home/stijn/.config/sxhkd
# ln ./sxhkdrc ~/.config/sxhkd/sxhkdrc
cp -f ./sxhkdrc /home/stijn/.config/sxhkd/sxhkdrc

# ln ./wallpaper.jpg ~/Pictures/wallpaper.jpg
