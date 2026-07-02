# https://github.com/lhensley/ubuntu-tools/tree/master/install/readme.txt
# This document explains how to provision a newly installed Ubuntu server.


INSTRUCTIONS

This procedure assumes that you have a functioning client such as a laptop.
The client needs network access, a web browser, and a SSH client like Termius.
The SSH client must have keys that correspond to the public keys stored on Github.

1. Install Ubuntu Server, making sure to install SSH, 
and download and install the SSH public keys found on Github.

2. VERY IMPORTANT:
Go to https://github.com, log in as lhensley, and select repository lhensley/ubuntu-tools.
Open SETUP/readme.txt (this document). The https://github.com ALWAYS is the authorized version.

3. SSH from the client machine to the new server and login to the new server.

4. At the CLI, enter these commands. 
It's fine to copy these command all at once and paste to the server's shell.

  sudo apt-get -y update && sudo apt-get -y dist-upgrade  # Bring all packages current.
  sudo apt-get -y install at certbot fail2ban git-all moreutils php unzip # Add several needed utilities.
  # Install above also installed: coreutils curl gpg gzip moreutils openssl python3 rsync vim
  mkdir -p ~/SETUP # Create a setup directory in your home directory.
  curl -L -o ~/SETUP/readme.txt https://raw.githubusercontent.com/lhensley/ubuntu-tools/master/SETUP/readme.txt
  curl -L -o ~/SETUP/setup https://raw.githubusercontent.com/lhensley/ubuntu-tools/master/SETUP/setup
  curl -L -o ~/SETUP/variables https://raw.githubusercontent.com/lhensley/ubuntu-tools/master/SETUP/variables
  chmod 600 ~/SETUP/readme.txt  # Only you have rights to read and edit.
  chmod 700 ~/SETUP/setup ~/SETUP/variables.  # Only you have rights to read, edit, and execute.
  
5. If all appears well, run this command:

  sudo reboot now. # Reboot

5. The server will restart, which will end your SSH session. Wait about one minute and re-connect.

6. THIS STEP IS ABSOLUTELY REQUIRED.
Login to the new server, and change directory to ~/SETUP. Edit ~/SETUP/variables as you see appropriate.




Already installed: coreutils curl gpg gzip moreutils openssl python3 rsync vim 
Needs interaction: mailutils, webmin








