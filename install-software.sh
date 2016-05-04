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
