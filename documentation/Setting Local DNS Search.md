# Setting Local DNS Search
_Ref: https://itsfoss.com/resolvconf-permanent-ubuntu/_

_Note: This assumes you have resolvconf installed. If not:_
```
$ sudo apt-get install resolvconf
```
Edit this file:
```
$ sudo vi /etc/resolvconf/resolv.conf.d/base
```
Add this line:
```
domain lanehensley.org
```
Save the file and run this command:
```
$ sudo dpkg-reconfigure resolvconf
```
Reboot will be required.