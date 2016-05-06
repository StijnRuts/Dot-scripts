#!/usr/bin/env bash

font_config() {
    while true
    do
        print_title "FONTS CONFIGURATION - https://wiki.archlinux.org/index.php/Font_Configuration"
        print_info "Fontconfig is a library designed to provide a list of available fonts to applications, and also for configuration for how fonts get rendered."
        echo " 1) Default"
        echo " 2) Infinality"
        echo " 3) Ubuntu ${AUR}"
        echo ""
        read_input $FONTCONFIG
        case "$OPTION" in
            1)
            is_package_installed "fontconfig-ubuntu" && pacman -Rdds freetype2-ubuntu fontconfig-ubuntu cairo-ubuntu
            is_package_installed "fontconfig-infinality-ultimate" && pacman -Rdds --noconfirm fontconfig-infinality-ultimate freetype2-infinality-ultimate cairo-infinality-ultimate
            if [[ $ARCHI == x86_64 ]]; then
                is_package_installed "lib32-fontconfig-infinality-ultimate" && pacman -Rdds --noconfirm lib32-cairo-infinality-ultimate lib32-fontconfig-infinality-ultimate lib32-freetype2-infinality-ultimate
            fi
            pacman -S --asdeps --needed cairo fontconfig freetype2
            break
            ;;
            2)
            print_title "INFINALITY - https://wiki.archlinux.org/index.php/Infinality-bundle%2Bfonts"
            add_key "962DDE58"
            add_repository "infinality-bundle" "http://bohoomil.com/repo/\$arch" "Never"
            [[ $ARCHI == x86_64 ]] && add_repository "infinality-bundle-multilib" "http://bohoomil.com/repo/multilib/\$arch" "Never"
            is_package_installed "freetype2" && pacman -Rdds --noconfirm freetype2 fontconfig cairo
            is_package_installed "freetype2-ubuntu" && pacman -Rdds freetype2-ubuntu fontconfig-ubuntu cairo-ubuntu
            pacman -S --needed infinality-bundle
            [[ $ARCHI == x86_64 ]] && pacman -S --needed infinality-bundle-multilib
            break
            ;;
            3)
            is_package_installed "fontconfig" && pacman -Rdds freetype2 fontconfig cairo
            aur_package_install "freetype2-ubuntu fontconfig-ubuntu cairo-ubuntu"
            break
            ;;
            *)
            invalid_option
            ;;
        esac
    done
    pause_function
}

install_fonts() {
    while true
    do
        print_title "FONTS - https://wiki.archlinux.org/index.php/Fonts"
        echo " 1) $(menu_item "ttf-dejavu")"
        echo " 2) $(menu_item "ttf-funfonts") $AUR"
        echo " 3) $(menu_item "ttf-google-fonts-git") $AUR"
        echo " 4) $(menu_item "ttf-liberation")"
        echo " 5) $(menu_item "ttf-ms-fonts") $AUR"
        echo " 6) $(menu_item "ttf-vista-fonts") $AUR"
        echo " 7) $(menu_item "wqy-microhei") (Chinese/Japanese/Korean Support)"
        echo ""
        echo " b) BACK"
        echo ""
        FONTS_OPTIONS+=" b"
        read_input_options "$FONTS_OPTIONS"
        for OPT in ${OPTIONS[@]}; do
            case "$OPT" in
                1)
                package_install "ttf-dejavu"
                ;;
                2)
                aur_package_install "ttf-funfonts"
                ;;
                3)
                package_remove "ttf-droid"
                package_remove "ttf-roboto"
                package_remove "ttf-ubuntu-font-family"
                package_remove "otf-oswald-ib"
                aur_package_install "ttf-google-fonts-git"
                ;;
                4)
                package_install "ttf-liberation"
                ;;
                5)
                aur_package_install "ttf-ms-fonts"
                ;;
                6)
                aur_package_install "ttf-vista-fonts"
                ;;
                7)
                package_install "wqy-microhei"
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
