# Installing (Not Cloning) a New Ubuntu Host.md

1. Install from a USB stick with an ISO file.
2. Invoke this document Github in Firefox and copy the text below to the clipboard.
```bash
# Make sure we're root.
if [[ $EUID -ne 0 ]]; then
        echo "Use sudo. $0 must be run as root." 1>&2
        exit 1
    fi
# Install git and ufw and open the git port
DEBIAN_FRONTEND=noninteractive apt-get install -yq git
ufw allow git
# Configure git
cd
git config --global user.name "Lane Hensley"
git config --global user.email "lane.hensley@alumni.duke.edu"
git config --global credential.helper store
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=600'
# Install git token
# To get a new token, go to https://github.com/settings/tokens.
MY_GIT_TOKEN=8224e3fbc597bf523d30906d038158977763b2e1
git config --global url."https://api:$MY_GIT_TOKEN@github.com/".insteadOf "https://github.com/"
git config --global url."https://ssh:$MY_GIT_TOKEN@github.com/".insteadOf "ssh://git@github.com/"
git config --global url."https://git:$MY_GIT_TOKEN@github.com/".insteadOf "git@github.com:"
cp /root/.gitconfig $HOME_DIR/.gitconfig
chown root:root /root/.gitconfig
chown $USER_ME:$USER_ME $HOME_DIR/.gitconfig
chmod 600 $HOME_DIR/.gitconfig
chmod 600 /root/.gitconfig
# Wipe out existing git and /usr/local/sbin
rm -rf /var/local/git /usr/local/sbin
# Clone go.git and set restrictive permissions
mkdir -p /var/local/git
chmod 775 /var/local/git
cd /var/local/git
# Select the designated branch
git checkout $BRANCH
git clone https://github.com/lhensley/go.git
chmod -R 400 /var/local/git
cd
# Copy scripts into /usr/local/sbin
cp -r /var/local/git/go/sbin /usr/local
chown -R root:lhensley /usr/local/sbin
find /usr/local/sbin -type d -print0 | sudo xargs -0 chmod 750
find /usr/local/sbin -type f -print0 | sudo xargs -0 chmod 440
chmod -R 400 /var/local/git/go/configs
chmod -R 540 /usr/local/sbin
# Run initialization script
# THIS REQUIRES REBOOT AFTER RUNNING
/usr/local/sbin/setup/setup-os
```
3. Open a terminal (CTRL-ALT-T) and paste the clipboard contents into a temporary shell file. (Don't try just pasting it into the shell window.) Changes the file's permissions to 700, and run it.
4. Delete the file.
5. Close Firefox, run Chrome, and install 1Password extension. 