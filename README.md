# go
Utilities for installation and management of an Ubuntu server

**INSTALLATION INSTRUCTIONS**

1.	Install the Ubuntu operating system and get to a shell.
2.	Issue these commands (OK to copy the whole thing and paste it at a bash shell prompt):
```bash
# Install git and ufw and open the git port
sudo apt-get update && sudo apt-get install -y git ufw && sudo ufw allow git
# Configure git
cd && git config --global user.name "Lane Hensley" && git config --global user.email "lane.hensley@alumni.duke.edu" && git config --global credential.helper store && git config --global credential.helper cache && git config --global credential.helper 'cache --timeout=600'
# Wipe out existing git and /usr/local/sbin
sudo rm -rf /var/local/git /usr/local/sbin
# Clone go.git and set restrictive permissions
sudo mkdir -p /var/local/git && sudo chmod 775 /var/local/git && cd /var/local/git && sudo git clone https://github.com/lhensley/go.git && sudo chmod -R 400 /var/local/git && cd
# Copy scripts into /usr/local/sbin
sudo cp -r /var/local/git/go/sbin /usr/local && sudo chown -R root:lhensley /usr/local/sbin && sudo find /usr/local/sbin -type d -print0 | sudo xargs -0 chmod 750 && sudo find /usr/local/sbin -type f -print0 | sudo xargs -0 chmod 440 && sudo chmod -R 400 /usr/local/sbin/setup/configs && sudo chmod 540 /usr/local/sbin/*.sh /usr/local/sbin/setup/*.sh /usr/local/sbin/*.py /usr/local/sbin/ccextractor
# Run initialization script
# THIS REQUIRES REBOOT AFTER RUNNING
sudo /usr/local/sbin/setup/setup-os.sh
```
