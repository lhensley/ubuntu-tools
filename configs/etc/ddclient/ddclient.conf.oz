### Basic HTTPS configuration file for ddclient
#
# /etc/ddclient.conf
# nuc01
# root:root 600
#
syslog=yes
mail=lane@lanehensley.org
mail-failure=root
daemon=7200
pid=/var/run/ddclient.pid

protocol=dyndns2
use=web
server=domains.google.com
ssl=yes
login='T0yOxpMLi2oIhvGc'
password='7dBE0TK5dhScgL4U'
oz.ddns.lanehensley.org

