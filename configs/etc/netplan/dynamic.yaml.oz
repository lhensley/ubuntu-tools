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
    wifis:
        wifi0:
            match:
                macaddress: 68:ec:c5:43:62:0f
            set-name: wifi0
            access-points:
                "network_ssid_name":
                    password: "**********"
            accept-ra: true
            ipv6-address-token: "::2:4"
#            activation-mode: manual