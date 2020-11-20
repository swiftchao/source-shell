ROUTER_ID="4236716b-2ed6-410d-bec4-4c3044194b97"
CON_ID="4fdcad75-604a-496f-b0dd-c7ccdc37f79f"
NEXT_HOP="11.168.1.19"
VIRTUAL_PRIVATE="u%v4:10.168.6.0/24%v4:10.168.5.0/24"

ipsec whack --ctlbase /var/lib/neutron/ipsec/${ROUTER_ID}/var/run/pluto --name ${ROUTER_ID} --terminate
ipsec whack --ctlbase /var/lib/neutron/ipsec/${ROUTER_ID}/var/run/pluto --name ${ROUTER_ID} --shutdown

ip netns exec qrouter-${ROUTER_ID}  ipsec pluto --ctlbase /var/lib/neutron/ipsec/${ROUTER_ID}/var/run/pluto --ipsecdir /var/lib/neutron/ipsec/${ROUTER_ID}/etc --use-netkey --uniqueids --nat_traversal --secretsfile  /var/lib/neutron/ipsec/${ROUTER_ID}/etc/ipsec.secrets --virtual-private ${VIRTUAL_PRIVATE} --perpeerlog --perpeerlogbase /var/lib/neutron/ipsec/${ROUTER_ID}/log --logfile /var/lib/neutron/ipsec/${ROUTER_ID}/log/peer.log --debug-all --nssdir /var/lib/neutron/ipsec/${ROUTER_ID}/etc/ipsec.d
#ip netns exec qrouter-${ROUTER_ID}  ipsec pluto --ctlbase /var/lib/neutron/ipsec/${ROUTER_ID}/var/run/pluto --ipsecdir /var/lib/neutron/ipsec/${ROUTER_ID}/etc --use-netkey --uniqueids --nat_traversal --secretsfile  /var/lib/neutron/ipsec/${ROUTER_ID}/etc/ipsec.secrets --virtual-private ${VIRTUAL_PRIVATE} --perpeerlog --perpeerlogbase /var/lib/neutron/ipsec/${ROUTER_ID}/log --logfile /var/lib/neutron/ipsec/${ROUTER_ID}/log/peer.log --debug-all

# add connections
ip netns exec qrouter-${ROUTER_ID}  ipsec addconn --ctlbase /var/lib/neutron/ipsec/${ROUTER_ID}/var/run/pluto/pluto.ctl --defaultroutenexthop ${NEXT_HOP} --config /var/lib/neutron/ipsec/${ROUTER_ID}/etc/ipsec.conf ${CON_ID}

# start whack ipsec keying daemon
ip netns exec qrouter-${ROUTER_ID}  ipsec whack --ctlbase /var/lib/neutron/ipsec/${ROUTER_ID}/var/run/pluto --listen

ip netns exec qrouter-${ROUTER_ID}  ipsec whack --ctlbase /var/lib/neutron/ipsec/${ROUTER_ID}/var/run/pluto --name ${CON_ID}/0x1 --asynchronous --initiate

ip netns exec qrouter-${ROUTER_ID} ipsec whack --ctlbase /var/lib/neutron/ipsec/${ROUTER_ID}/var/run/pluto --status
