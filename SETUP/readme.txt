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
2026-07-24: Look at updating this step. Other (better?) ways to get this documents.

3. In 1Password, look for the Ubuntu Installation entry, 
which has files called 'Contents of gitconfig.txt'
and 'Contents of githubconfig.txt'. Download both of them.
2026-07-24: Is this still necessary? TBD ...

4. SFTP (Termius) from the client machine to the new server and login to the new server.
Copy the files from the Downloads folder on the client machine to /root on the new server.
IMPORTANT 1: Keep the "Contents of " parts of the file names.
IMPORTANT 2: Don't upload to $ADMIN_DIR or other place. Use /root.

6. Move the files from the Downloads folder on the client machine to the Trash and close SFTP.

7. SSH (Termius) from the client machine to the new server and login to the new server.

8. At the CLI, enter these commands. 
It's fine to copy these command all at once and paste to the server's shell.
Unexpected warnings and errors are not unusual. Recommend executing these one at a time.

  sudo apt-get -y update && sudo apt-get -y dist-upgrade  # Bring all packages current
  sudo apt-get -y install at certbot fail2ban git-all moreutils php unzip # Add several needed utilities
  # Install above also installed: coreutils curl gpg gzip moreutils openssl python3 rsync vim and more
  # mv ~/'Contents of gitconfig.txt' ~/.gitconfig
  # mv ~/'Contents of githubconfig.txt' ~/.githubconfig
  mkdir -p /root/SETUP # Create a setup directory in your home directory
  curl -L -o /root/SETUP/readme.txt  https://raw.githubusercontent.com/lhensley/ubuntu-tools/master/SETUP/readme.txt
  curl -L -o /root/SETUP/setup       https://raw.githubusercontent.com/lhensley/ubuntu-tools/master/SETUP/setup
  curl -L -o /root/SETUP/variables   https://raw.githubusercontent.com/lhensley/ubuntu-tools/master/SETUP/variables
  chmod 600 /root/.gitconfig                         # Only root has rights to read and edit
  chmod 600 /root/.githubconfig                      # Only root has rights to read and edit
  chmod 600 /root/SETUP/readme.txt                   # Only root has rights to read and edit
  chmod 700 /root/SETUP/setup /root/SETUP/variables  # Only root has rights to read, edit, and execute
  chown lhensley:lhensley /root/.gitconfig /root/.githubconfig /root/SETUP/readme.txt /root/SETUP/setup /root/SETUP/variables
  mv /root/.git* /home/lhensley/
  mv /root/SETUP /home/lhensley/
  
9. When all appears well, run this command:

  sudo reboot now  # Reboot

10. The server will restart, which will end your SSH session. Wait about one minute and re-connect.

11. THIS STEP IS ABSOLUTELY REQUIRED.
Login to the new server, and edit ~/SETUP/variables as you see appropriate.

12. Run the setup script:

  sudo ~/SETUP/setup  # Runs the system setup routine for a newly provisioning server




####################

# NOT FINISHED!









