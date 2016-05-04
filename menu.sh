#!/usr/bin/env bash
source shared_function.sh

setup() {
    package_install "dialog"

    ANSWER="/tmp/dot-scripts"
    HIGHLIGHT=0
}

main_menu() {
    if [[ $HIGHLIGHT != 12 ]]; then
        HIGHLIGHT=$(( HIGHLIGHT + 1 ))
    fi

    dialog --default-item ${HIGHLIGHT} \
        --menu "Dot-scripts" 0 0 12 \
        "1"  "Set locales" \
        "2"  "Configure mirrorlist" \
        "3"  "Create new user" \
        "4"  "Install AUR helper" \
        "5"  "Install Xorg" \
        "6"  "Install fonts" \
        "7"  "Install desktop" \
        "8"  "Install networking" \
        "9"  "Install multimedia" \
        "10" "Install CUPS" \
        "11" "Install general software" \
        "12" "Install development software" \
    2>${ANSWER}

    case $(cat ${ANSWER}) in
        "1") sh set-locales.sh ;;
        "2") sh configure-mirrorlist.sh ;;
        "3") sh create-new-user.sh ;;
        "4") sh install-aur-helper.sh ;;
        "5") sh install-xorg.sh ;;
        "6") sh install-fonts.sh ;;
        "7") sh install-desktop.sh ;;
        "8") sh install-networking.sh ;;
        "9") sh install-multimedia.sh ;;
        "10") sh install-cups.sh ;;
        "11") sh install-general-software.sh ;;
        "12") sh install-development-software.sh ;;
        *) clear; echo "Thank you for using Dot-scripts"; exit ;;
    esac

    HIGHLIGHT=$(cat ${ANSWER})
    main_menu
}


# Execution
setup
main_menu
