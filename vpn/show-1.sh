source /root/admin-openrc.sh
neutron ipsec-site-connection-list | grep cf-ipsec-site-connection-[1-2]
neutron vpn-service-list | grep cf-vpn-service-[1-2]
