source /root/admin-openrc.sh
neutron ipsec-site-connection-list | grep cf-ipsec-site-connection-4[1-2]
neutron vpn-service-list | grep cf-vpn-service-4[1-2]
