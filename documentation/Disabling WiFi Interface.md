# Disabling WiFi Interface
Create a file:
```
$ sudo vi /etc/network/interfaces.d/wifi-disable
```
Add this line, changing the device name as needed:
```
iface wlan0 inet manual
```
Save the file, and issue this command:
```
$ sudo service network-manager restart
```
