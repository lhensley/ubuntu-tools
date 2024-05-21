# DNS resolution isn't working

Try editing ```/etc/systemd/resolved.conf``` and changing the ```DNS=``` entry to the IPv4 address of the router. For example, for server ```adam```, it's ```DNS=192.168.169.2```.