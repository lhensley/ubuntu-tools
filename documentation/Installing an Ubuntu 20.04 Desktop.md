# Installing (Not Cloning) a New Ubuntu Host.md

1. Install from a USB stick with an ISO file.
2. In the GUI, start Firefox and log into Dashlane, and retrieve the Github password.
3. Invoke this document Github in Firefox and copy the text below to the clipboard.
```bash
# Install ssh
sudo apt-get update
sudo apt-get install -y ufw ssh
sudo ufw allow ssh
# Install Google Chrome
sudo apt-get install -y wget gdebi-core
sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo gdebi --n google-chrome-stable_current_amd64.deb
sudo rm ./google-chrome-stable_current_amd64.deb
# Install git and ufw and open the git port
sudo apt-get install -y git
sudo ufw allow git
# Configure git
sudo cd
sudo git config --global user.name "Lane Hensley"
sudo git config --global user.email "lane.hensley@alumni.duke.edu"
sudo git config --global credential.helper store
sudo git config --global credential.helper cache
sudo git config --global credential.helper 'cache --timeout=600'
# Install git token
# To get a new token, go to https://github.com/settings/tokens.
MY_GIT_TOKEN=4b662b7d4431ec1956127aa9d4fdbd8d75ec821a
sudo git config --global url."https://api:$MY_GIT_TOKEN@github.com/".insteadOf "https://github.com/"
sudo git config --global url."https://ssh:$MY_GIT_TOKEN@github.com/".insteadOf "ssh://git@github.com/"
sudo git config --global url."https://git:$MY_GIT_TOKEN@github.com/".insteadOf "git@github.com:"
sudo cp /root/.gitconfig $HOME_DIR/.gitconfig
sudo chown root:root /root/.gitconfig
sudo chown $USER_ME:$USER_ME $HOME_DIR/.gitconfig
sudo chmod 600 $HOME_DIR/.gitconfig
sudo chmod 600 /root/.gitconfig
# Wipe out existing git and /usr/local/sbin
sudo rm -rf /var/local/git /usr/local/sbin
# Clone go.git and set restrictive permissions
sudo mkdir -p /var/local/git
sudo chmod 775 /var/local/git
cd /var/local/git
sudo git clone https://github.com/lhensley/go.git
sudo chmod -R 400 /var/local/git
cd
# Copy scripts into /usr/local/sbin
sudo cp -r /var/local/git/go/sbin /usr/local
sudo chown -R root:lhensley /usr/local/sbin
sudo find /usr/local/sbin -type d -print0 | sudo xargs -0 chmod 750
sudo find /usr/local/sbin -type f -print0 | sudo xargs -0 chmod 440
sudo chmod -R 400 /var/local/git/go/configs
sudo chmod -R 540 /usr/local/sbin
# Run initialization script
# THIS REQUIRES REBOOT AFTER RUNNING
sudo /usr/local/sbin/setup/setup-os
```
4. Open a terminal (CTRL-ALT-T) and paste the clipboard contents into a temporary shell file. (Don't try just pasting it into the shell window.) Changes the file's permissions to 700, and run it.
5. Delete the file.
6. Close Firefox, run Chrome, and install Dashlane extension. 