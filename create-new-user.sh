#!/usr/bin/env bash

add_user_to_group() {
    local _user=${1}
    local _group=${2}

    if [[ -z ${_group} ]]; then
        error_msg "ERROR! 'add_user_to_group' was not given enough parameters."
    fi

    ncecho " ${BBlue}[${Reset}${Bold}X${BBlue}]${Reset} Adding ${Bold}${_user}${Reset} to ${Bold}${_group}${Reset} "
    groupadd ${_group} >>"$LOG" 2>&1 &
    gpasswd -a ${_user} ${_group} >>"$LOG" 2>&1 &
    pid=$!;progress $pid
}

# Originally adapted from the Antergos 2.0 installer
create_new_user() {

    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_NUsrTitle " --inputbox "$_NUsrBody" 0 0 "" 2>${ANSWER} || config_base_menu
    USER=$(cat ${ANSWER})

    # Loop while user name is blank, has spaces, or has capital letters in it.
    while [[ ${#USER} -eq 0 ]] || [[ $USER =~ \ |\' ]] || [[ $USER =~ [^a-z0-9\ ] ]]; do
        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_NUsrTitle " --inputbox "$_NUsrErrBody" 0 0 "" 2>${ANSWER} || config_base_menu
        USER=$(cat ${ANSWER})
    done

    # Enter password. This step will only be reached where the loop has been skipped or broken.
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_ConfUsrNew " --clear --insecure --passwordbox "$_PassNUsrBody $USER\n\n" 0 0 2> ${ANSWER} || config_base_menu
    PASSWD=$(cat ${ANSWER})

    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_ConfUsrNew " --clear --insecure --passwordbox "$_PassReEntBody" 0 0 2> ${ANSWER} || config_base_menu
    PASSWD2=$(cat ${ANSWER})

    # loop while passwords entered do not match.
    while [[ $PASSWD != $PASSWD2 ]]; do
        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_ErrTitle " --msgbox "$_PassErrBody" 0 0

        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_ConfUsrNew " --clear --insecure --passwordbox "$_PassNUsrBody $USER\n\n" 0 0 2> ${ANSWER} || config_base_menu
        PASSWD=$(cat ${ANSWER})

        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_ConfUsrNew " --clear --insecure --passwordbox "$_PassReEntBody" 0 0 2> ${ANSWER} || config_base_menu
        PASSWD2=$(cat ${ANSWER})
    done

    # create new user. This step will only be reached where the password loop has been skipped or broken.
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $_ConfUsrNew " --infobox "$_NUsrSetBody" 0 0
    sleep 2
    # Create the user, set password, then remove temporary password file
    arch_chroot "useradd ${USER} -m -g users -G wheel,storage,power,network,video,audio,lp -s /bin/bash" 2>/tmp/.errlog
    check_for_error
    echo -e "${PASSWD}\n${PASSWD}" > /tmp/.passwd
    arch_chroot "passwd ${USER}" < /tmp/.passwd >/dev/null 2>/tmp/.errlog
    rm /tmp/.passwd
    check_for_error
    # Set up basic configuration files and permissions for user
    arch_chroot "cp /etc/skel/.bashrc /home/${USER}"
    arch_chroot "chown -R ${USER}:users /home/${USER}"
    [[ -e ${MOUNTPOINT}/etc/sudoers ]] && sed -i '/%wheel ALL=(ALL) ALL/s/^#//' ${MOUNTPOINT}/etc/sudoers

}

configure_sudo() {
    if ! is_package_installed "sudo" ; then
        print_title "SUDO - https://wiki.archlinux.org/index.php/Sudo"
        package_install "sudo"
    fi
    if [[ ! -f  /etc/sudoers.aui ]]; then
        cp -v /etc/sudoers /etc/sudoers.aui
        ## Uncomment to allow members of group wheel to execute any command
        sed -i '/%wheel ALL=(ALL) ALL/s/^#//' /etc/sudoers
        ## Same thing without a password (not secure)
        #sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//' /etc/sudoers

        #This config is especially helpful for those using terminal multiplexers like screen, tmux, or ratpoison, and those using sudo from scripts/cronjobs:
        echo "" >> /etc/sudoers
        echo 'Defaults !requiretty, !tty_tickets, !umask' >> /etc/sudoers
        echo 'Defaults visiblepw, path_info, insults, lecture=always' >> /etc/sudoers
        echo 'Defaults loglinelen=0, logfile =/var/log/sudo.log, log_year, log_host, syslog=auth' >> /etc/sudoers
        echo 'Defaults passwd_tries=3, passwd_timeout=1' >> /etc/sudoers
        echo 'Defaults env_reset, always_set_home, set_home, set_logname' >> /etc/sudoers
        echo 'Defaults !env_editor, editor="/usr/bin/vim:/usr/bin/vi:/usr/bin/nano"' >> /etc/sudoers
        echo 'Defaults timestamp_timeout=15' >> /etc/sudoers
        echo 'Defaults passprompt="[sudo] password for %u: "' >> /etc/sudoers
    fi
}
