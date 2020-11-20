ROUTER_ID="04a39f52-c89f-4f78-be73-2159ac431eb7"
CON_ID="4819966c-4883-4ab8-94dd-7a1896f7a0fb"
NEXT_HOP="11.168.1.8"
VIRTUAL_PRIVATE="u%v4:10.168.5.0/24%v4:10.168.6.0/24"

ip netns exec qrouter-${ROUTER_ID} ipsec whack --ctlbase /var/lib/neutron/ipsec/${ROUTER_ID}/var/run/pluto --status
