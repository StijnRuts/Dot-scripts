#!/usr/bin/env bash

main_menu() {

    if [[ $HIGHLIGHT != 9 ]]; then
        HIGHLIGHT=$(( HIGHLIGHT + 1 ))
    fi

    dialog --default-item ${HIGHLIGHT} --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_MMTitle " \
    --menu "$_MMBody" 0 0 9 \
    "1" "$_PrepMenuTitle" \
    "2" "$_InstBsMenuTitle" \
    "3" "$_ConfBseMenuTitle" \
    "4" "$_InstGrMenuTitle" \
    "5" "$_InstNMMenuTitle" \
    "6" "$_InstMultMenuTitle" \
    "7" "$_SecMenuTitle" \
    "8" "$_SeeConfOptTitle" \
    "9" "$_Done" 2>${ANSWER}

    HIGHLIGHT=$(cat ${ANSWER})

    # Depending on the answer, first check whether partition(s) are mounted and whether base has been installed
    if [[ $(cat ${ANSWER}) -eq 2 ]]; then
        check_mount
    fi

    if [[ $(cat ${ANSWER}) -ge 3 ]] && [[ $(cat ${ANSWER}) -le 8 ]]; then
        check_mount
        check_base
    fi

    case $(cat ${ANSWER}) in
        "1") prep_menu
        ;;
        "2") install_base_menu
        ;;
        "3") config_base_menu
        ;;
        "4") install_graphics_menu
        ;;
        "5") install_network_menu
        ;;
        "6") install_multimedia_menu
        ;;
        "7") security_menu
        ;;
        "8") edit_configs
        ;;
        *) dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --yesno "$_CloseInstBody" 0 0

        if [[ $? -eq 0 ]]; then
            umount_partitions
            clear
            exit 0
        else
            main_menu
        fi

        ;;
    esac

}

# Execution
while true; do
    main_menu
done
