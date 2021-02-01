ipsec whack --ctlbase /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/var/run/pluto --name c79fb178-7652-44ed-90c0-d0d3152a3e4b  --terminate
ipsec whack --ctlbase /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/var/run/pluto --name c79fb178-7652-44ed-90c0-d0d3152a3e4b  --shutdown

# start pluto IKE keying daemon
#ip netns exec qrouter-2237ed21-3726-43da-bf43-581239727ed4  ipsec pluto --ctlbase /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/var/run/pluto --ipsecdir /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/etc --use-netkey --uniqueids --nat_traversal --secretsfile  /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/etc/ipsec.secrets --virtual-private u%v4:10.168.61.0/24%v4:10.168.63.0/24 --perpeerlog --perpeerlogbase /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/log --logfile /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/log/peer.log --debug-all
ip netns exec qrouter-2237ed21-3726-43da-bf43-581239727ed4  ipsec pluto --ctlbase /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/var/run/pluto --ipsecdir /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/etc --use-netkey --uniqueids --nat_traversal --secretsfile  /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/etc/ipsec.secrets --virtual-private u%v4:10.168.61.0/24%v4:10.168.62.0/24%v4:10.168.63.0/24 --perpeerlog --perpeerlogbase /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/log --logfile /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/log/peer.log --debug-all

# add connections
ip netns exec qrouter-2237ed21-3726-43da-bf43-581239727ed4  ipsec addconn --ctlbase /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/var/run/pluto/pluto.ctl --defaultroutenexthop 11.168.1.13 --config /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/etc/ipsec.conf c79fb178-7652-44ed-90c0-d0d3152a3e4b

# start whack ipsec keying daemon
ip netns exec qrouter-2237ed21-3726-43da-bf43-581239727ed4  ipsec whack --ctlbase /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/var/run/pluto --listen

ip netns exec qrouter-2237ed21-3726-43da-bf43-581239727ed4  ipsec whack --ctlbase /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/var/run/pluto --name c79fb178-7652-44ed-90c0-d0d3152a3e4b/0x1 --asynchronous --initiate

ip netns exec qrouter-2237ed21-3726-43da-bf43-581239727ed4 ipsec whack --ctlbase /var/lib/neutron/ipsec/2237ed21-3726-43da-bf43-581239727ed4/var/run/pluto --status
