#!/usr/bin/env bash

install_cups() {
    print_title "CUPS - https://wiki.archlinux.org/index.php/Cups"
    print_info "CUPS is the standards-based, open source printing system developed by Apple Inc. for Mac OS X and other UNIX-like operating systems."
    read_input_text "Install CUPS (aka Common Unix Printing System)" $CUPS
    if [[ $OPTION == y ]]; then
        package_install "cups cups-filters ghostscript gsfonts"
        package_install "gutenprint foomatic-db foomatic-db-engine foomatic-db-nonfree foomatic-filters foomatic-db-ppds foomatic-db-nonfree-ppds plip splix cups-pdf"
        package_install "system-config-printer"
        system_ctl enable org.cups.cupsd
        pause_function
    fi
}
