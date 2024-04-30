# go-static.yaml
network:
    version: 2
    renderer: NetworkManager
    ethernets:
        ethernet0:
            match:
                macaddress: 38:f7:cd:c7:17:36
            set-name: ethernet0
            dhcp4: false
            gateway4: 192.168.168.1
            dhcp6: false
            gateway6: '2604:2d80:5391:300:60f1:5bff:fe7a:1c3'
            addresses: 
                - 192.168.168.8/24
                - 2604:2d80:5391:300::3/64
            nameservers:
                addresses: [192.168.168.1, 8.8.8.8, '2001:4860:4860::8844']
                search: [lanehensley.org, local, lan]
    wifis:
        wifi0:
            match:
                macaddress: a8:41:f4:d4:2e:c4
            set-name: wifi0
            access-points:
                "network_ssid_name":
                    password: "**********"
            activation-mode: manual
