ipsec whack --ctlbase /var/lib/neutron/ipsec/8b0453f1-9e7e-4b76-a4be-95ef38cad459/var/run/pluto --name e1aff855-a835-4698-8549-31e0cd223681  --terminate
ipsec whack --ctlbase /var/lib/neutron/ipsec/8b0453f1-9e7e-4b76-a4be-95ef38cad459/var/run/pluto --name e1aff855-a835-4698-8549-31e0cd223681  --shutdown

# start pluto IKE keying daemon
ip netns exec qrouter-8b0453f1-9e7e-4b76-a4be-95ef38cad459  ipsec pluto --ctlbase /var/lib/neutron/ipsec/8b0453f1-9e7e-4b76-a4be-95ef38cad459/var/run/pluto --ipsecdir /var/lib/neutron/ipsec/8b0453f1-9e7e-4b76-a4be-95ef38cad459/etc --use-netkey --uniqueids --nat_traversal --secretsfile  /var/lib/neutron/ipsec/8b0453f1-9e7e-4b76-a4be-95ef38cad459/etc/ipsec.secrets --virtual-private u%v4:10.168.73.0/24%v4:10.168.71.0/24%v4:10.168.72.0/24 --perpeerlog --perpeerlogbase /var/lib/neutron/ipsec/8b0453f1-9e7e-4b76-a4be-95ef38cad459/log --logfile /var/lib/neutron/ipsec/8b0453f1-9e7e-4b76-a4be-95ef38cad459/log/peer.log --debug-all

# add connections
ip netns exec qrouter-8b0453f1-9e7e-4b76-a4be-95ef38cad459  ipsec addconn --ctlbase /var/lib/neutron/ipsec/8b0453f1-9e7e-4b76-a4be-95ef38cad459/var/run/pluto/pluto.ctl --defaultroutenexthop 11.168.1.10 --config /var/lib/neutron/ipsec/8b0453f1-9e7e-4b76-a4be-95ef38cad459/etc/ipsec.conf e1aff855-a835-4698-8549-31e0cd223681

# start whack ipsec keying daemon
ip netns exec qrouter-8b0453f1-9e7e-4b76-a4be-95ef38cad459  ipsec whack --ctlbase /var/lib/neutron/ipsec/8b0453f1-9e7e-4b76-a4be-95ef38cad459/var/run/pluto --listen

ip netns exec qrouter-8b0453f1-9e7e-4b76-a4be-95ef38cad459  ipsec whack --ctlbase /var/lib/neutron/ipsec/8b0453f1-9e7e-4b76-a4be-95ef38cad459/var/run/pluto --name e1aff855-a835-4698-8549-31e0cd223681/0x1 --asynchronous --initiate

ip netns exec qrouter-8b0453f1-9e7e-4b76-a4be-95ef38cad459 ipsec whack --ctlbase /var/lib/neutron/ipsec/8b0453f1-9e7e-4b76-a4be-95ef38cad459/var/run/pluto --status
