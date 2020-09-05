# To Back Up
* cron jobs
* /etc/fstab
* Network settings
  * (systemctl restart networking network-manager)
  * DIRECTORY: /etc/netplan
  * FILE: /etc/hosts (CRITICAL)
* Data
  * Contents of ~ (including root and other users) MAYBE
  * MySQL
  * Plex Media Server
  * /var/www
* Configs
  * Everything in install-utils
  * apache2
  * openssl
  * certbot
  * mailutils
  * mysql
  * phpmyadmin
  * plexmediaserver
  * webmin
  * lsyncd
  * makemkv
  * handbrake
  * sudousers