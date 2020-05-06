# go
Utilities for installation and management of an Ubuntu server

**INSTALLATION INSTRUCTIONS**

1.	Install the Ubuntu operating system and get to a shell.
2.	Issue these commands:
```bash
cd
sudo apt-get install -y git ufw
sudo ufw allow git
git config --global user.name "Lane Hensley"
git config --global user.email "lane.hensley@alumni.duke.edu"
git config --global credential.helper store
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=600'
git clone https://github.com/lhensley/go.git
```
