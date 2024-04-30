### Basic HTTPS configuration file for ddclient
#
# /etc/ddclient.conf
# nuc01
# root:root 600
#
syslog=yes
#mail=root
mail-failure=root
daemon=7200
pid=/var/run/ddclient.pid

# Google lanehensley.org
# SECTION DROPPED 2/11/2024
# protocol=dyndns2
# use=web
# #ipv6=yes
# #usev6=if, if=ethernet0
# #if-skip=Scope:Link
# server=domains.google.com
# ssl=yes
# login='gVPwHZhQC1wMwuug'
# password='qIHyhBhSQjhjcubg'
# lanehensley.org

# # Dynu dyn4.lanehensley.org
# daemon=60                                                    # Check every 60 seconds.
# syslog=yes                                                   # Log update msgs to syslog.
# mail=root                                                    # Mail all msgs to root.
# mail-failure=root                                            # Mail failed update msgs to root.
# pid=/var/run/ddclient.pid                                    # Record PID in file.
# ssl=yes
# use=web, web=checkip.dynu.com/, web-skip='IP Address'        # Get ip from server.
# server=api.dynu.com                                          # IP update server.
# protocol=dyndns2                        
# login=lanehensley                                            # Your username
# password=aDgD2VjTKNd2J@r6FCqv                                # Your password or MD5/SHA256 of password
# dynu4.lanehensley.org                                        # Update IP address for alias of your domain name
# #dyn4.lanehensley.org&alias=ALIAS                            # Update IP address for alias of your domain name

# Dynu lanehensley.dynu.com
# daemon=60                                                    # Check every 60 seconds.
syslog=yes                                                   # Log update msgs to syslog.
mail=root                                                    # Mail all msgs to root.
mail-failure=root                                            # Mail failed update msgs to root.
ssl=yes
pid=/var/run/ddclient.pid                                    # Record PID in file.
use=web, web=checkip.dynu.com/, web-skip='IP Address'        # Get ip from server.
# use=if, if=ethernet0
server=api.dynu.com                                          # IP update server.
protocol=dyndns2                        
login='lanehensley'                                            # Your username
# password='aDgD2VjTKNd2J@r6FCqv'                   # Your password or MD5/SHA256 of password
password='10967f4145ca7ad1a13c845dc574655127b0d1a98d2c32ed5ee98991e1a60b22'
go.lanehensley.org                              # List one or more hostnames one on each line.
# nuc01.lanehensley.org
# files.lanehensley.org

# # Dynu lanehensley.dynu.com
# syslog=yes                                      # Log update msgs to syslog.
# mail=root                                       # Mail all msgs to root.
# mail-failure=root                               # Mail failed update msgs to root.
# pid=/var/run/ddclient.pid                       # Record PID in file.
# use=if, if=eth0                                 # Get ip from hardware interface.
# server=api.dynu.com                             # IP update server.
# protocol=dyndns2                        
# ssl=yes
# login=lanehensley                               # Your username.
# password=aDgD2VjTKNd2J@r6FCqv                   # Your password or MD5/SHA256 of password
# lanehensley.dynu.com                            # List one or more hostnames one on each line.

# Google nuc01.lanehensley.org
# SECTION DROPPED 2/11/2024
# protocol=dyndns2
# use=web
# #ipv6=yes
# #usev6=if, if=ethernet0
# #if-skip=Scope:Link
# server=domains.google.com
# ssl=yes
# login='Jbg23fR0bwZ7Jm5J'
# password='E6acADdbXUv9A6Aj'
# nuc01.lanehensley.org

# Google scalcp83.org
# SECTION DROPPED 2/11/2024
# protocol=dyndns2
# use=web
# #ipv6=yes
# #usev6=if, if=ethernet0
# #if-skip=Scope:Link
# server=domains.google.com
# ssl=yes
# login='1PBmz1LFhxrYXxlX'
# password='JuLP3tsV253eoUwI'
# svalcp83.org

# protocol=dyndns2
# use=web
# server=domains.google.com
# ssl=yes
# login='ZTxZ5sTVfRLqROHg'
# password='THLnwnTUDixd66pA'
# nuc01.lanehensley.org

# protocol=dyndns2
# usev6=web
# server=domains.google.com
# ssl=yes
# login='bi2OZwXRhBsZc6Rs'
# password='YXTaOmGIxj8AkvcQ'
# test.lanehensley.org

# protocol=dyndns2
# use=web
# server=domains.google.com
# ssl=yes
# login='7cdwe5byN9wzmswI'
# password='RLPaPkua71NuCWjI'
# nuc01.ddns.lanehensley.org

