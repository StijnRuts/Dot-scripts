#!/usr/bin/env bash

install_development_apps() {
    while true
    do
        print_title "DEVELOPMENT APPS"
        echo " 1) $(menu_item "atom-editor-bin" "Atom")"
        echo " 2) $(menu_item "emacs")"
        echo " 3) $(menu_item "gvim")"
        echo " 4) $(menu_item "meld")"
        echo " 5) $(menu_item "android-studio" "Android Studio")"
        echo " 6) $(menu_item "intellij-idea-community-edition" "IntelliJ IDEA")"
        echo " 7) $(menu_item "monodevelop")"
        echo " 8) $(menu_item "qtcreator")"
        echo " 9) $(menu_item "mysql-workbench-gpl" "MySQL Workbench") $AUR"
        echo "10) $(menu_item "jdk7-openjdk" "OpenJDK")"
        echo "11) $(menu_item "jdk" "Oracle JDK") $AUR"
        echo "12) $(menu_item "nodejs")"
        echo ""
        echo " b) BACK"
        echo ""
        DEVELOPMENT_OPTIONS+=" b"
        read_input_options "$DEVELOPMENT_OPTIONS"
        for OPT in ${OPTIONS[@]}; do
            case "$OPT" in
                1)
                aur_package_install "atom-editor-bin"
                ;;
                2)
                package_install "emacs"
                ;;
                3)
                package_remove "vim"
                package_install "gvim ctags"
                ;;
                4)
                package_install "meld"
                ;;
                5)
                aur_package_install "android-sdk android-sdk-platform-tools android-sdk-build-tools android-platform"
                add_user_to_group ${username} sdkusers
                chown -R :sdkusers /opt/android-sdk/
                chmod -R g+w /opt/android-sdk/
                add_line "export ANDROID_HOME=/opt/android-sdk" "/home/${username}/.bashrc"
                aur_package_install "android-studio"
                ;;
                6)
                package_install "intellij-idea-community-edition"
                ;;
                7)
                package_install "monodevelop monodevelop-debugger-gdb"
                ;;
                8)
                package_install "qtcreator"
                ;;
                9)
                aur_package_install "mysql-workbench-gpl"
                ;;
                10)
                package_remove "jdk"
                package_install "jdk8-openjdk icedtea-web"
                ;;
                11)
                package_remove "jre{7,8}-openjdk"
                package_remove "jdk{7,8}-openjdk"
                aur_package_install "jdk"
                ;;
                12)
                package_install "nodejs"
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
