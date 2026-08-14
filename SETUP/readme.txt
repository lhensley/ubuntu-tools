# https://github.com/lhensley/ubuntu-tools/tree/master/install/readme.txt
# This document explains how to provision a newly installed Ubuntu server.


INSTRUCTIONS

This procedure assumes that you have a functioning client such as a laptop.
The client needs network access, a web browser, and a SSH client like Termius.
The SSH client must have keys that correspond to the public keys stored on Github.

1. BASIC OS INSTALL
Install Ubuntu Server, making sure to install SSH, 
and download and install the SSH public keys found on Github.
EVERYTHING THAT FOLLOWS CAN BE DONE FROM A SSH CLIENT MACHINE.

2. USE CURRENT DOCUMENTATION
If you are not reading this document from Github or Visual Studio Code that upates Github, do.
For Github, go to https://github.com, log in as lhensley, and select repository lhensley/ubuntu-tools.

3. GIT CONFIGS
In 1Password, look for the Ubuntu Installation entry, 
which has files called 'Contents of gitconfig.txt'
and 'Contents of githubconfig.txt'. Download both of them.

4. SFTP (Termius) from the client machine to the new server and login to the new server.
Copy the files from the Downloads folder on the client machine to your home directory on the new server.
IMPORTANT: Keep the "Contents of " parts of the file names.
Close SFTP (optional).

5. SSH (Termius) from the client machine to the new server and login to the new server.
It's fine to copy these command all at once and paste to the server's shell.
Unexpected warnings and errors are not unusual. Recommend executing these one at a time.
  mv ~/'Contents of gitconfig.txt' ~/.gitconfig
  mv ~/'Contents of githubconfig.txt' ~/.githubconfig
  sudo apt-get -y update && sudo apt-get -y dist-upgrade  # Bring all packages current
  sudo apt-get -y install at certbot fail2ban git-all moreutils php unzip # Add several needed utilities
  mkdir -p ~/SETUP # Create a setup directory in your home directory
  curl -L -o ~/SETUP/readme.txt  https://raw.githubusercontent.com/lhensley/ubuntu-tools/master/SETUP/readme.txt
  curl -L -o ~/SETUP/setup       https://raw.githubusercontent.com/lhensley/ubuntu-tools/master/SETUP/setup
  curl -L -o ~/SETUP/variables   https://raw.githubusercontent.com/lhensley/ubuntu-tools/master/SETUP/variables
  chmod 600 ~/.gitconfig                             # Only you have rights to read and edit
  chmod 600 ~/.githubconfig                          # Only you have rights to read and edit
  chmod 600 ~/SETUP/readme.txt                       # Only you have rights to read and edit
  chmod 700 ~/SETUP ~/SETUP/setup ~/SETUP/variables  # Only you have rights to read, edit, and execute
  chown lhensley:lhensley ~/.gitconfig ~/.githubconfig ~/SETUP/readme.txt ~/SETUP/setup ~/SETUP/variables
  sudo mkdir -p /mnt/bob /mnt/2TBA /mnt/3TBB /mnt/4TBA /mnt/5TBC /mnt/5TBD /mnt/5TBE /mnt/12TBA /mnt/12TBB /mnt/12TBC 
  sudo mkdir -p /mnt/20TBA /mnt/Black1TB /mnt/Silver1TB /mnt/Silver5TB-A /mnt/Silver5TB-B
  sudo chmod 700 /mnt/* 
  
6. UPDATE VARIABLES 
Login to the new server, and edit ~/SETUP/variables as you see appropriate.

7. Run the setup script:
    sudo ~/SETUP/setup  # Runs the system setup routine for a newly provisioning server



Things to backup
  Filesystems with tar/gzip
  MySQL dump
  crontabs
  plexmediaserver
  uids and gids? TBD...

Manual restore:
#    SETUP_TIME=$(/bin/date '+%Y-%m-%d-%H-%M-%S-%Z')
    SETUP_TIME="2026-08-13"
    TMP_SETUP_DIR=/tmp/$SETUP_TIME
    sudo mkdir -p $TMP_SETUP_DIR
#  # lifeboat
#    sudo mkdir -p ~/lifeboat
  # Letsencrypt
    CONFIG_ETC=/etc/letscrypt
    sudo rm -rf $TMP_SETUP_DIR/*
    sudo mv $CONFIG_ETC/* $TMP_SETUP_DIR/
    sudo cp -r /mnt/4TBA/lifeboat$CONFIG_ETC/* $CONFIG_ETC/
    sudo mkdir -p $CONFIG_ETC/$SETUP_TIME
    sudo mv $TMP_SETUP_DIR/* $CONFIG_ETC/$SETUP_TIME/
    sudo systemctl restart certbot
  # /var/www
    sudo mkdir -p /var/www
    sudo cp -r /mnt/4TBA/lifeboat/var/www/* /var/www/
    sudo chown -R www-data:www-data /var/www
  # apache2   DEFIN
    CONFIG_ETC=/etc/apache2
    sudo rm -rf $TMP_SETUP_DIR/*
    sudo mv $CONFIG_ETC/* $TMP_SETUP_DIR/
    sudo cp -r /mnt/4TBA/lifeboat$CONFIG_ETC/* $CONFIG_ETC/
    sudo mkdir -p $CONFIG_ETC/$SETUP_TIME
    sudo mv $TMP_SETUP_DIR/* $CONFIG_ETC/$SETUP_TIME/
  #  sudo systemctl restart apache2
  # Plex Media Server
    sudo mkdir -p /backups
    sudo cp -r /mnt/4TBA/lifeboat/backups/'Plex Media Server' /backups/
  # Lane home
    sudo mkdir -p /home/lhensley/restores
    sudo cp -r /mnt/4TBA/lifeboat/home/lhensley/* /home/lhensley/restores/
    sudo chown -R lhensley:lhensley /home/lhensley/restores

WORKING AS EXPECTED
  apache2
  apg
  at
  curl
  ddclient
  exiftool
  fail2ban
  ffmpeg
  git
  gpg
  gzip
  HandBrake-CLI
  mailutils
  NetworkManager (fixed)
  openssl
  openVPN # <==== IMPORTANT: DON'T INSTALL THIS VERSION. USE ACCESS SERVER FROM openvpn.net
  php
  python3
  rsync
  unzip
  vi (reverts to vim)
  webmin

PROBLEMS
  certbot

MANUAL ISSUES TO MANAGE  
  mysql (just needs data & accounts)
  phpmyadmin
  plexmediaserver

After stabilized and rebooted,
https://ubuntu.com/esm is Expanded Security Maintenance (NO!)
https://ubuntu.com/pro (NO! Same thing!)
YES DO THIS: https://ubuntu.com/pro/subscribe



Find the passwords in ~ and /root directories.



NEED TO RESTORE 
contents of ~ and /root *
webmin
mail
MySQL *
ddclient
apache2 and /var/www *
certbot/Letsencrypt
Plex *
crontabs
uids and gids? TBD...
OpenVPN
phpmyadmin
git

WHAT CAN WE DO RIGHT NOW 

# UFW
sudo ufw enable

# plex
sudo snap stop plexmediaserver
sudo cp -r '/mnt/4TBA/lifeboat/var/snap/plexmediaserver/common/Library/Application Support' '/var/snap/plexmediaserver/common/Library/'
sudo snap start plexmediaserver
# WORKS! Needs some configuration, but you'll see it, and it's easy.

# home directory
mkdir -p /home/lhensley/RESTORES
sudo mv /home/lhensley/mysql-client-certificates /home/lhensley/RESTORES/ 
sudo mv /home/lhensley/.my* /home/lhensley/RESTORES/
sudo mv /home/lhensley/git /home/lhensley/git-new
sudo cp -r /mnt/4TBA/lifeboat/home/lhensley/* /home/lhensley/
sudo mv /home/lhensley/RESTORES/* /home/lhensley/
sudo mv /home/lhensley/RESTORES/.* /home/lhensley/
sudo rmdir /home/lhensley/RESTORES

# /root doesn't appear to need anything.

# mysql
sudo apt update
sudo apt install mysql-server
sudo systemctl status mysql
sudo systemctl start mysql
sudo systemctl enable mysql
sudo mysql
  ALTER USER 'root'@'localhost' IDENTIFIED BY 'YourStrongPassword';
  exit;
sudo mysql_secure_installation
  choose YES
  choose 2 (strong for user admin)
  choose YES (to change the password for admin)
    enter new password
  choose YES (to remove anonymous users)
  choose YES (to disallow root login remotely)
  choose YES (to remove test database and access to it)
  choose YES (to reload privilege tables now)
sudo chown lhensley:lhensley /home/lhensley/MySQL.dsm1.dump.sql
mysql -u admin -p -f < /home/lhensley/MySQL.dsm1.dump.sql

