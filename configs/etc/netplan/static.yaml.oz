# oz-static.yaml
network:
    version: 2
    renderer: NetworkManager
    ethernets:
        ethernet0:
            match:
                macaddress: 30:9c:23:8e:f3:bc
            set-name: ethernet0
            dhcp4: false
            gateway4: 192.168.169.2
            dhcp6: false
            gateway6: '2604:2d80:5391:300:60f1:5bff:fe7a:1c3'
            addresses: 
                - 192.168.169.4/24
                - 2604:2d80:5391:300::4/64
            nameservers:
                addresses: [192.168.169.2, 8.8.8.8, '2001:4860:4860::8844']
                search: [lanehensley.org, local, lan]
    wifis:
        wifi0:
            match:
                macaddress: 68:ec:c5:43:62:0f
            set-name: wifi0
            access-points:
                "network_ssid_name":
                    password: "**********"
            activation-mode: manual
