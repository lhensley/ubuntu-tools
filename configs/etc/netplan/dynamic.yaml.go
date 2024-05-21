# go-dynamic.yaml
network:
    version: 2
    renderer: NetworkManager
    ethernets:
        ethernet0:
            match:
                macaddress: 38:f7:cd:c7:17:36
            set-name: ethernet0
            dhcp4: true
            dhcp6: true
            accept-ra: true
            ipv6-address-token: '::8'
            nameservers:
                addresses: [192.168.168.1, 8.8.8.8, '2001:4860:4860::8844']
                search: [local, lan]
    wifis:
        wifi0:
            match:
                macaddress: a8:41:f4:d4:2e:c4
            set-name: wifi0
            access-points:
                "Hog Heaven DSM":
                    password: "fuckitymcfuckface"
            dhcp4: true
            dhcp6: true
            accept-ra: true
            ipv6-address-token: "::2:8"
#            activation-mode: manual
