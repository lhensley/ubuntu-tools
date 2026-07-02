# https://github.com/lhensley/ubuntu-tools/tree/master/install/readme.txt
# This document explains how to provision a newly installed Ubuntu server.


INSTRUCTIONS

This procedure assumes that you have a functioning client such as a laptop.
The client needs network access, a web browser, and a SSH client like Termius.
The SSH client must have keys that correspond to the public keys stored on Github.

1. VERY IMPORTANT:
Use files from Github (https://github.com/lhensley/ubuntu-tools/tree/master/install). 
If you have Microsoft Visual Studio Code or another front end, that's easier.
In either case, you can cut-and-paste to get going. If you're reading this from any other source,
follow the current online https://github.com/lhensley/ubuntu-tools/tree/master/install/readme.txt instead.

2. Install Ubuntu Server, making sure to install SSH, 
and download and install the SSH public keys found on Github.

3. SSH from the client machine to the new server and login to the new server.

4. At the CLI, enter these commands. 
It's fine to copy these command all at once and paste to the server's shell.

  sudo apt-get -y update && sudo apt-get -y dist-upgrade  # Bring all packages current.
  sudo apt-get -y install git-all moreutils  # Add several needed utilities.
  mkdir -p ~/SETUP # Create a setup directory in your home directory. 
  curl -L -o ~/SETUP/readme.txt https://raw.githubusercontent.com/lhensley/ubuntu-tools/master/SETUP/readme.txt
  curl -L -o ~/SETUP/setup https://raw.githubusercontent.com/lhensley/ubuntu-tools/master/SETUP/setup
  curl -L -o ~/SETUP/variables https://raw.githubusercontent.com/lhensley/ubuntu-tools/master/SETUP/variables
  chmod 600 ~/SETUP/readme.txt
  chmod 700 ~/SETUP/setup ~/SETUP/variables
  sudo reboot now

5. The server will restart, which will end your SSH session. Wait about one minute and re-connect.









