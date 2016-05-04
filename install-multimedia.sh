#!/usr/bin/env bash

install_multimedia_menu() {

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

install_audio_apps(){
    while true
    do
        print_title "AUDIO APPS"
        echo " 1) Players"
        echo " 2) Editors|Tools"
        echo " 3) Codecs"
        echo ""
        echo " b) BACK"
        echo ""
        AUDIO_OPTIONS+=" b"
        read_input_options "$AUDIO_OPTIONS"
        for OPT in ${OPTIONS[@]}; do
            case "$OPT" in
                1)
                #PLAYERS {{{
                while true
                do
                    print_title "AUDIO PLAYERS"
                    echo " 1) $(menu_item "amarok")"
                    echo " 2) $(menu_item "audacious")"
                    echo " 3) $(menu_item "banshee")"
                    echo " 4) $(menu_item "clementine")"
                    echo " 5) $(menu_item "deadbeef")"
                    echo " 6) $(menu_item "guayadeque")"
                    echo " 7) $(menu_item "musique") $AUR"
                    echo " 8) $(menu_item "nuvolaplayer") $AUR"
                    echo " 9) $(menu_item "pragha")"
                    echo "10) $(menu_item "radiotray") $AUR"
                    echo "11) $(menu_item "rhythmbox")"
                    echo "12) $(menu_item "spotify") $AUR"
                    echo "13) $(menu_item "timidity++")"
                    echo "14) $(menu_item "tomahawk") $AUR"
                    echo "15) $(menu_item "quodlibet")"
                    echo ""
                    echo " b) BACK"
                    echo ""
                    AUDIO_PLAYER_OPTIONS+=" b"
                    read_input_options "$AUDIO_PLAYER_OPTIONS"
                    for OPT in ${OPTIONS[@]}; do
                        case "$OPT" in
                            1)
                            package_install "amarok"
                            ;;
                            2)
                            package_install "audacious audacious-plugins"
                            ;;
                            3)
                            package_install "banshee"
                            ;;
                            4)
                            package_install "clementine"
                            ;;
                            5)
                            package_install "deadbeef"
                            ;;
                            6)
                            package_install "guayadeque"
                            ;;
                            7)
                            aur_package_install "musique"
                            ;;
                            8)
                            aur_package_install "nuvolaplayer"
                            ;;
                            9)
                            package_install "pragha"
                            ;;
                            10)
                            aur_package_install "radiotray"
                            ;;
                            11)
                            package_install "rhythmbox grilo grilo-plugins libgpod libdmapsharing gnome-python python-mako pywebkitgtk"
                            ;;
                            12)
                            aur_package_install "spotify"
                            ;;
                            13)
                            aur_package_install "timidity++ fluidr3"
                            echo -e 'soundfont /usr/share/soundfonts/fluidr3/FluidR3GM.SF2' >> /etc/timidity++/timidity.cfg
                            ;;
                            14)
                            aur_package_install "tomahawk"
                            ;;
                            15)
                            package_install "quodlibet"
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
                #EDITORS {{{
                while true
                do
                    print_title "AUDIO EDITORS|TOOLS"
                    echo " 1) $(menu_item "audacity")"
                    echo " 2) $(menu_item "easytag")"
                    echo " 3) $(menu_item "ocenaudio-bin") $AUR"
                    echo " 4) $(menu_item "soundconverter soundkonverter" "$([[ ${KDE} -eq 1 ]] && echo "Soundkonverter" || echo "Soundconverter";)")"
                    echo ""
                    echo " b) BACK"
                    echo ""
                    AUDIO_EDITOR_OPTIONS+=" b"
                    read_input_options "$AUDIO_EDITOR_OPTIONS"
                    for OPT in ${OPTIONS[@]}; do
                        case "$OPT" in
                            1)
                            package_install "audacity"
                            ;;
                            2)
                            package_install "easytag"
                            ;;
                            3)
                            aur_package_install "ocenaudio-bin"
                            ;;
                            4)
                            if [[ ${KDE} -eq 1 ]]; then
                                package_install "soundkonverter"
                            else
                                package_install "soundconverter"
                            fi
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
                package_install "gst-plugins-base gst-plugins-base-libs gst-plugins-good \
                gst-plugins-bad gst-plugins-ugly gst-libav"
                [[ ${KDE} -eq 1 ]] && package_install "phonon-qt5-gstreamer"
                # Use the 'standard' preset by default. This preset should generally be
                # transparent to most people on most music and is already quite high in quality.
                # The resulting bitrate should be in the 170-210kbps range, according to music
                # complexity.
                run_as_user "gconftool-2 --type string --set /system/gstreamer/0.10/audio/profiles/mp3/pipeline \audio/x-raw-int,rate=44100,channels=2 ! lame name=enc preset=1001 ! id3v2mux\""
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

install_video_apps(){
    while true
    do
        print_title "VIDEO APPS"
        echo " 1) Players"
        echo " 2) Editors|Tools"
        echo " 3) Codecs"
        echo ""
        echo " b) BACK"
        echo ""
        VIDEO_OPTIONS+=" b"
        read_input_options "$VIDEO_OPTIONS"
        for OPT in ${OPTIONS[@]}; do
            case "$OPT" in
                1)
                #PLAYERS {{{
                while true
                do
                    print_title "VIDEO PLAYERS"
                    echo " 1) $(menu_item "gnome-mplayer")"
                    echo " 2) $(menu_item "livestreamer")"
                    echo " 3) $(menu_item "minitube")"
                    echo " 4) $(menu_item "miro") $AUR"
                    echo " 5) $(menu_item "mpv")"
                    echo " 6) $(menu_item "parole")"
                    echo " 7) $(menu_item "popcorntime-ce") $AUR"
                    echo " 8) $(menu_item "vlc")"
                    echo " 9) $(menu_item "kodi")"
                    echo ""
                    echo " b) BACK"
                    echo ""
                    VIDEO_PLAYER_OPTIONS+=" b"
                    read_input_options "$VIDEO_PLAYER_OPTIONS"
                    for OPT in ${OPTIONS[@]}; do
                        case "$OPT" in
                            1)
                            package_install "gnome-mplayer"
                            ;;
                            2)
                            package_install "livestreamer"
                            ;;
                            3)
                            package_install "minitube"
                            ;;
                            4)
                            aur_package_install "miro"
                            ;;
                            5)
                            package_install "mpv"
                            ;;
                            6)
                            package_install "parole"
                            ;;
                            7)
                            aur_package_install "popcorntime-ce"
                            ;;
                            8)
                            package_install "vlc"
                            [[ ${KDE} -eq 1 ]] && package_install "phonon-qt5-vlc"
                            ;;
                            9)
                            package_install "kodi"
                            add_user_to_group ${username} kodi
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
                #EDITORS {{{
                while true
                do
                    print_title "VIDEO EDITORS|TOOLS"
                    echo " 1) $(menu_item "arista")"
                    echo " 2) $(menu_item "avidemux-gtk avidemux-qt" "Avidemux")"
                    echo " 3) $(menu_item "filebot") $AUR"
                    echo " 4) $(menu_item "handbrake")"
                    echo " 5) $(menu_item "kazam") $AUR"
                    echo " 6) $(menu_item "kdeenlive")"
                    echo " 7) $(menu_item "lwks" "Lightworks") $AUR"
                    echo " 8) $(menu_item "openshot")"
                    echo " 9) $(menu_item "pitivi")"
                    echo "10) $(menu_item "transmageddon")"
                    echo ""
                    echo " b) BACK"
                    echo ""
                    VIDEO_EDITOR_OPTIONS+=" b"
                    read_input_options "$VIDEO_EDITOR_OPTIONS"
                    for OPT in ${OPTIONS[@]}; do
                        case "$OPT" in
                            1)
                            package_install "arista"
                            ;;
                            2)
                            if [[ ${KDE} -eq 1 ]]; then
                                package_install "avidemux-qt"
                            else
                                package_install "avidemux-gtk"
                            fi
                            ;;
                            3)
                            aur_package_install "filebot"
                            ;;
                            4)
                            package_install "handbrake"
                            ;;
                            5)
                            aur_package_install "kazam"
                            ;;
                            6)
                            package_install "kdenlive"
                            ;;
                            7)
                            aur_package_install "lwks"
                            ;;
                            8)
                            package_install "openshot"
                            ;;
                            9)
                            package_install "pitivi frei0r-plugins"
                            ;;
                            10)
                            package_install "transmageddon"
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
                package_install "libquicktime libdvdnav libdvdcss cdrdao"
                aur_package_install "libaacs"
                if [[ $ARCHI == i686 ]]; then
                    aur_package_install "codecs"
                else
                    aur_package_install "codecs64"
                fi
                package_install "ffmpeg"
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
