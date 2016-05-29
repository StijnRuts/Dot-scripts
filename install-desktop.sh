#!/usr/bin/env bash
source ./shared-functions.sh

package_install "bspwm sxhkd dmenu rxvt-unicode feh"
package_install "polkit gnome-keyring gvfs xdg-utils xdg-user-dirs"

ln -sf $(pwd)/xinitrc ~/.xinitrc

mkdir -p ~/.config/bspwm
ln -sf $(pwd)/bspwmrc ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/bspwmrc

mkdir -p ~/.config/sxhkd
ln -sf $(pwd)/sxhkdrc ~/.config/sxhkd/sxhkdrc
chmod +x ~/.config/sxhkd/sxhkdrc

# ln -sf $(pwd)/wallpaper.jpg ~/Pictures/wallpaper.jpg
