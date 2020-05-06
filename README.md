# go
Utilities for installation and management of an Ubuntu server

**INSTALLATION INSTRUCTIONS**

1.	Install the Ubuntu operating system and get to a shell.
2.	Issue these commands:
```bash
# Install git and ufw and open the git port
sudo apt-get install -y git ufw && sudo ufw allow git
# Configure git
cd && git config --global user.name "Lane Hensley" && git config --global user.email "lane.hensley@alumni.duke.edu" && git config --global credential.helper store && git config --global credential.helper cache && git config --global credential.helper 'cache --timeout=600'
# Clone go.git and set restrictive permissions
sudo mkdir -p /var/local/git && cd /var/local/git && sudo git clone https://github.com/lhensley/go.git && cd go && sudo git pull https://github.com/lhensley/go.git && sudo chmod -R 400 /var/local/git
# Copy scripts into /usr/local/sbin
sudo cp -r /var/local/git/go/sbin /usr/local
sudo chown -R root:lhensley /usr/local/sbin
sudo chmod -R 440 /usr/local/sbin
sudo chmod -R 540 /usr/local/sbin/*.sh /usr/local/sbin/*.py /usr/local/sbin/ccextractor
```
