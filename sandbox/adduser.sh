#!/bin/bash

# Here Only
ADMIN_USER="lhensley"

# Once
# echo "AllowGroups sudo" >> /etc/ssh/sshd_config


# For Each User
USERADD_USERNAME="testuser1"
USERADD_PASSWORD="password"
USERADD_FULLNAME="Test User"
useradd -p "$USERADD_PASSWORD" -c "$USERADD_FULLNAME" -G sudo -U "$USERADD_USERNAME"
mkdir -p /home/$USERADD_USERNAME/.ssh /home/$USERADD_USERNAME/.config
cp -ar --preserve=mode,timestamps /home/$ADMIN_USER/.config/* /home/$USERADD_USERNAME/.config
cp -ar --preserve=mode,timestamps /home/$ADMIN_USER/.ssh/* /home/$USERADD_USERNAME/.ssh
cp -ar --preserve=mode,timestamps .bash_logout .bashrc .gitconfig .githubconfig .my.cnf .profile .viminfo /home/$USERADD_USERNAME
chown -R $USERADD_USERNAME:$USERADD_USERNAME /home/$USERADD_USERNAME
chmod 750 /home/$USERADD_USERNAME
chmod 750 /home/$USERADD_USERNAME/.ssh
systemctl restart sshd



deluser testuser0
rm -r /home/testuser0



