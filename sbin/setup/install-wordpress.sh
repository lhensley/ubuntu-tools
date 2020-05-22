#!/bin/bash
# install-wordpress.sh
# Revised 2020-05-05

# To store MySQL root password in a config, create .my.cnf in the home directory, with permissions 600, owner [user]:[user] and with this format:
#
# 	[client]
# 	user="MYSQL_USERNAME"
# 	password="MYSQL_PASSWORD"
#
# 	[mysqldump]
# 	user="MYSQL_USERNAME"
# 	password="MYSQL_PASSWORD"
#
# For the root user, copy the file to /root with permissions 600, owner root:root

# DEFINE THESE VARIABLES BEFORE RUNNING THE SCRIPT!
fqdn="tmp.from-ia.com"
web_admin_user="lhensley"
web_admin_email="lane.hensley@alumni.duke.edu"
remove=false
#remove=true

mysql_root_user="kai"
mysql_root_password="Qok7qxYX,=UZtDTTcv@(H^U8@JRLXwyu"

script_name=install-wordpress.sh
current_directory=$(pwd)
docroot_base="/var/www"
apache2_configs="/etc/apache2"
error_log="/var/log/apache2/error.log"
custom_log="/var/log/apache2/access.log"
certificate_conf_dir="/etc/letsencrypt"
certificate_live_dir="$certificate_conf_dir/live"
excluded_password_characters="\";\$\`\!\*\@"

docroot=$docroot_base/$fqdn
site_conf=$apache2_configs/sites-available/$fqdn.conf
site_enabled=$apache2_configs/sites-enabled/$fqdn.conf

#debug_mode=false
debug_mode=true
if $debug_mode ; then
  set -x
  fi

function backout {
  echo "Backing out the installation."
  cd $current_directory
  rm -f -r $docroot
  rm -f $site_enabled
  rm -f $site_conf
  query="DROP DATABASE IF EXISTS \`wp_$fqdn\`; DROP USER IF EXISTS 'wp_$fqdn'@'localhost'; FLUSH PRIVILEGES;"
#  mysql -u $mysql_root_user -p$mysql_root_password -e "$query" > /dev/null 2> /dev/null
  mysql -e "$query" > /dev/null 2> /dev/null
  systemctl restart apache2
  }

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." 1>&2
  echo "Aborted."
  exit 1
  fi

# Check for removal option
if $remove ; then
  backout
  echo "$fqdn virtual server removed."
  exit 0
  fi

# Check that target directory does not contain files; create it if needed.
if [ -d "$docroot" ]; then # If docroot already exists
  if ! [ -z "$(ls -A $docroot)" ]; then # If docroot is not empty
    echo "$docroot is not empty."
    echo "Aborted."
    exit 1
    fi
  else
    mkdir $docroot
  fi

# Do updates and install needed tools
apt-get update && apt -y dist-upgrade && apt -y clean && apt -y autoremove
# For Ubuntu 18
# apt-get install -y wget apg certbot python python-certbot-apache
# For Ubuntu 18
apt-get install -y wget apg certbot python3-certbot-apache

# Generate a MySQL password for the Wordpress database
admin_wp_pwd="$(apg -a 1 -m 20 -n 1 -MCLN)"
mysql_wp_pwd="$(apg -a 1 -m 20 -n 1 -MCLN)"

# Add MySQL database and user
query="DROP USER IF EXISTS 'wp_$fqdn'@'localhost'; FLUSH PRIVILEGES; CREATE USER 'wp_$fqdn'@'localhost' IDENTIFIED WITH caching_sha2_password BY \'$mysql_wp_pwd\';GRANT USAGE ON *.* TO 'wp_$fqdn'@'localhost';ALTER USER 'wp_$fqdn'@'localhost' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;CREATE DATABASE IF NOT EXISTS `wp_$fqdn`;GRANT ALL PRIVILEGES ON `wp_$fqdn`.* TO 'wp_$fqdn'@'localhost';"
echo $query
read xxx
if ! mysql -e "$query" > /dev/null 2> /dev/null; then
  backout
  echo "Could not add MySQL database and user."
  echo "Aborted."
  exit 1
  fi

# Move to docroot
if ! cd "$docroot"; then
  backout
  echo "Could not move to $docroot."
  echo "Aborted."
  exit 1
  fi

# Install wordpress
if ! wget https://wordpress.org/latest.tar.gz; then
  backout
  echo "Could not download Wordpress."
  echo "Aborted."
  exit 1
  fi
if ! tar xzf latest.tar.gz; then
  backout
  echo "Could not unpack latest.tar.gz in $docroot."
  echo "Aborted."
  exit 1
  fi
if ! mv wordpress/* .; then
  backout
  echo "Could not move wordpress directory contents into $docroot."
  echo "Aborted."
  exit 1
  fi

# Clean up
rmdir wordpress
rm latest.tar.gz
chown -R www-data:www-data .

# Append to wp-includes/functions.php to increase max upload size
if ! echo "@ini_set( 'upload_max_size' , '2G' );" >> $docroot/wp-includes/functions.php; then
  backout
  echo "Could not append to $docroot/wp-includes/functions.php."
  echo "Aborted."
  exit 1
  fi
if ! echo "@ini_set( 'post_max_size', '2G' );" >> $docroot/wp-includes/functions.php; then
  backout
  echo "Could not append to $docroot/wp-includes/functions.php."
  echo "Aborted."
  exit 1
  fi
if ! echo "@ini_set( 'max_execution_time', '300' );" >> $docroot/wp-includes/functions.php; then
  backout
  echo "Could not append to $docroot/wp-includes/functions.php."
  echo "Aborted."
  exit 1
  fi

# Create php.ini in docroot
if ! echo "upload_max_filesize = 2G" > $docroot/php.ini; then
  backout
  echo "Could not create $docroot/php.ini."
  echo "Aborted."
  exit 1
  fi
echo "post_max_size = 2G" >> $docroot/php.ini
echo "max_execution_time = 300" >> $docroot/php.ini
if ! chown www-data:www-data $docroot/php.ini; then
  backout
  echo "Could not set ownership for $docroot/php.ini."
  echo "Aborted."
  exit 1
  fi

# Install SSL certificate.
echo "Choose $fqdn when prompted."
echo "Do NOT choose to redirect"
certificate_successfully_installed="is"
if ! certbot certonly --apache -d $fqdn; then
  certificate_successfully_installed="is not"
  fi

# Define virtual host in apache2
if ! echo "<VirtualHost *:443>" > $site_conf; then
  backout
  echo "Could not create $site_conf."
  echo "Aborted."
  exit 1
  fi
echo "DocumentRoot \"$docroot\"" >> $site_conf
echo "ServerAdmin $web_admin_email" >> $site_conf
echo "ErrorLog $error_log" >> $site_conf
echo "CustomLog $custom_log combined" >> $site_conf
echo "<Directory $docroot>" >> $site_conf
echo "Options FollowSymLinks" >> $site_conf
echo "AllowOverride Limit Options FileInfo" >> $site_conf
echo "DirectoryIndex index.php" >> $site_conf
echo "Order allow,deny" >> $site_conf
echo "Allow from all" >> $site_conf
echo "</Directory>" >> $site_conf
echo "<Directory $docroot/wp-content>" >> $site_conf
echo "Options FollowSymLinks" >> $site_conf
echo "Order allow,deny" >> $site_conf
echo "Allow from all" >> $site_conf
echo "</Directory>" >> $site_conf
echo "SSLEngine on" >> $site_conf
echo "LogLevel emerg" >> $site_conf
echo "ServerName $fqdn" >> $site_conf
echo "SSLCertificateFile $certificate_live_dir/$fqdn/fullchain.pem" >> $site_conf
echo "SSLCertificateKeyFile $certificate_live_dir/$fqdn/privkey.pem" >> $site_conf
echo "Include $certificate_conf_dir/options-ssl-apache.conf" >> $site_conf
echo "SSLProtocol +TLSv1.1 +TLSv1.2" >> $site_conf
echo "</VirtualHost>" >> $site_conf
echo "<VirtualHost *:80>" >> $site_conf
echo "DocumentRoot \"$docroot\"" >> $site_conf
echo "ServerName $fqdn" >> $site_conf
echo "RewriteEngine On" >> $site_conf
echo "RewriteCond %{SERVER_PORT} 80" >> $site_conf
echo "RewriteRule ^(.*)$ https://$fqdn$1 [R=301,L]" >> $site_conf
echo "RewriteCond %{SERVER_NAME} =$fqdn" >> $site_conf
echo "RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]" >> $site_conf
echo "<Directory "$docroot">" >> $site_conf
echo "allow from all" >> $site_conf
echo "Options None" >> $site_conf
echo "Require all granted" >> $site_conf
echo "</Directory>" >> $site_conf
echo "</VirtualHost>" >> $site_conf
chown root:root $site_conf
chmod 644 $site_conf
if ! ln -s $site_conf $site_enabled; then
  backout
  echo "Could not enable virtual host $fqdn."
  echo "Aborted."
  exit 1
  fi
chown root:root $site_enabled

# Restart apache2
if ! systemctl restart apache2; then
  rm $site_enabled
  rm $site_conf
  if ! systemctl restart apache2; then
    backout
    echo "Error restarting apache2."
    echo "Aborted."
    exit 1
  else
    backout
    echo "Apache2 will not start with virtual host $fqdn defined."
    echo "Virtual host $fqdn has been deleted."
    echo "Apache2 is running."
    echo "Aborted."
    exit 1
    fi
  fi

# Open the firewall for apache2
ufw allow 'Apache' > /dev/null 2> /dev/null
ufw allow 'Apache Full' > /dev/null 2> /dev/null

# Install SSL certificate. APACHE MUST ALREADY BE RUNNING THE VIRTUAL HOST
echo "Choose $fqdn when prompted."
echo "Do NOT choose to redirect"
certificate_successfully_installed="is"
if ! certbot --apache -d $fqdn; then
  certificate_successfully_installed="is not"
  fi

# Append to .htaccess to increase max upload size
echo "php_value upload_max_filesize 2G" >> $docroot/.htaccess
echo "php_value post_max_size 2G" >> $docroot/.htaccess
echo "php_value memory_limit 256M" >> $docroot/.htaccess
echo "php_value max_execution_time 300" >> $docroot/.htaccess
echo "php_value max_input_time 300" >> $docroot/.htaccess

# Report results to end user
echo "IMPORTANT: COPY THIS INFORMATION NOW."
echo "  Virtual host URL: https://$fqdn"
echo "  MySQL database name: wp_$fqdn"
echo "  MySQL user name: wp_$fqdn"
echo "  MySQL password for $fqdn database: $mysql_wp_pwd"
echo "  WordPress administrator user name: $web_admin_user"
echo "  WordPress administrator password: $admin_wp_pwd"
echo "  WordPress administrator email: $web_admin_email"
echo "  SSL certificate for $fqdn $certificate_successfully_installed installed."
exit 0
