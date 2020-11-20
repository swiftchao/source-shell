ROUTER_ID="4236716b-2ed6-410d-bec4-4c3044194b97"
CON_ID="4fdcad75-604a-496f-b0dd-c7ccdc37f79f"
NEXT_HOP="11.168.1.19"
VIRTUAL_PRIVATE="u%v4:10.168.6.0/24%v4:10.168.5.0/24"

ip netns exec qrouter-${ROUTER_ID} ipsec whack --ctlbase /var/lib/neutron/ipsec/${ROUTER_ID}/var/run/pluto --status
