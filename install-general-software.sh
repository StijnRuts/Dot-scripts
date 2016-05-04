#!/usr/bin/env bash

install_software() {

    echo "" > ${PACKAGES}

    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_InstAccTitle " --checklist "$_InstAccBody" 0 0 15 \
    "package1" "-" off \
    "package2" "-" on \
    "package3" "-" off 2>${PACKAGES}

    clear
    # If something has been selected, install
    if [[ $(cat ${PACKAGES}) != "" ]]; then
        pacstrap ${MOUNTPOINT} ${PACKAGES} 2>/tmp/.errlog
        check_for_error
    fi

}

install_basic_setup() {
    print_title "BASH TOOLS - https://wiki.archlinux.org/index.php/Bash"
    package_install "bc rsync mlocate bash-completion pkgstats arch-wiki-lite"
    pause_function
    print_title "(UN)COMPRESS TOOLS - https://wiki.archlinux.org/index.php/P7zip"
    package_install "zip unzip unrar p7zip lzop cpio"
    pause_function
    print_title "AVAHI - https://wiki.archlinux.org/index.php/Avahi"
    print_info "Avahi is a free Zero Configuration Networking (Zeroconf) implementation, including a system for multicast DNS/DNS-SD discovery. It allows programs to publish and discovers services and hosts running on a local network with no specific configuration."
    package_install "avahi nss-mdns"
    is_package_installed "avahi" && system_ctl enable avahi-daemon
    pause_function
    print_title "ALSA - https://wiki.archlinux.org/index.php/Alsa"
    print_info "The Advanced Linux Sound Architecture (ALSA) is a Linux kernel component intended to replace the original Open Sound System (OSSv3) for providing device drivers for sound cards."
    package_install "alsa-utils alsa-plugins"
    [[ ${ARCHI} == x86_64 ]] && package_install "lib32-alsa-plugins"
    pause_function
    print_title "PULSEAUDIO - https://wiki.archlinux.org/index.php/Pulseaudio"
    print_info "PulseAudio is the default sound server that serves as a proxy to sound applications using existing kernel sound components like ALSA or OSS"
    package_install "pulseaudio pulseaudio-alsa"
    [[ ${ARCHI} == x86_64 ]] && package_install "lib32-libpulse"
    pause_function
    print_title "NTFS/FAT/exFAT/F2FS - https://wiki.archlinux.org/index.php/File_Systems"
    print_info "A file system (or filesystem) is a means to organize data expected to be retained after a program terminates by providing procedures to store, retrieve and update data, as well as manage the available space on the device(s) which contain it. A file system organizes data in an efficient manner and is tuned to the specific characteristics of the device."
    package_install "ntfs-3g dosfstools exfat-utils f2fs-tools fuse fuse-exfat autofs"
    pause_function
}

install_system_apps() {
    while true
    do
        print_title "SYSTEM TOOLS APPS"
        echo " 1) $(menu_item "clamav")"
        echo " 2) $(menu_item "cockpit")"
        echo " 3) $(menu_item "docker")"
        echo " 4) $(menu_item "firewalld")"
        echo " 5) $(menu_item "gparted")"
        echo " 6) $(menu_item "grsync")"
        echo " 7) $(menu_item "hosts-update") $AUR"
        echo " 8) $(menu_item "htop")"
        echo " 9) $(menu_item "plex-media-server" "Plex") $AUR"
        echo "10) $(menu_item "ufw")"
        echo "11) $(menu_item "unified-remote-server" "Unified Remote") $AUR"
        echo "12) $(menu_item "virtualbox")"
        echo "13) $(menu_item "wine")"
        echo ""
        echo " b) BACK"
        echo ""
        SYSTEMTOOLS_OPTIONS+=" b"
        read_input_options "$SYSTEMTOOLS_OPTIONS"
        for OPT in ${OPTIONS[@]}; do
            case "$OPT" in
                1)
                package_install "clamav"
                cp /etc/clamav/clamd.conf.sample /etc/clamav/clamd.conf
                cp /etc/clamav/freshclam.conf.sample /etc/clamav/freshclam.conf
                sed -i '/Example/d' /etc/clamav/freshclam.conf
                sed -i '/Example/d' /etc/clamav/clamd.conf
                system_ctl enable clamd
                freshclam
                ;;
                2)
                aur_package_install "cockpit"
                ;;
                3)
                package_install "docker"
                add_user_to_group ${username} docker
                ;;
                4)
                is_package_installed "ufw" && package_remove "ufw"
                is_package_installed "firewalld" && package_remove "firewalld"
                package_install "firewalld"
                system_ctl enable firewalld
                ;;
                5)
                package_install "gparted"
                ;;
                6)
                package_install "grsync"
                ;;
                7)
                aur_package_install "hosts-update"
                hosts-update
                ;;
                8)
                package_install "htop"
                ;;
                9)
                aur_package_install "plex-media-server"
                system_ctl enable plexmediaserver.service
                ;;
                10)
                print_title "UFW - https://wiki.archlinux.org/index.php/Ufw"
                print_info "Ufw stands for Uncomplicated Firewall, and is a program for managing a netfilter firewall. It provides a command line interface and aims to be uncomplicated and easy to use."
                is_package_installed "firewalld" && package_remove "firewalld"
                aur_package_install "ufw gufw"
                system_ctl enable ufw.service
                ;;
                11)
                aur_package_install "unified-remote-server"
                system_ctl enable urserver.service
                ;;
                12)
                #Make sure we are not a VirtualBox Guest
                VIRTUALBOX_GUEST=`dmidecode --type 1 | grep VirtualBox`
                if [[ -z ${VIRTUALBOX_GUEST} ]]; then
                    package_install "virtualbox virtualbox-guest-iso qt4"
                    aur_package_install "virtualbox-ext-oracle"
                    add_user_to_group ${username} vboxusers
                    modprobe vboxdrv vboxnetflt
                else
                    cecho "${BBlue}[${Reset}${Bold}!${BBlue}]${Reset} VirtualBox was not installed as we are a VirtualBox guest."
                fi
                ;;
                13)
                package_install "icoutils wine wine_gecko wine-mono winetricks"
                ;;
                "b")
                break
                ;;
                *)
                invalid_option
                ;;
            esac
        done
        elihw
    done
}

install_graphics_apps() {
    while true
    do
        print_title "GRAPHICS APPS"
        echo " 1) $(menu_item "blender")"
        echo " 2) $(menu_item "gimp")"
        echo " 3) $(menu_item "gthumb")"
        echo " 4) $(menu_item "inkscape")"
        echo " 5) $(menu_item "mcomix")"
        echo " 6) $(menu_item "mypaint")"
        echo " 7) $(menu_item "pencil" "Pencil Prototyping Tool") $AUR"
        echo " 8) $(menu_item "scribus")"
        echo " 9) $(menu_item "shotwell")"
        echo "10) $(menu_item "simple-scan")"
        echo ""
        echo " b) BACK"
        echo ""
        GRAPHICS_OPTIONS+=" b"
        read_input_options "$GRAPHICS_OPTIONS"
        for OPT in ${OPTIONS[@]}; do
            case "$OPT" in
                1)
                package_install "blender"
                ;;
                2)
                package_install "gimp"
                ;;
                3)
                package_install "gthumb"
                ;;
                4)
                package_install "inkscape python2-numpy python-lxml"
                ;;
                5)
                package_install "mcomix"
                ;;
                6)
                package_install "mypaint"
                ;;
                7)
                aur_package_install "pencil"
                ;;
                8)
                package_install "scribus"
                ;;
                9)
                package_install "shotwell"
                ;;
                10)
                package_install "simple-scan"
                ;;
                "b")
                break
                ;;
                *)
                invalid_option
                ;;
            esac
        done
        elihw
    done
}

install_internet_apps() {
    while true
    do
        print_title "INTERNET APPS"
        echo " 1) Browser"
        echo " 2) Download|Fileshare"
        echo " 3) Email|RSS"
        echo " 4) Instant Messaging|IRC"
        echo " 5) Mapping Tools"
        echo " 6) VNC|Desktop Share"
        echo ""
        echo " b) BACK"
        echo ""
        INTERNET_OPTIONS+=" b"
        read_input_options "$INTERNET_OPTIONS"
        for OPT in ${OPTIONS[@]}; do
            case "$OPT" in
                1)
                #BROWSER {{{
                while true
                do
                    print_title "BROWSER"
                    echo " 1) $(menu_item "google-chrome" "Chrome") $AUR"
                    echo " 2) $(menu_item "chromium")"
                    echo " 3) $(menu_item "firefox")"
                    echo " 4) $(menu_item "midori rekonq" "$([[ ${KDE} -eq 1 ]] && echo "Rekonq" || echo "Midori";)")"
                    echo " 5) $(menu_item "opera")"
                    echo ""
                    echo " b) BACK"
                    echo ""
                    BROWSERS_OPTIONS+=" b"
                    read_input_options "$BROWSERS_OPTIONS"
                    for OPT in ${OPTIONS[@]}; do
                        case "$OPT" in
                            1)
                            aur_package_install "google-chrome"
                            ;;
                            2)
                            package_install "chromium"
                            ;;
                            3)
                            package_install "firefox firefox-i18n-$LOCALE_FF firefox-adblock-plus flashplugin "
                            # speedup firefox load
                            package_install "upx"
                            upx --best /usr/lib/firefox/firefox
                            ;;
                            4)
                            if [[ ${KDE} -eq 1 ]]; then
                                package_install "rekonq"
                            else
                                package_install "midori"
                            fi
                            ;;
                            5)
                            package_install "opera"
                            ;;
                            "b")
                            break
                            ;;
                            *)
                            invalid_option
                            ;;
                        esac
                    done
                    elihw
                done
                #}}}
                OPT=1
                ;;
                2)
                #DOWNLOAD|FILESHARE {{{
                while true
                do
                    print_title "DOWNLOAD|FILESHARE"
                    echo " 1) $(menu_item "aerofs") $AUR"
                    echo " 2) $(menu_item "btsync" "BitTorrent Sync") $AUR"
                    echo " 3) $(menu_item "deluge")"
                    echo " 4) $(menu_item "dropbox") $AUR"
                    echo " 5) $(menu_item "flareget") $AUR"
                    echo " 6) $(menu_item "jdownloader") $AUR"
                    echo " 7) $(menu_item "qbittorrent") $AUR"
                    echo " 8) $(menu_item "sparkleshare")"
                    echo " 9) $(menu_item "spideroak") $AUR"
                    echo "10) $(menu_item "transmission-qt transmission-gtk" "Transmission")"
                    echo "11) $(menu_item "uget")"
                    echo "12) $(menu_item "youtube-dl")"
                    echo ""
                    echo " b) BACK"
                    echo ""
                    DOWNLOAD_OPTIONS+=" b"
                    read_input_options "$DOWNLOAD_OPTIONS"
                    for OPT in ${OPTIONS[@]}; do
                        case "$OPT" in
                            1)
                            aur_package_install "aerofs"
                            ;;
                            2)
                            aur_package_install "btsync"
                            ;;
                            3)
                            package_install "deluge"
                            ;;
                            4)
                            aur_package_install "dropbox"
                            ;;
                            5)
                            aur_package_install "flareget"
                            ;;
                            6)
                            aur_package_install "jdownloader"
                            ;;
                            7)
                            aur_package_install "qbittorrent"
                            ;;
                            8)
                            package_install "sparkleshare"
                            ;;
                            9)
                            aur_package_install "spideroak"
                            ;;
                            10)
                            if [[ ${KDE} -eq 1 ]]; then
                                package_install "transmission-qt"
                            else
                                package_install "transmission-gtk"
                            fi
                            if [[ -f /home/${username}/.config/transmission/settings.json ]]; then
                                replace_line '"blocklist-enabled": false' '"blocklist-enabled": true' /home/${username}/.config/transmission/settings.json
                                replace_line "www\.example\.com\/blocklist" "list\.iblocklist\.com\/\?list=bt_level1&fileformat=p2p&archiveformat=gz" /home/${username}/.config/transmission/settings.json
                            fi
                            ;;
                            11)
                            package_install "uget"
                            ;;
                            12)
                            package_install "youtube-dl"
                            ;;
                            "b")
                            break
                            ;;
                            *)
                            invalid_option
                            ;;
                        esac
                    done
                    elihw
                done
                #}}}
                OPT=2
                ;;
                3)
                #EMAIL {{{
                while true
                do
                    print_title "EMAIL|RSS"
                    echo " 1) $(menu_item "liferea")"
                    echo " 2) $(menu_item "thunderbird")"
                    echo ""
                    echo " b) BACK"
                    echo ""
                    EMAIL_OPTIONS+=" b"
                    read_input_options "$EMAIL_OPTIONS"
                    for OPT in ${OPTIONS[@]}; do
                        case "$OPT" in
                            1)
                            package_install "liferea"
                            ;;
                            2)
                            package_install "thunderbird thunderbird-i18n-$LOCALE_TB"
                            ;;
                            "b")
                            break
                            ;;
                            *)
                            invalid_option
                            ;;
                        esac
                    done
                    elihw
                done
                #}}}
                OPT=3
                ;;
                4)
                #IM|IRC {{{
                while true
                do
                    print_title "IM - INSTANT MESSAGING"
                    echo " 1) $(menu_item "hexchat konversation" "$([[ ${KDE} -eq 1 ]] && echo "Konversation" || echo "Hexchat";)")"
                    echo " 2) $(menu_item "irssi")"
                    echo " 3) $(menu_item "pidgin")"
                    echo " 4) $(menu_item "skype")"
                    echo " 5) $(menu_item "teamspeak3")"
                    echo " 6) $(menu_item "viber") $AUR"
                    echo " 7) $(menu_item "telegram-desktop-bin") $AUR"
                    echo " 8) $(menu_item "qtox-git") $AUR"
                    echo ""
                    echo " b) BACK"
                    echo ""
                    IM_OPTIONS+=" b"
                    read_input_options "$IM_OPTIONS"
                    for OPT in ${OPTIONS[@]}; do
                        case "$OPT" in
                            1)
                            if [[ ${KDE} -eq 1 ]]; then
                                package_install "konversation"
                            else
                                package_install "hexchat"
                            fi
                            ;;
                            2)
                            package_install "irssi"
                            ;;
                            3)
                            package_install "pidgin"
                            ;;
                            4)
                            package_install "skype"
                            ;;
                            5)
                            package_install "teamspeak3"
                            ;;
                            6)
                            aur_package_install "viber"
                            ;;
                            7)
                            aur_package_install "telegram-desktop-bin"
                            ;;
                            8)
                            aur_package_install "qtox-git"
                            ;;
                            "b")
                            break
                            ;;
                            *)
                            invalid_option
                            ;;
                        esac
                    done
                    elihw
                done
                #}}}
                OPT=4
                ;;
                5)
                #MAPPING {{{
                while true
                do
                    print_title "MAPPING TOOLS"
                    echo " 1) $(menu_item "google-earth") $AUR"
                    echo " 2) $(menu_item "worldwind" "NASA World Wind") $AUR"
                    echo ""
                    echo " b) BACK"
                    echo ""
                    MAPPING_OPTIONS+=" b"
                    read_input_options "$MAPPING_OPTIONS"
                    for OPT in ${OPTIONS[@]}; do
                        case "$OPT" in
                            1)
                            aur_package_install "google-earth"
                            ;;
                            2)
                            aur_package_install "worldwind"
                            ;;
                            "b")
                            break
                            ;;
                            *)
                            invalid_option
                            ;;
                        esac
                    done
                    elihw
                done
                #}}}
                OPT=5
                ;;
                6)
                #DESKTOP SHARE {{{
                while true
                do
                    print_title "DESKTOP SHARE"
                    echo " 1) $(menu_item "remmina")"
                    echo " 2) $(menu_item "teamviewer") $AUR"
                    echo ""
                    echo " b) BACK"
                    echo ""
                    VNC_OPTIONS+=" b"
                    read_input_options "$VNC_OPTIONS"
                    for OPT in ${OPTIONS[@]}; do
                        case "$OPT" in
                            1)
                            package_install "remmina"
                            ;;
                            2)
                            aur_package_install "teamviewer"
                            ;;
                            "b")
                            break
                            ;;
                            *)
                            invalid_option
                            ;;
                        esac
                    done
                    elihw
                done
                #}}}
                OPT=6
                ;;
                "b")
                break
                ;;
                *)
                invalid_option
                ;;
            esac
        done
        elihw
    done
}
