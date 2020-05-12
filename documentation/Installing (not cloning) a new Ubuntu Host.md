# Installing (Not Cloning) a New Ubuntu Host.md

1. BEFORE creating a VirtualBox, set the Oracle VM VirtualBox Manager Preferences:
	a. Display -> Maximum Guest Screen Size -> None
	b. Extensions: Install Oracle VM VirtualBox Extension Pack
2. Install from a USB stick, or create/clone a VirtualBox with an ISO file.
3. If installing by creating a new VirtualBox, here are recommended base specs: 2048MB RAM; create a virtual hard disk, VDI type, dynamically allocated, 32GB. (Tried 16GB 5/6/2020)
	a. General -> Advanced -> Shared Clipboard: Bidirectional
	b. Display -> Screen -> Video Memory -> 128MB
	c. Display -> Screen -> Scale Factor -> 300% (adjust after OS is installed)
	d. Display -> Remote Display -> Enable Server
	e. Network -> Adapter 1 -> Advanced -> Port ForwardingDon’t specify any IP addresses. Just port Numbers. Establish unique port numbers here.
4. Run the OS installation.
5. In the GUI, go to Settings and select
	a. Displays -> 1440x900 (recommended for L10)
6. In VM Machine -> Settings, select
	a. Display -> Screen -> Scale Factor -> 200% (recommended for L10)
7. In the GUI, load a terminal (CTRL-ALT-T) and issues these commands:
```bash
	sudo apt-get install -y ssh && sudo ufw allow ssh
```
8. SSH into the VirtualBox (port 101XX).
9.	Install the Ubuntu operating system and get to a shell.
10.	Issue these commands (OK to copy the whole thing and paste it at a bash shell prompt):
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
11. Load the Firefox Web Browser and login using Lion credentials.
12. Install Roboform extension to Firefox and log in.
13. In the GUI, run Settings, Online Accounts and fill in where possible.
14. At Setup / Settings on the desktop, go to Sharing and turn on Screen Sharing.
