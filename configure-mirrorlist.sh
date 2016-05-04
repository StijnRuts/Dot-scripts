#!/usr/bin/env bash

package_install "haveged"
haveged -w 1024
pacman-key --init
pacman-key --populate archlinux
pkill haveged
package_remove "haveged"

pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys

# Originally adapted from AIS. Added option to allow users to edit the mirrorlist.
configure_mirrorlist() {

    # Generate a mirrorlist based on the country chosen.
    mirror_by_country() {

        COUNTRY_LIST=""
        countries_list="AU Australia AT Austria BA Bosnia_Herzegovina BY Belarus BE Belgium BR Brazil BG Bulgaria CA Canada CL Chile CN China CO Colombia CZ Czech_Republic DK Denmark EE Estonia FI Finland FR France DE Germany GB United_Kingdom GR Greece HU Hungary IN India IE Ireland IL Israel IT Italy JP Japan KZ Kazakhstan KR Korea LT Lithuania LV Latvia LU Luxembourg MK Macedonia NL Netherlands NC New_Caledonia NZ New_Zealand NO Norway PL Poland PT Portugal RO Romania RU Russia RS Serbia SG Singapore SK Slovakia ZA South_Africa ES Spain LK Sri_Lanka SE Sweden CH Switzerland TW Taiwan TR Turkey UA Ukraine US United_States UZ Uzbekistan VN Vietnam"

        for i in ${countries_list}; do
            COUNTRY_LIST="${COUNTRY_LIST} ${i}"
        done

        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_MirrorlistTitle " --menu "$_MirrorCntryBody" 0 0 0 $COUNTRY_LIST 2>${ANSWER} || install_base_menu

        URL="https://www.archlinux.org/mirrorlist/?country=$(cat ${ANSWER})&use_mirror_status=on"
        MIRROR_TEMP=$(mktemp --suffix=-mirrorlist)

        # Get latest mirror list and save to tmpfile
        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_MirrorlistTitle " --infobox "$_PlsWaitBody" 0 0

        curl -so ${MIRROR_TEMP} ${URL} 2>/tmp/.errlog
        check_for_error
        sed -i 's/^#Server/Server/g' ${MIRROR_TEMP}
        nano ${MIRROR_TEMP}

        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_MirrorlistTitle " --yesno "$_MirrorGenQ" 0 0

        if [[ $? -eq 0 ]];then
            mv -f /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig
            mv -f ${MIRROR_TEMP} /etc/pacman.d/mirrorlist
            chmod +r /etc/pacman.d/mirrorlist
            dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_MirrorlistTitle " --infobox "\n$_Done!\n\n" 0 0
            sleep 2
        else
            configure_mirrorlist
        fi
    }


    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_MirrorlistTitle " \
    --menu "$_MirrorlistBody" 0 0 6 \
    "1" "$_MirrorbyCountry" \
    "2" "$_MirrorRankTitle" \
    "3" "$_MirrorEdit" \
    "4" "$_MirrorRestTitle" \
    "5" "$_MirrorPacman" \
    "6" "$_Back" 2>${ANSWER}

    case $(cat ${ANSWER}) in
        "1") mirror_by_country
        ;;
        "2") dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_MirrorlistTitle " --infobox "$_MirrorRankBody $_PlsWaitBody" 0 0
        cp -f /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
        rankmirrors -n 10 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist 2>/tmp/.errlog
        check_for_error
        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_MirrorlistTitle " --infobox "\n$_Done!\n\n" 0 0
        sleep 2
        ;;
        "3") nano /etc/pacman.d/mirrorlist
        ;;
        "4") if [[ -e /etc/pacman.d/mirrorlist.orig ]]; then
        mv -f /etc/pacman.d/mirrorlist.orig /etc/pacman.d/mirrorlist
        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_MirrorlistTitle " --msgbox "\n$_Done!\n\n" 0 0
    else
        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_ErrTitle " --msgbox "$_MirrorNoneBody" 0 0
    fi
    ;;
    "5") nano /etc/pacman.conf
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_MirrorPacman " --yesno "$_MIrrorPacQ" 0 0 && COPY_PACCONF=1 || COPY_PACCONF=0
    pacman -Syy
    ;;
    *) install_base_menu
    ;;
esac

configure_mirrorlist
}
