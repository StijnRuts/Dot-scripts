#!/usr/bin/env bash

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
