#!/usr/bin/env bash

LOCALE="en_US.UTF-8"
#LOCALE="nl_BE.UTF-8"
KEYMAP="be-latin1"
XKBMAP="be"
TIMEZONE="Europe/Brussels"




# Generate the chosen locale and set the language
sed -i "s/#${LOCALE}/${LOCALE}/" /etc/locale.gen
locale-gen >/dev/null 2>&1
export LANG=${LOCALE}
[[ $FONT != "" ]] && setfont $FONT



# virtual console keymap
set_keymap() {

KEYMAPS=""
for i in $(ls -R /usr/share/kbd/keymaps | grep "map.gz" | sed 's/\.map\.gz//g' | sort); do
    KEYMAPS="${KEYMAPS} ${i} -"
done

dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_VCKeymapTitle " \
--menu "$_VCKeymapBody" 20 40 16 ${KEYMAPS} 2>${ANSWER} || prep_menu
KEYMAP=$(cat ${ANSWER})

loadkeys $KEYMAP 2>/tmp/.errlog
check_for_error

echo -e "KEYMAP=${KEYMAP}\nFONT=${FONT}" > /tmp/vconsole.conf
}

# Set keymap for X11
set_xkbmap() {

    XKBMAP_LIST=""
    keymaps_xkb=("af al am at az ba bd be bg br bt bw by ca cd ch cm cn cz de dk ee es et eu fi fo fr gb ge gh gn gr hr hu ie il in iq ir is it jp ke kg kh kr kz la lk lt lv ma md me mk ml mm mn mt mv ng nl no np pc ph pk pl pt ro rs ru se si sk sn sy tg th tj tm tr tw tz ua us uz vn za")

    for i in ${keymaps_xkb}; do
        XKBMAP_LIST="${XKBMAP_LIST} ${i} -"
    done

    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_PrepKBLayout " --menu "$_XkbmapBody" 0 0 16 ${XKBMAP_LIST} 2>${ANSWER} || install_graphics_menu
    XKBMAP=$(cat ${ANSWER} |sed 's/_.*//')
    echo -e "Section "\"InputClass"\"\nIdentifier "\"system-keyboard"\"\nMatchIsKeyboard "\"on"\"\nOption "\"XkbLayout"\" "\"${XKBMAP}"\"\nEndSection" > ${MOUNTPOINT}/etc/X11/xorg.conf.d/00-keyboard.conf

}

# locale array generation code adapted from the Manjaro 0.8 installer
set_locale() {

    LOCALES=""
    for i in $(cat /etc/locale.gen | grep -v "#  " | sed 's/#//g' | sed 's/ UTF-8//g' | grep .UTF-8); do
        LOCALES="${LOCALES} ${i} -"
    done

    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_ConfBseSysLoc " --menu "$_localeBody" 0 0 12 ${LOCALES} 2>${ANSWER} || config_base_menu

    LOCALE=$(cat ${ANSWER})

    echo "LANG=\"${LOCALE}\"" > ${MOUNTPOINT}/etc/locale.conf
    sed -i "s/#${LOCALE}/${LOCALE}/" ${MOUNTPOINT}/etc/locale.gen 2>/tmp/.errlog
    arch_chroot "locale-gen" >/dev/null 2>>/tmp/.errlog
    check_for_error
}

# Set Zone and Sub-Zone
set_timezone() {

    ZONE=""
    for i in $(cat /usr/share/zoneinfo/zone.tab | awk '{print $3}' | grep "/" | sed "s/\/.*//g" | sort -ud); do
        ZONE="$ZONE ${i} -"
    done

    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_ConfBseTimeHC " --menu "$_TimeZBody" 0 0 10 ${ZONE} 2>${ANSWER} || config_base_menu
    ZONE=$(cat ${ANSWER})

    SUBZONE=""
    for i in $(cat /usr/share/zoneinfo/zone.tab | awk '{print $3}' | grep "${ZONE}/" | sed "s/${ZONE}\///g" | sort -ud); do
        SUBZONE="$SUBZONE ${i} -"
    done

    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_ConfBseTimeHC " --menu "$_TimeSubZBody" 0 0 11 ${SUBZONE} 2>${ANSWER} || config_base_menu
    SUBZONE=$(cat ${ANSWER})

    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_ConfBseTimeHC " --yesno "$_TimeZQ ${ZONE}/${SUBZONE}?" 0 0

    if [[ $? -eq 0 ]]; then
        arch_chroot "ln -s /usr/share/zoneinfo/${ZONE}/${SUBZONE} /etc/localtime" 2>/tmp/.errlog
        check_for_error
    else
        config_base_menu
    fi
}

set_hw_clock() {

    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_ConfBseTimeHC " --menu "$_HwCBody" 0 0 2 \
    "utc" "-" "localtime" "-" 2>${ANSWER}

    [[ $(cat ${ANSWER}) != "" ]] && arch_chroot "hwclock --systohc --$(cat ${ANSWER})"  2>/tmp/.errlog && check_for_error
}


setlocale() {
    local _locale_list=(`cat /etc/locale.gen | grep UTF-8 | sed 's/\..*$//' | sed '/@/d' | awk '{print $1}' | uniq | sed 's/#//g'`);
    PS3="$prompt1"
    echo "Select locale:"
    select LOCALE in "${_locale_list[@]}"; do
        if contains_element "$LOCALE" "${_locale_list[@]}"; then
            LOCALE_UTF8="${LOCALE}.UTF-8"
            break
        else
            invalid_option
        fi
    done
}

settimezone() {
    local _zones=(`timedatectl list-timezones | sed 's/\/.*$//' | uniq`)
    PS3="$prompt1"
    echo "Select zone:"
    select ZONE in "${_zones[@]}"; do
        if contains_element "$ZONE" "${_zones[@]}"; then
            local _subzones=(`timedatectl list-timezones | grep ${ZONE} | sed 's/^.*\///'`)
            PS3="$prompt1"
            echo "Select subzone:"
            select SUBZONE in "${_subzones[@]}"; do
                if contains_element "$SUBZONE" "${_subzones[@]}"; then
                    break
                else
                    invalid_option
                fi
            done
            break
        else
            invalid_option
        fi
    done
}
