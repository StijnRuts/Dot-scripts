#!/usr/bin/env bash
source ./shared-functions.sh

package_install "bspwm sxhkd feh urxvt dmenu"
package_install "polkit gnome-keyring gvfs xdg-utils xdg-user-dirs"

ln ./xinitrc ~/.xinitrc

mkdir -p ~/.config/bspwm
ln ./bspwmrc ~/.config/bspwm/bspwmrc

mkdir -p ~/.config/sxhkd
ln ./sxhkdrc ~/.config/sxhkd/sxhkdrc
