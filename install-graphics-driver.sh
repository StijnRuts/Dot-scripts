#!/usr/bin/env bash
source ./shared-functions.sh

ANSWER="/tmp/dot-scripts-driver"

dialog --menu "Select graphics driver" 0 0 6 \
    "1"  "Intel" \
    "2"  "ATI" \
    "3"  "NVIDIA (nouveau)" \
    "4"  "NVIDIA (proprietary)" \
    "5"  "VirtualBox" \
    "6"  "Generic / Unknown" \
2>${ANSWER}

clear

case $(cat ${ANSWER}) in
    "1") # Intel
        package_install "xf86-video-intel libva-intel-driver intel-ucode"
        sed -i 's/MODULES=""/MODULES="i915"/' /etc/mkinitcpio.conf
        mkinitcpio
    ;;
    "2") # ATI
        package_install "xf86-video-ati"
        sed -i 's/MODULES=""/MODULES="radeon"/' /etc/mkinitcpio.conf
        mkinitcpio
    ;;
    "3") # NVIDIA (nouveau)
        package_install "xf86-video-nouveau"
        sed -i 's/MODULES=""/MODULES="nouveau"/' /etc/mkinitcpio.conf
        mkinitcpio
    ;;
    "4") # NVIDIA (proprietary)
        package_install "nvidia nvidia-libgl nvidia-utils nvidia-settings nvidia-xconfig"
        sh ./enable-multilib.sh
        package_install "lib32-nvidia-libgl lib32-nvidia-utils"
    ;;
    "5") # VirtualBox
        package_install "virtualbox-guest-utils virtualbox-guest-dkms"
        modprobe -a vboxguest vboxsf vboxvideo
        systemctl enable vboxservice
        echo -e "vboxguest\nvboxsf\nvboxvideo" > /etc/modules-load.d/virtualbox.conf
    ;;
    "6") # Generic / Unknown
        package_install "xf86-video-fbdev xf86-video-vesa"
    ;;
esac
