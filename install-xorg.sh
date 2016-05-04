#!/usr/bin/env bash

# Install xorg and input drivers. Also copy the xkbmap configuration file created earlier to the installed system
install_xorg_input() {

    echo "" > ${PACKAGES}

    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_InstGrMenuDS " --checklist "$_InstGrMenuDSBody\n\n$_UseSpaceBar" 0 0 12 \
    "wayland" "-" off \
    "xorg-server" "-" on \
    "xorg-server-common" "-" off \
    "xorg-server-utils" "-" on \
    "xorg-xinit" "-" on \
    "xorg-server-xwayland" "-" off \
    "xf86-input-evdev" "-" off \
    "xf86-input-joystick" "-" off \
    "xf86-input-keyboard" "-" on \
    "xf86-input-libinput" "-" off \
    "xf86-input-mouse" "-" on \
    "xf86-input-synaptics" "-" on 2>${PACKAGES}

    clear
    # If at least one package, install.
    if [[ $(cat ${PACKAGES}) != "" ]]; then
        pacstrap ${MOUNTPOINT} $(cat ${PACKAGES}) 2>/tmp/.errlog
        check_for_error
    fi

    # now copy across .xinitrc for all user accounts
    user_list=$(ls ${MOUNTPOINT}/home/ | sed "s/lost+found//")
    for i in ${user_list}; do
        cp -f ${MOUNTPOINT}/etc/X11/xinit/xinitrc ${MOUNTPOINT}/home/$i/.xinitrc
        arch_chroot "chown -R ${i}:users /home/${i}"
    done

    install_graphics_menu
}

setup_graphics_card() {

    # Save repetition
    install_intel(){

        pacstrap ${MOUNTPOINT} xf86-video-intel libva-intel-driver intel-ucode 2>/tmp/.errlog
        sed -i 's/MODULES=""/MODULES="i915"/' ${MOUNTPOINT}/etc/mkinitcpio.conf

        # Intel microcode (Grub, Syslinux and systemd-boot).
        # Done as seperate if statements in case of multiple bootloaders.
        if [[ -e ${MOUNTPOINT}/boot/grub/grub.cfg ]]; then
            dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " grub-mkconfig " --infobox "$_PlsWaitBody" 0 0
            sleep 1
            arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg" 2>>/tmp/.errlog
        fi

        # Syslinux
        [[ -e ${MOUNTPOINT}/boot/syslinux/syslinux.cfg ]] && sed -i "s/INITRD /&..\/intel-ucode.img,/g" ${MOUNTPOINT}/boot/syslinux/syslinux.cfg

        # Systemd-boot
        if [[ -e ${MOUNTPOINT}${UEFI_MOUNT}/loader/loader.conf ]]; then
            update=$(ls ${MOUNTPOINT}${UEFI_MOUNT}/loader/entries/*.conf)
            for i in ${upgate}; do
                sed -i '/linux \//a initrd \/intel-ucode.img' ${i}
            done
        fi

    }

    # Save repetition
    install_ati(){
        pacstrap ${MOUNTPOINT} xf86-video-ati 2>/tmp/.errlog
        sed -i 's/MODULES=""/MODULES="radeon"/' ${MOUNTPOINT}/etc/mkinitcpio.conf
    }

    # Main menu. Correct option for graphics card should be automatically highlighted.
    NVIDIA=""
    VB_MOD=""
    GRAPHIC_CARD=""
    INTEGRATED_GC="N/A"
    GRAPHIC_CARD=$(lspci | grep -i "vga" | sed 's/.*://' | sed 's/(.*//' | sed 's/^[ \t]*//')

    # Highlight menu entry depending on GC detected. Extra work is needed for NVIDIA
    if 	[[ $(echo $GRAPHIC_CARD | grep -i "nvidia") != "" ]]; then
        # If NVIDIA, first need to know the integrated GC
        [[ $(lscpu | grep -i "intel\|lenovo") != "" ]] && INTEGRATED_GC="Intel" || INTEGRATED_GC="ATI"

        # Second, identity the NVIDIA card and driver / menu entry
        if [[ $(dmesg | grep -i 'chipset' | grep -i 'nvc\|nvd\|nve') != "" ]]; then HIGHLIGHT_SUB_GC=4
    elif [[ $(dmesg | grep -i 'chipset' | grep -i 'nva\|nv5\|nv8\|nv9'﻿) != "" ]]; then HIGHLIGHT_SUB_GC=5
elif [[ $(dmesg | grep -i 'chipset' | grep -i 'nv4\|nv6') != "" ]]; then HIGHLIGHT_SUB_GC=6
else HIGHLIGHT_SUB_GC=3
fi

# All non-NVIDIA cards / virtualisation
elif [[ $(echo $GRAPHIC_CARD | grep -i 'intel\|lenovo') != "" ]]; then HIGHLIGHT_SUB_GC=2
elif [[ $(echo $GRAPHIC_CARD | grep -i 'ati') != "" ]]; then HIGHLIGHT_SUB_GC=1
elif [[ $(echo $GRAPHIC_CARD | grep -i 'via') != "" ]]; then HIGHLIGHT_SUB_GC=7
elif [[ $(echo $GRAPHIC_CARD | grep -i 'virtualbox') != "" ]]; then HIGHLIGHT_SUB_GC=8
elif [[ $(echo $GRAPHIC_CARD | grep -i 'vmware') != "" ]]; then HIGHLIGHT_SUB_GC=9
else HIGHLIGHT_SUB_GC=10
fi

dialog --default-item ${HIGHLIGHT_SUB_GC} --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_GCtitle " \
--menu "$GRAPHIC_CARD\n" 0 0 10 \
"1" $"xf86-video-ati" \
"2" $"xf86-video-intel" \
"3" $"xf86-video-nouveau (+ $INTEGRATED_GC)" \
"4" $"Nvidia (+ $INTEGRATED_GC)" \
"5" $"Nvidia-340xx (+ $INTEGRATED_GC)" \
"6" $"Nvidia-304xx (+ $INTEGRATED_GC)" \
"7" $"xf86-video-openchrome" \
"8" $"virtualbox-guest-dkms" \
"9" $"xf86-video-vmware" \
"10" "$_GCUnknOpt / xf86-video-fbdev" 2>${ANSWER}

case $(cat ${ANSWER}) in
    "1") # ATI/AMD
    install_ati
    ;;
    "2") # Intel
    install_intel
    ;;
    "3") # Nouveau / NVIDIA
    [[ $INTEGRATED_GC == "ATI" ]] &&  install_ati || install_intel
    pacstrap ${MOUNTPOINT} xf86-video-nouveau 2>/tmp/.errlog
    sed -i 's/MODULES=""/MODULES="nouveau"/' ${MOUNTPOINT}/etc/mkinitcpio.conf
    ;;
    "4") # NVIDIA-GF
    [[ $INTEGRATED_GC == "ATI" ]] &&  install_ati || install_intel
    arch_chroot "pacman -Rdds --noconfirm mesa-libgl mesa"

    # Set NVIDIA driver(s) to install depending on installed kernel(s)
    ([[ -e ${MOUNTPOINT}/boot/initramfs-linux.img ]] || [[ -e ${MOUNTPOINT}/boot/initramfs-linux-grsec.img ]] || [[ -e ${MOUNTPOINT}/boot/initramfs-linux-zen.img ]]) && NVIDIA="nvidia"
    [[ -e ${MOUNTPOINT}/boot/initramfs-linux-lts.img ]] && NVIDIA="$NVIDIA nvidia-lts"

    clear
    pacstrap ${MOUNTPOINT} ${NVIDIA} nvidia-libgl nvidia-utils pangox-compat nvidia-settings 2>/tmp/.errlog
    NVIDIA_INST=1
    ;;
    "5") # NVIDIA-340

    [[ $INTEGRATED_GC == "ATI" ]] &&  install_ati || install_intel
    arch_chroot "pacman -Rdds --noconfirm mesa-libgl mesa"

    # Set NVIDIA driver(s) to install depending on installed kernel(s)
    ([[ -e ${MOUNTPOINT}/boot/initramfs-linux.img ]] || [[ -e ${MOUNTPOINT}/boot/initramfs-linux-grsec.img ]] || [[ -e ${MOUNTPOINT}/boot/initramfs-linux-zen.img ]]) && NVIDIA="nvidia-340xx"
    [[ -e ${MOUNTPOINT}/boot/initramfs-linux-lts.img ]] && NVIDIA="$NVIDIA nvidia-340xx-lts"

    clear
    pacstrap ${MOUNTPOINT} ${NVIDIA} nvidia-340xx-libgl nvidia-340xx-utils nvidia-settings 2>/tmp/.errlog
    NVIDIA_INST=1
    ;;
    "6") # NVIDIA-304
    [[ $INTEGRATED_GC == "ATI" ]] &&  install_ati || install_intel
    arch_chroot "pacman -Rdds --noconfirm mesa-libgl mesa"

    # Set NVIDIA driver(s) to install depending on installed kernel(s)
    ([[ -e ${MOUNTPOINT}/boot/initramfs-linux.img ]] || [[ -e ${MOUNTPOINT}/boot/initramfs-linux-grsec.img ]] || [[ -e ${MOUNTPOINT}/boot/initramfs-linux-zen.img ]]) && NVIDIA="nvidia-304xx"
    [[ -e ${MOUNTPOINT}/boot/initramfs-linux-lts.img ]] && NVIDIA="$NVIDIA nvidia-304xx-lts"

    clear
    pacstrap ${MOUNTPOINT} ${NVIDIA} nvidia-304xx-libgl nvidia-304xx-utils nvidia-settings 2>/tmp/.errlog
    NVIDIA_INST=1
    ;;
    "7") # Via
    pacstrap ${MOUNTPOINT} xf86-video-openchrome 2>/tmp/.errlog
    ;;
    "8") # VirtualBox

    # Set VB headers to install depending on installed kernel(s)
    [[ -e ${MOUNTPOINT}/boot/initramfs-linux.img ]] && VB_MOD="linux-headers"
    [[ -e ${MOUNTPOINT}/boot/initramfs-linux-grsec.img ]] && VB_MOD="$VB_MOD linux-grsec-headers"
    [[ -e ${MOUNTPOINT}/boot/initramfs-linux-zen.img ]] && VB_MOD="$VB_MOD linux-zen-headers"
    [[ -e ${MOUNTPOINT}/boot/initramfs-linux-lts.img ]] && VB_MOD="$VB_MOD linux-lts-headers"

    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_VBoxInstTitle" --msgbox "$_VBoxInstBody" 0 0
    clear

    pacstrap ${MOUNTPOINT} virtualbox-guest-utils virtualbox-guest-dkms $VB_MOD 2>/tmp/.errlog
    umount -l /mnt/dev

    # Load modules and enable vboxservice.
    arch_chroot "modprobe -a vboxguest vboxsf vboxvideo"
    arch_chroot "systemctl enable vboxservice"
    echo -e "vboxguest\nvboxsf\nvboxvideo" > ${MOUNTPOINT}/etc/modules-load.d/virtualbox.conf
    ;;
    "9") # VMWare
    pacstrap ${MOUNTPOINT} xf86-video-vmware xf86-input-vmmouse 2>/tmp/.errlog
    ;;
    "10") # Generic / Unknown
    pacstrap ${MOUNTPOINT} xf86-video-fbdev 2>/tmp/.errlog
    ;;
    *) install_graphics_menu
    ;;
esac
check_for_error

# Create a basic xorg configuration file for NVIDIA proprietary drivers where installed
# if that file does not already exist.
if [[ $NVIDIA_INST == 1 ]] && [[ ! -e ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf ]]; then
    echo "Section "\"Device"\"" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo "        Identifier "\"Nvidia Card"\"" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo "        Driver "\"nvidia"\"" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo "        VendorName "\"NVIDIA Corporation"\"" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo "        Option "\"NoLogo"\" "\"true"\"" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo "        #Option "\"UseEDID"\" "\"false"\"" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo "        #Option "\"ConnectedMonitor"\" "\"DFP"\"" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo "        # ..." >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo "EndSection" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
fi

# Where NVIDIA has been installed allow user to check and amend the file
if [[ $NVIDIA_INST == 1 ]]; then
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_NvidiaConfTitle " --msgbox "$_NvidiaConfBody" 0 0
    nano ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
fi

install_graphics_menu

}
