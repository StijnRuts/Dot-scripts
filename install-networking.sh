#!/usr/bin/env bash

install_network_menu() {

    # ntp not exactly wireless, but this menu is the best fit.
    install_wireless_packages(){

        WIRELESS_PACKAGES=""
        wireless_pkgs="dialog iw rp-pppoe wireless_tools wpa_actiond"

        for i in ${wireless_pkgs}; do
            WIRELESS_PACKAGES="${WIRELESS_PACKAGES} ${i} - on"
        done

        # If no wireless, uncheck wireless pkgs
        [[ $(lspci | grep -i "Network Controller") == "" ]] && WIRELESS_PACKAGES=$(echo $WIRELESS_PACKAGES | sed "s/ on/ off/g")

        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_InstNMMenuPkg " --checklist "$_InstNMMenuPkgBody\n\n$_UseSpaceBar" 0 0 13 \
        $WIRELESS_PACKAGES \
        "ufw" "-" off \
        "gufw" "-" off \
        "ntp" "-" off \
        "b43-fwcutter" "Broadcom 802.11b/g/n" off \
        "bluez-firmware" "Broadcom BCM203x / STLC2300 Bluetooth" off \
        "ipw2100-fw" "Intel PRO/Wireless 2100" off \
        "ipw2200-fw" "Intel PRO/Wireless 2200" off \
        "zd1211-firmware" "ZyDAS ZD1211(b) 802.11a/b/g USB WLAN" off 2>${PACKAGES}

        if [[ $(cat ${PACKAGES}) != "" ]]; then
            clear
            pacstrap ${MOUNTPOINT} $(cat ${PACKAGES}) 2>/tmp/.errlog
            check_for_error
        fi

    }

    install_cups(){

        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_InstNMMenuCups " --checklist "$_InstCupsBody\n\n$_UseSpaceBar" 0 0 11 \
        "cups" "-" on \
        "cups-pdf" "-" off \
        "ghostscript" "-" on \
        "gsfonts" "-" on \
        "samba" "-" off 2>${PACKAGES}

        if [[ $(cat ${PACKAGES}) != "" ]]; then
            clear
            pacstrap ${MOUNTPOINT} $(cat ${PACKAGES}) 2>/tmp/.errlog
            check_for_error

            if [[ $(cat ${PACKAGES} | grep "cups") != "" ]]; then
                dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_InstNMMenuCups " --yesno "$_InstCupsQ" 0 0
                if [[ $? -eq 0 ]]; then
                    arch_chroot "systemctl enable org.cups.cupsd.service" 2>/tmp/.errlog
                    check_for_error
                    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_InstNMMenuCups " --infobox "\n$_Done!\n\n" 0 0
                    sleep 2
                fi
            fi
        fi

    }

    if [[ $SUB_MENU != "install_network_packages" ]]; then
        SUB_MENU="install_network_packages"
        HIGHLIGHT_SUB=1
    else
        if [[ $HIGHLIGHT_SUB != 5 ]]; then
            HIGHLIGHT_SUB=$(( HIGHLIGHT_SUB + 1 ))
        fi
    fi

    dialog --default-item ${HIGHLIGHT_SUB} --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_InstNMMenuTitle " --menu "$_InstNMMenuBody" 0 0 5 \
    "1" "$_SeeWirelessDev" \
    "2" "$_InstNMMenuPkg" \
    "3" "$_InstNMMenuNM" \
    "4" "$_InstNMMenuCups" \
    "5" "$_Back" 2>${ANSWER}

    case $(cat ${ANSWER}) in
        "1") # Identify the Wireless Device
        lspci -k | grep -i -A 2 "network controller" > /tmp/.wireless
        if [[ $(cat /tmp/.wireless) != "" ]]; then
            dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_WirelessShowTitle " --textbox /tmp/.wireless 0 0
        else
            dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_WirelessShowTitle " --msgbox "$_WirelessErrBody" 7 30
        fi
        ;;
        "2") install_wireless_packages
        ;;
        "3") install_nm
        ;;
        "4") install_cups
        ;;
        *) main_menu_online
        ;;
    esac

    install_network_menu

}

# Network Manager
install_nm() {

    # Save repetition of code
    enable_nm() {
        if [[ $(cat ${PACKAGES}) == "NetworkManager" ]]; then
            arch_chroot "systemctl enable NetworkManager.service && systemctl enable NetworkManager-dispatcher.service" >/tmp/.symlink 2>/tmp/.errlog
        else
            arch_chroot "systemctl enable $(cat ${PACKAGES})" 2>/tmp/.errlog
        fi

        check_for_error
        NM_ENABLED=1
    }

    if [[ $NM_ENABLED -eq 0 ]]; then
        # Prep variables
        echo "" > ${PACKAGES}
        nm_list="connman CLI dhcpcd CLI netctl CLI NetworkManager GUI wicd GUI"
        NM_LIST=""
        NM_INST=""

        # Generate list of DMs installed with DEs, and a list for selection menu
        for i in ${nm_list}; do
            [[ -e ${MOUNTPOINT}/usr/bin/${i} ]] && NM_INST="${NM_INST} ${i}"
            NM_LIST="${NM_LIST} ${i}"
        done

        # Remove netctl from selectable list as it is a PITA to configure via arch_chroot
        NM_LIST=$(echo $NM_LIST | sed "s/netctl CLI//")

        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_InstNMTitle " --menu "$_AlreadyInst $NM_INST\n$_InstNMBody" 0 0 4 \
        ${NM_LIST} 2> ${PACKAGES}
        clear

        # If a selection has been made, act
        if [[ $(cat ${PACKAGES}) != "" ]]; then

            # check if selected nm already installed. If so, enable and break loop.
            for i in ${NM_INST}; do
                [[ $(cat ${PACKAGES}) == ${i} ]] && enable_nm && break
            done

            # If no match found, install and enable NM
            if [[ $NM_ENABLED -eq 0 ]]; then

                # Where networkmanager selected, add network-manager-applet
                sed -i 's/NetworkManager/networkmanager network-manager-applet/g' ${PACKAGES}
                pacstrap ${MOUNTPOINT} $(cat ${PACKAGES}) 2>/tmp/.errlog

                # Where networkmanager selected, now remove network-manager-applet
                sed -i 's/networkmanager network-manager-applet/NetworkManager/g' ${PACKAGES}
                enable_nm
            fi
        fi
    fi

    # Show after successfully installing or where attempting to repeat when already completed.
    [[ $NM_ENABLED -eq 1 ]] && dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_InstNMTitle " --msgbox "$_InstNMErrBody" 0 0


}
