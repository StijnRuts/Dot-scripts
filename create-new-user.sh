#!/usr/bin/env bash
source ./shared-functions.sh

# Loop while user name is blank, has spaces, or has capital letters in it.
USER=""
while [[ ${#USER} -eq 0 ]] || [[ $USER =~ \ |\' ]] || [[ $USER =~ [^a-z0-9\ ] ]]; do
    read -p "username:" USER
done

# Add the user
# -m creates the user's home directory
# -g the user's initial login group
# -G a list of supplementary groups
# -s defines the user's default login shell
useradd ${USER} -m -g users -G storage,power,network,video,audio,lp -s /bin/bash

# Prompt for password
echo "password:"
passwd $USER

# Setup sudo access
read -r -p "Setup sudo for $USER? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    package_install "sudo"
    # set sudo access for the 'wheel' group in /etc/sudoers.d/
    # instead of editing /etc/sudoers directly
    echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
    # Add user to the 'wheel' group
    groupadd wheel
    gpasswd -a ${USER} wheel
fi

# Set up basic configuration files and permissions for user
cp /etc/skel/.bashrc /home/${USER}
chown -R ${USER}:users /home/${USER}

# Create user dirs
package_install "xdg-user-dirs"
su - ${USER} -c "xdg-user-dirs-update"

# Passing aliases
# If you use a lot of aliases, you might have noticed that they do not carry over to the root account when using sudo.
# However, there is an easy way to make them work. Simply add the following to your ~/.bashrc or /etc/bash.bashrc:
# alias sudo='sudo '
