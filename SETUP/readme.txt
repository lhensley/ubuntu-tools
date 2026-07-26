# https://github.com/lhensley/ubuntu-tools/tree/master/install/readme.txt
# This document explains how to provision a newly installed Ubuntu server.


INSTRUCTIONS

This procedure assumes that you have a functioning client such as a laptop.
The client needs network access, a web browser, and a SSH client like Termius.
The SSH client must have keys that correspond to the public keys stored on Github.

1. THIS STEP MUST BE DONE AT THE CONSOLE.
Install Ubuntu Server, making sure to install SSH, 
and download and install the SSH public keys found on Github.
EVERYTHING THAT FOLLOWS CAN BE DONE FROM A SSH CLIENT MACHINE.

2. VERY IMPORTANT:
If you are not reading this document from Github or Visual Studio Code that upates Github, do.
For Github, go to https://github.com, log in as lhensley, and select repository lhensley/ubuntu-tools.
Open SETUP/readme.txt (this document). The https://github.com ALWAYS is the authorized version.
2026-07-24: Look at updating this step. Other (better?) ways to get this documents.

3. In 1Password, look for the Ubuntu Installation entry, 
which has files called 'Contents of gitconfig.txt'
and 'Contents of githubconfig.txt'. Download both of them.

4. SFTP (Termius) from the client machine to the new server and login to the new server.
Copy the files from the Downloads folder on the client machine to your home directory on the new server.
IMPORTANT: Keep the "Contents of " parts of the file names.
Close SFTP (optional).

5. SSH (Termius) from the client machine to the new server and login to the new server.
Issue these commands:   
  mv ~/'Contents of gitconfig.txt' ~/.gitconfig
  mv ~/'Contents of githubconfig.txt' ~/.githubconfig

6. At the CLI, enter these commands. 
It's fine to copy these command all at once and paste to the server's shell.
Unexpected warnings and errors are not unusual. Recommend executing these one at a time.
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
  
7. THIS STEP IS ABSOLUTELY REQUIRED.
Login to the new server, and edit ~/SETUP/variables as you see appropriate.

8. Run the setup script:
    sudo ~/SETUP/setup  # Runs the system setup routine for a newly provisioning server











