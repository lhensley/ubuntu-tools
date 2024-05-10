# oz-dynamic.yaml
network:
    version: 2
    renderer: NetworkManager
    ethernets:
        ethernet0:
            match:
                macaddress: 30:9c:23:8e:f3:bc
            set-name: ethernet0
            dhcp4: true
            dhcp6: true
            accept-ra: true
            ipv6-address-token: '::4'
            nameservers:
                addresses: [192.168.168.2, 8.8.8.8, '2001:4860:4860::8844']
                search: [lanehensley.org, local, lan]
    wifis:
        wifi0:
            match:
                macaddress: 68:ec:c5:43:62:0f
            set-name: wifi0
            access-points:
                "Hog Heaven DSM":
                    password: "fuckitymcfuckface"
            dhcp4: true
            dhcp6: true
            accept-ra: true
            ipv6-address-token: "::2:4"
#            activation-mode: manual
