# network 
NUM_1=81
NUM_2=82
NUM_3=83
EXTERNAL_NETWORK_ID="50d90181-417c-466e-b6d3-6236b7169658"
SUBNET_IP_PREFIX="10.168."
IMAGE_ID="89c2442a-9948-476f-8f55-14a368a7d96f"
FLAVOR_ID="cf2G10G2VCPU"
VPN_PSK="asdfghjkl"

function get_args_id_value() {
  if [ -n "$1" ] && [ -n "$2" ] ; then 
    SHOW_CMD="${1}" 
    COLUME_NAME="${2}"
    ARGS_VALUE=$($SHOW_CMD | grep -w "$COLUME_NAME" | awk -F '|' '{print $3}' | xargs)
    echo "$ARGS_VALUE"
  fi
}

function get_args_id_value() {
  if [ -n "$1" ] ; then 
    SHOW_CMD="${1}" 
    NAME="${2}"
    ARGS_VALUE=$($SHOW_CMD | grep -w "$NAME" | awk '{if(NR==1){print $2}}' | xargs)
    echo "$ARGS_VALUE"
  fi
}

source /root/admin-openrc.sh

# vpn ipsec-site-connection
IPSEC_SITE_CONNECTION_1_2=$(get_args_id_value "neutron ipsec-site-connection-list" "cf-ipsec-site-connection-spoke-$NUM_1-to-hub-$NUM_2")
IPSEC_SITE_CONNECTION_3_2=$(get_args_id_value "neutron ipsec-site-connection-list" "cf-ipsec-site-connection-spoke-$NUM_3-to-hub-$NUM_2")
IPSEC_SITE_CONNECTION_2_1=$(get_args_id_value "neutron ipsec-site-connection-list" "cf-ipsec-site-connection-hub-$NUM_2-to-spoke-$NUM_1")
IPSEC_SITE_CONNECTION_2_3=$(get_args_id_value "neutron ipsec-site-connection-list" "cf-ipsec-site-connection-hub-$NUM_2-to-spoke-$NUM_3")
echo neutron ipsec-site-connection-delete $IPSEC_SITE_CONNECTION_1_2
neutron ipsec-site-connection-delete $IPSEC_SITE_CONNECTION_1_2
echo neutron ipsec-site-connection-delete $IPSEC_SITE_CONNECTION_3_2
neutron ipsec-site-connection-delete $IPSEC_SITE_CONNECTION_3_2
echo neutron ipsec-site-connection-delete $IPSEC_SITE_CONNECTION_2_1
neutron ipsec-site-connection-delete $IPSEC_SITE_CONNECTION_2_1
echo neutron ipsec-site-connection-delete $IPSEC_SITE_CONNECTION_2_3
neutron ipsec-site-connection-delete $IPSEC_SITE_CONNECTION_2_3
neutron ipsec-site-connection-list

# vpn vpn-service
VPN_SERVICE_ID_1=$(get_args_id_value "neutron vpn-service-list" "cf-vpn-service-$NUM_1")
VPN_SERVICE_ID_2=$(get_args_id_value "neutron vpn-service-list" "cf-vpn-service-$NUM_2")
VPN_SERVICE_ID_3=$(get_args_id_value "neutron vpn-service-list" "cf-vpn-service-$NUM_3")
echo neutron vpn-service-delete $VPN_SERVICE_ID_1
neutron vpn-service-delete $VPN_SERVICE_ID_1
echo neutron vpn-service-delete $VPN_SERVICE_ID_2
neutron vpn-service-delete $VPN_SERVICE_ID_2
echo neutron vpn-service-delete $VPN_SERVICE_ID_3
neutron vpn-service-delete $VPN_SERVICE_ID_3
neutron vpn-service-list

# vpn ipsecpolicy
IPSEC_POLICY_ID_1=$(get_args_id_value "neutron vpn-ipsecpolicy-list" "cf-ipsecpolicy-$NUM_1")
IPSEC_POLICY_ID_2=$(get_args_id_value "neutron vpn-ipsecpolicy-list" "cf-ipsecpolicy-$NUM_2")
IPSEC_POLICY_ID_3=$(get_args_id_value "neutron vpn-ipsecpolicy-list" "cf-ipsecpolicy-$NUM_3")
echo neutron vpn-ipsecpolicy-delete $IPSEC_POLICY_ID_1
neutron vpn-ipsecpolicy-delete $IPSEC_POLICY_ID_1
echo neutron vpn-ipsecpolicy-delete $IPSEC_POLICY_ID_2
neutron vpn-ipsecpolicy-delete $IPSEC_POLICY_ID_2
echo neutron vpn-ipsecpolicy-delete $IPSEC_POLICY_ID_3
neutron vpn-ipsecpolicy-delete $IPSEC_POLICY_ID_3

# vpn ikepolicy 
IKE_POLICY_ID_1=$(get_args_id_value "neutron vpn-ikepolicy-list" "cf-ikepolicy-$NUM_1")
IKE_POLICY_ID_2=$(get_args_id_value "neutron vpn-ikepolicy-list" "cf-ikepolicy-$NUM_2")
IKE_POLICY_ID_3=$(get_args_id_value "neutron vpn-ikepolicy-list" "cf-ikepolicy-$NUM_3")
echo neutron vpn-ikepolicy-delete $IKE_POLICY_ID_1 
neutron vpn-ikepolicy-delete $IKE_POLICY_ID_1 
echo neutron vpn-ikepolicy-delete $IKE_POLICY_ID_2
neutron vpn-ikepolicy-delete $IKE_POLICY_ID_2
echo neutron vpn-ikepolicy-delete $IKE_POLICY_ID_3
neutron vpn-ikepolicy-delete $IKE_POLICY_ID_3

# vpn-endpoint-group
LOCAL_SUBNET_ENDPOINT_GROUP_1=$(get_args_id_value "neutron vpn-endpoint-group-list" "cf-local-subnet-endpoint-subnet-$NUM_1")
LOCAL_SUBNET_ENDPOINT_GROUP_2=$(get_args_id_value "neutron vpn-endpoint-group-list" "cf-local-subnet-endpoint-subnet-$NUM_2")
LOCAL_SUBNET_ENDPOINT_GROUP_3=$(get_args_id_value "neutron vpn-endpoint-group-list" "cf-local-subnet-endpoint-subnet-$NUM_3")
LOCAL_CIDR_ENDPOINT_GROUP_2=$(get_args_id_value "neutron vpn-endpoint-group-list" "cf-local-cidr-endpoint-cidr-$NUM_2")
PEER_CIDR_ENDPOINT_GROUP_1=$(get_args_id_value "neutron vpn-endpoint-group-list" "cf-peer-cidr-endpoint-cidr-$NUM_1")
PEER_CIDR_ENDPOINT_GROUP_2=$(get_args_id_value "neutron vpn-endpoint-group-list" "cf-peer-cidr-endpoint-cidr-$NUM_2")
PEER_CIDR_ENDPOINT_GROUP_3=$(get_args_id_value "neutron vpn-endpoint-group-list" "cf-peer-cidr-endpoint-cidr-$NUM_3")
echo neutron vpn-endpoint-group-delete $LOCAL_SUBNET_ENDPOINT_GROUP_1
neutron vpn-endpoint-group-delete $LOCAL_SUBNET_ENDPOINT_GROUP_1
echo neutron vpn-endpoint-group-delete $LOCAL_SUBNET_ENDPOINT_GROUP_2
neutron vpn-endpoint-group-delete $LOCAL_SUBNET_ENDPOINT_GROUP_2
echo neutron vpn-endpoint-group-delete $LOCAL_SUBNET_ENDPOINT_GROUP_3
neutron vpn-endpoint-group-delete $LOCAL_SUBNET_ENDPOINT_GROUP_3
echo neutron vpn-endpoint-group-delete $PEER_CIDR_ENDPOINT_GROUP_1
neutron vpn-endpoint-group-delete $PEER_CIDR_ENDPOINT_GROUP_1
echo neutron vpn-endpoint-group-delete $PEER_CIDR_ENDPOINT_GROUP_2
neutron vpn-endpoint-group-delete $PEER_CIDR_ENDPOINT_GROUP_2
echo neutron vpn-endpoint-group-delete $PEER_CIDR_ENDPOINT_GROUP_3
neutron vpn-endpoint-group-delete $PEER_CIDR_ENDPOINT_GROUP_3
echo neutron vpn-endpoint-group-delete $LOCAL_CIDR_ENDPOINT_GROUP_2
neutron vpn-endpoint-group-delete $LOCAL_CIDR_ENDPOINT_GROUP_2

# server vm
VM_ID_1=$(get_args_id_value "openstack server list" "cf-vpn-vm-$NUM_1")
VM_ID_2=$(get_args_id_value "openstack server list" "cf-vpn-vm-$NUM_2")
VM_ID_3=$(get_args_id_value "openstack server list" "cf-vpn-vm-$NUM_3")
echo openstack server delete $VM_ID_1
openstack server delete $VM_ID_1
echo openstack server delete $VM_ID_2
openstack server delete $VM_ID_2
echo openstack server delete $VM_ID_3
openstack server delete $VM_ID_3

# port
PORT_ID_1=$(get_args_id_value "openstack port list" "cf-vpn-port-$SUBNET_IP_PREFIX$NUM_1-1")
PORT_ID_2=$(get_args_id_value "openstack port list" "cf-vpn-port-$SUBNET_IP_PREFIX$NUM_2-1")
PORT_ID_3=$(get_args_id_value "openstack port list" "cf-vpn-port-$SUBNET_IP_PREFIX$NUM_3-1")
echo openstack port delete $PORT_ID_1
openstack port delete $PORT_ID_1
echo openstack port delete $PORT_ID_2
openstack port delete $PORT_ID_2
echo openstack port delete $PORT_ID_3
openstack port delete $PORT_ID_3

# router
ROUTER_ID_1=$(get_args_id_value "openstack router list" "cf-vpn-router-$NUM_1")
ROUTER_ID_2=$(get_args_id_value "openstack router list" "cf-vpn-router-$NUM_2")
ROUTER_ID_3=$(get_args_id_value "openstack router list" "cf-vpn-router-$NUM_3")
#router set geteway
echo neutron router-gateway-clear $ROUTER_ID_1
neutron router-gateway-clear $ROUTER_ID_1
echo neutron router-gateway-clear $ROUTER_ID_2
neutron router-gateway-clear $ROUTER_ID_2
neutron router-gateway-clear $ROUTER_ID_3

# subent
SUBNET_ID_1=$(get_args_id_value "openstack subnet list" "cf-vpn-internal-subnet-$SUBNET_IP_PREFIX$NUM_1-24")
SUBNET_ID_2=$(get_args_id_value "openstack subnet list" "cf-vpn-internal-subnet-$SUBNET_IP_PREFIX$NUM_2-24")
SUBNET_ID_3=$(get_args_id_value "openstack subnet list" "cf-vpn-internal-subnet-$SUBNET_IP_PREFIX$NUM_3-24")
# router remove subent
echo openstack router remove subnet $ROUTER_ID_1 $SUBNET_ID_1
openstack router remove subnet $ROUTER_ID_1 $SUBNET_ID_1
echo openstack router remove subnet $ROUTER_ID_2 $SUBNET_ID_2
openstack router remove subnet $ROUTER_ID_2 $SUBNET_ID_2
echo openstack router remove subnet $ROUTER_ID_3 $SUBNET_ID_3
openstack router remove subnet $ROUTER_ID_3 $SUBNET_ID_3

# delete router
echo openstack router delete $ROUTER_ID_1
openstack router delete $ROUTER_ID_1
echo openstack router delete $ROUTER_ID_2
openstack router delete $ROUTER_ID_2

# delete subent
echo openstack subnet delete $SUBNET_ID_1
openstack subnet delete $SUBNET_ID_1
echo openstack subnet delete $SUBNET_ID_2
openstack subnet delete $SUBNET_ID_2
echo openstack subnet delete $SUBNET_ID_3
openstack subnet delete $SUBNET_ID_3

# network
NET_ID_1=$(get_args_id_value "openstack network list" "cf-vpn-network-internal-$NUM_1")
NET_ID_2=$(get_args_id_value "openstack network list" "cf-vpn-network-internal-$NUM_2")
NET_ID_3=$(get_args_id_value "openstack network list" "cf-vpn-network-internal-$NUM_3")
# delete network
echo openstack network delete $NET_ID_1
openstack network delete $NET_ID_1
echo openstack network delete $NET_ID_2
openstack network delete $NET_ID_2
echo openstack network delete $NET_ID_3
openstack network delete $NET_ID_3
