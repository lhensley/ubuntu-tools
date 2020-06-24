# Installing (Not Cloning) a New Ubuntu Host.md

1. Install from a USB stick with an ISO file.
2. In the GUI, invoke this document from Firefox, open a terminal (CTRL-ALT-T) and cut-and-paste this into the shell:
```bash
# Install ssh
sudo apt-get install -y ssh && sudo ufw allow ssh
# Install Google Chrome
apt-get install -y gdebi-core
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
gdebi --n google-chrome-stable_current_amd64.deb
rm ./google-chrome-stable_current_amd64.deb
# Install git and ufw and open the git port
sudo apt-get update && sudo apt-get install -y git ufw && sudo ufw allow git
# Configure git
cd && git config --global user.name "Lane Hensley" && git config --global user.email "lane.hensley@alumni.duke.edu" && git config --global credential.helper store && git config --global credential.helper cache && git config --global credential.helper 'cache --timeout=600'
# Install git token
# To get a new token, go to https://github.com/settings/tokens.
MY_GIT_TOKEN=4b662b7d4431ec1956127aa9d4fdbd8d75ec821a
git config --global url."https://api:$MY_GIT_TOKEN@github.com/".insteadOf "https://github.com/"
git config --global url."https://ssh:$MY_GIT_TOKEN@github.com/".insteadOf "ssh://git@github.com/"
git config --global url."https://git:$MY_GIT_TOKEN@github.com/".insteadOf "git@github.com:"
# Wipe out existing git and /usr/local/sbin
sudo rm -rf /var/local/git /usr/local/sbin
# Clone go.git and set restrictive permissions
sudo mkdir -p /var/local/git && sudo chmod 775 /var/local/git && cd /var/local/git && sudo git clone https://github.com/lhensley/go.git && sudo chmod -R 400 /var/local/git && cd
# Copy scripts into /usr/local/sbin
sudo cp -r /var/local/git/go/sbin /usr/local && sudo chown -R root:lhensley /usr/local/sbin && sudo find /usr/local/sbin -type d -print0 | sudo xargs -0 chmod 750 && sudo find /usr/local/sbin -type f -print0 | sudo xargs -0 chmod 440 && sudo chmod -R 400 /var/local/git/go/configs && sudo chmod 540 /usr/local/sbin/*.sh /usr/local/sbin/setup/*.sh /usr/local/sbin/*.py /usr/local/sbin/ccextractor
# Run initialization script
# THIS REQUIRES REBOOT AFTER RUNNING
sudo /usr/local/sbin/setup/setup-os
```
3. Close Firefox, run Chrome, and install Dashlane extension.