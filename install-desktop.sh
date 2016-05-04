#!/usr/bin/env bash

install_de_wm() {

    # Only show this information box once
    if [[ $SHOW_ONCE -eq 0 ]]; then
        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_InstDETitle " --msgbox "$_DEInfoBody" 0 0
        SHOW_ONCE=1
    fi

    # DE/WM Menu
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_InstDETitle " --checklist "$_InstDEBody $_UseSpaceBar" 0 0 12 \
    "budgie-desktop" "-" off \
    "cinnamon" "-" off \
    "deepin" "-" off \
    "deepin-extra" "-" off \
    "enlightenment + terminology" "-" off \
    "gnome-shell" "-" off \
    "gnome" "-" off \
    "gnome-extra" "-" off \
    "plasma-desktop" "-" off \
    "plasma" "-" off \
    "kde-applications" "-" off \
    "lxde" "-" off \
    "lxqt + oxygen-icons" "-" off \
    "mate" "-" off \
    "mate-extra" "-" off \
    "mate-gtk3" "-" off \
    "mate-extra-gtk3" "-" off \
    "xfce4" "-" off \
    "xfce4-goodies" "-" off \
    "awesome + vicious" "-" off \
    "fluxbox + fbnews" "-" off \
    "i3-wm + i3lock + i3status" "-" off \
    "icewm + icewm-themes" "-" off \
    "openbox + openbox-themes" "-" off \
    "pekwm + pekwm-themes" "-" off \
    "windowmaker" "-" off 2>${PACKAGES}

    # If something has been selected, install
    if [[ $(cat ${PACKAGES}) != "" ]]; then
        clear
        sed -i 's/+\|\"//g' ${PACKAGES}
        pacstrap ${MOUNTPOINT} $(cat ${PACKAGES}) 2>/tmp/.errlog
        check_for_error


        # Clear the packages file for installation of "common" packages
        echo "" > ${PACKAGES}

        # Offer to install various "common" packages.
        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_InstComTitle " --checklist "$_InstComBody $_UseSpaceBar" 0 50 14 \
        "bash-completion" "-" on \
        "gamin" "-" on \
        "gksu" "-" on \
        "gnome-icon-theme" "-" on \
        "gnome-keyring" "-" on \
        "gvfs" "-" on \
        "gvfs-afc" "-" on \
        "gvfs-smb" "-" on \
        "polkit" "-" on \
        "poppler" "-" on \
        "python2-xdg" "-" on \
        "ntfs-3g" "-" on \
        "ttf-dejavu" "-" on \
        "xdg-user-dirs" "-" on \
        "xdg-utils" "-" on \
        "xterm" "-" on 2>${PACKAGES}

        # If at least one package, install.
        if [[ $(cat ${PACKAGES}) != "" ]]; then
            clear
            pacstrap ${MOUNTPOINT} $(cat ${PACKAGES}) 2>/tmp/.errlog
            check_for_error
        fi

    fi

}

# Display Manager
install_dm() {

    # Save repetition of code
    enable_dm() {
        arch_chroot "systemctl enable $(cat ${PACKAGES})" 2>/tmp/.errlog
        check_for_error
        DM=$(cat ${PACKAGES})
        DM_ENABLED=1
    }

    if [[ $DM_ENABLED -eq 0 ]]; then
        # Prep variables
        echo "" > ${PACKAGES}
        dm_list="gdm lxdm lightdm sddm"
        DM_LIST=""
        DM_INST=""

        # Generate list of DMs installed with DEs, and a list for selection menu
        for i in ${dm_list}; do
            [[ -e ${MOUNTPOINT}/usr/bin/${i} ]] && DM_INST="${DM_INST} ${i}"
            DM_LIST="${DM_LIST} ${i} -"
        done

        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_DmChTitle " --menu "$_AlreadyInst$DM_INST\n\n$_DmChBody" 0 0 4 \
        ${DM_LIST} 2>${PACKAGES}
        clear

        # If a selection has been made, act
        if [[ $(cat ${PACKAGES}) != "" ]]; then

            # check if selected dm already installed. If so, enable and break loop.
            for i in ${DM_INST}; do
                if [[ $(cat ${PACKAGES}) == ${i} ]]; then
                    enable_dm
                    break;
                fi
            done

            # If no match found, install and enable DM
            if [[ $DM_ENABLED -eq 0 ]]; then

                # Where lightdm selected, add gtk greeter package
                sed -i 's/lightdm/lightdm lightdm-gtk-greeter/' ${PACKAGES}
                pacstrap ${MOUNTPOINT} $(cat ${PACKAGES}) 2>/tmp/.errlog

                # Where lightdm selected, now remove the greeter package
                sed -i 's/lightdm-gtk-greeter//' ${PACKAGES}
                enable_dm
            fi
        fi
    fi

    # Show after successfully installing or where attempting to repeat when already completed.
    [[ $DM_ENABLED -eq 1 ]] && dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_DmChTitle " --msgbox "$_DmDoneBody" 0 0

}
