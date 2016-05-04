#!/usr/bin/env bash

add_line() {
    local _add_line=${1}
    local _filepath=${2}

    local _has_line=`grep -ci "${_add_line}" ${_filepath} 2>&1`
    [[ $_has_line -eq 0 ]] && echo "${_add_line}" >> ${_filepath}
}

replace_line() {
    local _search=${1}
    local _replace=${2}
    local _filepath=${3}
    local _filebase=`basename ${3}`

    sed -e "s/${_search}/${_replace}/" ${_filepath} > /tmp/${_filebase} 2>"$LOG"
    if [[ ${?} -eq 0 ]]; then
        mv /tmp/${_filebase} ${_filepath}
    else
        cecho "failed: ${_search} - ${_filepath}"
    fi
}

is_package_installed() {
    # check if a package is already installed
    for PKG in $1; do
        pacman -Q $PKG &> /dev/null && return 0;
    done
    return 1
}

aui_download_packages() {
    for PKG in $1; do
        # exec command as user instead of root
        su - ${username} -c "
        [[ ! -d aui_packages ]] && mkdir aui_packages
        cd aui_packages
        curl -o ${PKG}.tar.gz https://aur.archlinux.org/cgit/aur.git/snapshot/${PKG}.tar.gz
        tar zxvf ${PKG}.tar.gz
        rm ${PKG}.tar.gz
        cd ${PKG}
        makepkg -csi --noconfirm
        "
    done
}

aur_package_install() {
    su - ${username} -c "sudo -v"
    # install package from aur
    for PKG in $1; do
        if ! is_package_installed "${PKG}" ; then
            if [[ $AUTOMATIC_MODE -eq 1 ]]; then
                ncecho " ${BBlue}[${Reset}${Bold}X${BBlue}]${Reset} Installing ${AUR} ${Bold}${PKG}${Reset} "
                su - ${username} -c "${AUR_PKG_MANAGER} --noconfirm -S ${PKG}" >>"$LOG" 2>&1 &
                pid=$!;progress $pid
            else
                su - ${username} -c "${AUR_PKG_MANAGER} -S ${PKG}"
            fi
        else
            if [[ $VERBOSE_MODE -eq 0 ]]; then
                cecho " ${BBlue}[${Reset}${Bold}X${BBlue}]${Reset} Installing ${AUR} ${Bold}${PKG}${Reset} success"
            else
                echo -e "Warning: ${PKG} is up to date --skipping"
            fi
        fi
    done
}

package_install() {
    # install packages using pacman
    if [[ $AUTOMATIC_MODE -eq 1 || $VERBOSE_MODE -eq 0 ]]; then
        for PKG in ${1}; do
            local _pkg_repo=`pacman -Sp --print-format %r ${PKG} | uniq | sed '1!d'`
            case $_pkg_repo in
                "core")
                _pkg_repo="${BRed}${_pkg_repo}${Reset}"
                ;;
                "extra")
                _pkg_repo="${BYellow}${_pkg_repo}${Reset}"
                ;;
                "community")
                _pkg_repo="${BGreen}${_pkg_repo}${Reset}"
                ;;
                "multilib")
                _pkg_repo="${BCyan}${_pkg_repo}${Reset}"
                ;;
            esac
            if ! is_package_installed "${PKG}" ; then
                ncecho " ${BBlue}[${Reset}${Bold}X${BBlue}]${Reset} Installing (${_pkg_repo}) ${Bold}${PKG}${Reset} "
                pacman -S --noconfirm --needed ${PKG} >>"$LOG" 2>&1 &
                pid=$!;progress $pid
            else
                cecho " ${BBlue}[${Reset}${Bold}X${BBlue}]${Reset} Installing (${_pkg_repo}) ${Bold}${PKG}${Reset} exists "
            fi
        done
    else
        pacman -S --needed ${1}
    fi
}

package_remove() {
    #remove package
    for PKG in ${1}; do
        if is_package_installed "${PKG}" ; then
            if [[ $AUTOMATIC_MODE -eq 1 || $VERBOSE_MODE -eq 0 ]]; then
                ncecho " ${BBlue}[${Reset}${Bold}X${BBlue}]${Reset} Removing ${Bold}${PKG}${Reset} "
                pacman -Rcsn --noconfirm ${PKG} >>"$LOG" 2>&1 &
                pid=$!;progress $pid
            else
                pacman -Rcsn ${PKG}
            fi
        fi
    done
}

system_update() {
    pacman -Sy
}

clean_orphan_packages() {
    print_title "CLEAN ORPHAN PACKAGES"
    pacman -Rsc --noconfirm $(pacman -Qqdt)
    #pacman -Sc --noconfirm
    pacman-optimize
}
