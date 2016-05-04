#!/usr/bin/env bash

install_multimedia_menu(){

    install_alsa_pulse(){
        # Prep Variables
        echo "" > ${PACKAGES}
        ALSA=""
        PULSE_EXTRA=""
        alsa=$(pacman -Ss alsa | awk '{print $1}' | grep "/alsa-" | sed "s/extra\///g" | sort -u)
        pulse_extra=$(pacman -Ss pulseaudio- | awk '{print $1}' | sed "s/extra\///g" | grep "pulseaudio-" | sort -u)

        for i in ${alsa}; do
            ALSA="${ALSA} ${i} - off"
        done

        ALSA=$(echo $ALSA | sed "s/alsa-utils - off/alsa-utils - on/g" | sed "s/alsa-plugins - off/alsa-plugins - on/g")

        for i in ${pulse_extra}; do
            PULSE_EXTRA="${PULSE_EXTRA} ${i} - off"
        done

        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_InstMulSnd " --checklist "$_InstMulSndBody\n\n$_UseSpaceBar" 0 0 14 \
        $ALSA "pulseaudio" "-" off $PULSE_EXTRA \
        "paprefs" "pulseaudio GUI" off \
        "pavucontrol" "pulseaudio GUI" off \
        "ponymix" "pulseaudio CLI" off \
        "volumeicon" "ALSA GUI" off \
        "volwheel" "ASLA GUI" off 2>${PACKAGES}

        clear
        # If at least one package, install.
        if [[ $(cat ${PACKAGES}) != "" ]]; then
            pacstrap ${MOUNTPOINT} $(cat ${PACKAGES}) 2>/tmp/.errlog
            check_for_error
        fi

    }

    install_codecs(){

        # Prep Variables
        echo "" > ${PACKAGES}
        GSTREAMER=""
        gstreamer=$(pacman -Ss gstreamer | awk '{print $1}' | grep "/gstreamer" | sed "s/extra\///g" | sed "s/community\///g" | sort -u)
        echo $gstreamer
        for i in ${gstreamer}; do
            GSTREAMER="${GSTREAMER} ${i} - off"
        done

        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_InstMulCodec " --checklist "$_InstMulCodBody$_UseSpaceBar" 0 0 14 \
        $GSTREAMER "xine-lib" "-" off 2>${PACKAGES}

        # If at least one package, install.
        if [[ $(cat ${PACKAGES}) != "" ]]; then
            pacstrap ${MOUNTPOINT} $(cat ${PACKAGES}) 2>/tmp/.errlog
            check_for_error
        fi

    }

    install_cust_pkgs(){
        echo "" > ${PACKAGES}
        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_InstMulCust " --inputbox "$_InstMulCustBody" 0 0 "" 2>${PACKAGES} || install_multimedia_menu

        clear
        # If at least one package, install.
        if [[ $(cat ${PACKAGES}) != "" ]]; then
            if [[ $(cat ${PACKAGES}) == "hen poem" ]]; then
                dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " \"My Sweet Buckies\" by Atiya & Carl " --msgbox "\nMy Sweet Buckies,\nYou are the sweetest Buckies that ever did \"buck\",\nLily, Rosie, Trumpet, and Flute,\nMy love for you all is absolute!\n\nThey buck: \"We love our treats, we are the Booyakka sisters,\"\n\"Sometimes we squabble and give each other comb-twisters,\"\n\"And in our garden we love to sunbathe, forage, hop and jump,\"\n\"We love our freedom far, far away from that factory farm dump,\"\n\n\"For so long we were trapped in cramped prisons full of disease,\"\n\"No sunlight, no fresh air, no one who cared for even our basic needs,\"\n\"We suffered in fear, pain, and misery for such a long time,\"\n\"But now we are so happy, we wanted to tell you in this rhyme!\"\n\n" 0 0
            else
                pacstrap ${MOUNTPOINT} $(cat ${PACKAGES}) 2>/tmp/.errlog
                check_for_error
            fi
        fi

    }

    if [[ $SUB_MENU != "install_multimedia_menu" ]]; then
        SUB_MENU="install_multimedia_menu"
        HIGHLIGHT_SUB=1
    else
        if [[ $HIGHLIGHT_SUB != 5 ]]; then
            HIGHLIGHT_SUB=$(( HIGHLIGHT_SUB + 1 ))
        fi
    fi

    dialog --default-item ${HIGHLIGHT_SUB} --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_InstMultMenuTitle " --menu "$_InstMultMenuBody" 0 0 5 \
    "1" "$_InstMulSnd" \
    "2" "$_InstMulCodec" \
    "3" "$_InstMulAcc" \
    "4" "$_InstMulCust" \
    "5" "$_Back" 2>${ANSWER}

    HIGHLIGHT_SUB=$(cat ${ANSWER})
    case $(cat ${ANSWER}) in
        "1") install_alsa_pulse
        ;;
        "2") install_codecs
        ;;
        "3") install_acc_menu
        ;;
        "4") install_cust_pkgs
        ;;
        *) main_menu_online
        ;;
    esac

    install_multimedia_menu
}
