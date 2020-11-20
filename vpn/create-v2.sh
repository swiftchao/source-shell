# network 
NUM_1=5
NUM_2=6
EXTERNAL_NETWORK_ID="1a841cc5-82dc-4dd4-9447-6f6a7ab6147d"
SUBNET_IP_PREFIX="10.168."
IMAGE_ID="d3cf1b90-f3af-41b1-87d7-97f6035f1109"
FLAVOR_ID="cf2G10G2VCPU"
VPN_PSK="asdfghjkl"
AUTH_ALGORITHM="sha1"
ENCRYPTION_ALGORITHM="3des"
IKE_VERSION="v2"
# ext
EXT_SUBNET_IP_PREFIX="11.168."
EXT_NUM_1=1
IMAGE_NAME=nfvt2019.qcow2
IS_INIT=false

function get_args_colume_value() {
  if [ -n "$1" ] && [ -n "$2" ] ; then 
    SHOW_CMD="${1}" 
    COLUME_NAME="${2}"
    ARGS_VALUE=$($SHOW_CMD | grep -w "$COLUME_NAME" | awk -F '|' '{if(NR==1) {print $3}}' | xargs)
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

function init() {
  if [ "$IS_INIT" == "true" ]; then
    # ext network
    echo openstack network create --external --provider-network-type vlan cf-vpn-network-external-$EXT_NUM_1
    openstack network create --external --provider-network-type vlan cf-vpn-network-external-$EXT_NUM_1

    EXT_NET_ID_1=$(get_args_id_value "openstack network list" "cf-vpn-network-external-$EXT_NUM_1")
    EXTERNAL_NETWORK_ID=$EXT_NET_ID_1
    
    # ext subnet
    echo openstack subnet create cf-vpn-external-subnet-$EXT_SUBNET_IP_PREFIX$EXT_NUM_1-24 --ip-version 4 --subnet-range $EXT_SUBNET_IP_PREFIX$EXT_NUM_1.0/24 --allocation-pool start=$EXT_SUBNET_IP_PREFIX$EXT_NUM_1.1,end=$EXT_SUBNET_IP_PREFIX$EXT_NUM_1.253 --gateway $EXT_SUBNET_IP_PREFIX$EXT_NUM_1.254 --network $EXT_NET_ID_1 --no-dhcp
    openstack subnet create cf-vpn-external-subnet-$EXT_SUBNET_IP_PREFIX$EXT_NUM_1-24 --ip-version 4 --subnet-range $EXT_SUBNET_IP_PREFIX$EXT_NUM_1.0/24 --allocation-pool start=$EXT_SUBNET_IP_PREFIX$EXT_NUM_1.1,end=$EXT_SUBNET_IP_PREFIX$EXT_NUM_1.253 --gateway $EXT_SUBNET_IP_PREFIX$EXT_NUM_1.254 --network $EXT_NET_ID_1 --no-dhcp
    
    # flavor
    echo openstack flavor create --id $FLAVOR_ID --swap 2048 --disk 10 --vcpus 2 $FLAVOR_ID
    openstack flavor create --id $FLAVOR_ID --swap 2048 --disk 10 --vcpus 2 $FLAVOR_ID
    
    # image
    echo glance image-create --name $IMAGE_NAME --file $IMAGE_NAME --disk-format qcow2 --container-format bare --visibility public --progress
    glance image-create --name $IMAGE_NAME --file img/$IMAGE_NAME --disk-format qcow2 --container-format bare --visibility public --progress
     
  fi
}

# create exe net subne image flavor
init

EXT_NET_ID_1=$(get_args_id_value "openstack network list" "cf-vpn-network-external-$EXT_NUM_1")
EXTERNAL_NETWORK_ID=$EXT_NET_ID_1

IMAGE_ID=$(get_args_id_value "openstack image list" "$IMAGE_NAME")

# network
echo openstack network create --internal  --provider-network-type vxlan cf-vpn-network-internal-$NUM_1
openstack network create --internal  --provider-network-type vxlan cf-vpn-network-internal-$NUM_1
echo openstack network create --internal  --provider-network-type vxlan cf-vpn-network-internal-$NUM_2
openstack network create --internal  --provider-network-type vxlan cf-vpn-network-internal-$NUM_2
NET_ID_1=$(get_args_id_value "openstack network list" "cf-vpn-network-internal-$NUM_1")
NET_ID_2=$(get_args_id_value "openstack network list" "cf-vpn-network-internal-$NUM_2")

# subent
echo openstack subnet create cf-vpn-internal-subnet-$SUBNET_IP_PREFIX$NUM_1-24 --ip-version 4 --subnet-range $SUBNET_IP_PREFIX$NUM_1.0/24 --allocation-pool start=$SUBNET_IP_PREFIX$NUM_1.1,end=$SUBNET_IP_PREFIX$NUM_1.253 --gateway $SUBNET_IP_PREFIX$NUM_1.254 --network $NET_ID_1 --no-dhcp
openstack subnet create cf-vpn-internal-subnet-$SUBNET_IP_PREFIX$NUM_1-24 --ip-version 4 --subnet-range $SUBNET_IP_PREFIX$NUM_1.0/24 --allocation-pool start=$SUBNET_IP_PREFIX$NUM_1.1,end=$SUBNET_IP_PREFIX$NUM_1.253 --gateway $SUBNET_IP_PREFIX$NUM_1.254 --network $NET_ID_1 --no-dhcp
echo openstack subnet create cf-vpn-internal-subnet-$SUBNET_IP_PREFIX$NUM_2-24 --ip-version 4 --subnet-range $SUBNET_IP_PREFIX$NUM_2.0/24 --allocation-pool start=$SUBNET_IP_PREFIX$NUM_2.1,end=$SUBNET_IP_PREFIX$NUM_2.253 --gateway $SUBNET_IP_PREFIX$NUM_2.254 --network $NET_ID_2 --no-dhcp
openstack subnet create cf-vpn-internal-subnet-$SUBNET_IP_PREFIX$NUM_2-24 --ip-version 4 --subnet-range $SUBNET_IP_PREFIX$NUM_2.0/24 --allocation-pool start=$SUBNET_IP_PREFIX$NUM_2.1,end=$SUBNET_IP_PREFIX$NUM_2.253 --gateway $SUBNET_IP_PREFIX$NUM_2.254 --network $NET_ID_2 --no-dhcp
SUBNET_ID_1=$(get_args_id_value "openstack subnet list" "cf-vpn-internal-subnet-$SUBNET_IP_PREFIX$NUM_1-24")
SUBNET_ID_2=$(get_args_id_value "openstack subnet list" "cf-vpn-internal-subnet-$SUBNET_IP_PREFIX$NUM_2-24")

# router
echo openstack router create cf-vpn-router-$NUM_1 --centralized
openstack router create cf-vpn-router-$NUM_1 --centralized
echo openstack router create cf-vpn-router-$NUM_2 --centralized
openstack router create cf-vpn-router-$NUM_2 --centralized
ROUTER_ID_1=$(get_args_id_value "openstack router list" "cf-vpn-router-$NUM_1")
ROUTER_ID_2=$(get_args_id_value "openstack router list" "cf-vpn-router-$NUM_2")

# router subent
echo openstack router add subnet $ROUTER_ID_1 $SUBNET_ID_1
openstack router add subnet $ROUTER_ID_1 $SUBNET_ID_1
echo openstack router add subnet $ROUTER_ID_2 $SUBNET_ID_2
openstack router add subnet $ROUTER_ID_2 $SUBNET_ID_2

#router set geteway
echo neutron router-gateway-set $ROUTER_ID_1 "${EXTERNAL_NETWORK_ID}" 
neutron router-gateway-set $ROUTER_ID_1 "${EXTERNAL_NETWORK_ID}" 
echo neutron router-gateway-set $ROUTER_ID_2 "${EXTERNAL_NETWORK_ID}" 
neutron router-gateway-set $ROUTER_ID_2 "${EXTERNAL_NETWORK_ID}" 

# port
echo openstack port create cf-vpn-port-$SUBNET_IP_PREFIX$NUM_1-1 --fixed-ip subnet=$SUBNT_ID_1,ip-address=$SUBNET_IP_PREFIX$NUM_1.1 --network $NET_ID_1
openstack port create cf-vpn-port-$SUBNET_IP_PREFIX$NUM_1-1 --fixed-ip subnet=$SUBNT_ID_1,ip-address=$SUBNET_IP_PREFIX$NUM_1.1 --network $NET_ID_1
echo openstack port create cf-vpn-port-$SUBNET_IP_PREFIX$NUM_2-1 --fixed-ip subnet=$SUBNT_ID_2,ip-address=$SUBNET_IP_PREFIX$NUM_2.1 --network $NET_ID_2
openstack port create cf-vpn-port-$SUBNET_IP_PREFIX$NUM_2-1 --fixed-ip subnet=$SUBNT_ID_2,ip-address=$SUBNET_IP_PREFIX$NUM_2.1 --network $NET_ID_2
PORT_ID_1=$(get_args_id_value "openstack port list" "cf-vpn-port-$SUBNET_IP_PREFIX$NUM_1-1")
PORT_ID_2=$(get_args_id_value "openstack port list" "cf-vpn-port-$SUBNET_IP_PREFIX$NUM_2-1")

# server vm
echo openstack server create --port $PORT_ID_1 --image $IMAGE_ID --flavor $FLAVOR_ID cf-vpn-vm-$NUM_1
openstack server create --port $PORT_ID_1 --image $IMAGE_ID --flavor $FLAVOR_ID cf-vpn-vm-$NUM_1
echo openstack server create --port $PORT_ID_2 --image $IMAGE_ID --flavor $FLAVOR_ID cf-vpn-vm-$NUM_2
openstack server create --port $PORT_ID_2 --image $IMAGE_ID --flavor $FLAVOR_ID cf-vpn-vm-$NUM_2

# vpn ikepolicy 
echo neutron vpn-ikepolicy-create --auth-algorithm $AUTH_ALGORITHM --encryption-algorithm $ENCRYPTION_ALGORITHM --ike-version $IKE_VERSION cf-ikepolicy-$NUM_1;
neutron vpn-ikepolicy-create --auth-algorithm $AUTH_ALGORITHM --encryption-algorithm $ENCRYPTION_ALGORITHM --ike-version $IKE_VERSION cf-ikepolicy-$NUM_1;
echo neutron vpn-ikepolicy-create --auth-algorithm $AUTH_ALGORITHM --encryption-algorithm $ENCRYPTION_ALGORITHM --ike-version $IKE_VERSION cf-ikepolicy-$NUM_2;
neutron vpn-ikepolicy-create --auth-algorithm $AUTH_ALGORITHM --encryption-algorithm $ENCRYPTION_ALGORITHM --ike-version $IKE_VERSION cf-ikepolicy-$NUM_2;
IKE_POLICY_ID_1=$(get_args_id_value "neutron vpn-ikepolicy-list" "cf-ikepolicy-$NUM_1")
IKE_POLICY_ID_2=$(get_args_id_value "neutron vpn-ikepolicy-list" "cf-ikepolicy-$NUM_2")

# vpn ipsecpolicy
echo neutron vpn-ipsecpolicy-create --auth-algorithm $AUTH_ALGORITHM --encryption-algorithm $ENCRYPTION_ALGORITHM cf-ipsecpolicy-$NUM_1
neutron vpn-ipsecpolicy-create --auth-algorithm $AUTH_ALGORITHM --encryption-algorithm $ENCRYPTION_ALGORITHM cf-ipsecpolicy-$NUM_1
echo neutron vpn-ipsecpolicy-create --auth-algorithm $AUTH_ALGORITHM --encryption-algorithm $ENCRYPTION_ALGORITHM cf-ipsecpolicy-$NUM_2
neutron vpn-ipsecpolicy-create --auth-algorithm $AUTH_ALGORITHM --encryption-algorithm $ENCRYPTION_ALGORITHM cf-ipsecpolicy-$NUM_2
IPSEC_POLICY_ID_1=$(get_args_id_value "neutron vpn-ipsecpolicy-list" "cf-ipsecpolicy-$NUM_1")
IPSEC_POLICY_ID_2=$(get_args_id_value "neutron vpn-ipsecpolicy-list" "cf-ipsecpolicy-$NUM_2")

# vpn vpn-service
echo neutron vpn-service-create $ROUTER_ID_1 $SUBNET_ID_1 --name cf-vpn-service-$NUM_1
neutron vpn-service-create $ROUTER_ID_1 $SUBNET_ID_1 --name cf-vpn-service-$NUM_1
echo neutron vpn-service-create $ROUTER_ID_2 $SUBNET_ID_2 --name cf-vpn-service-$NUM_2
neutron vpn-service-create $ROUTER_ID_2 $SUBNET_ID_2 --name cf-vpn-service-$NUM_2
VPN_SERVICE_ID_1=$(get_args_id_value "neutron vpn-service-list" "cf-vpn-service-$NUM_1")
VPN_SERVICE_ID_2=$(get_args_id_value "neutron vpn-service-list" "cf-vpn-service-$NUM_2")
VPN_SERVICE_V4_IP_1=$(get_args_colume_value "neutron vpn-service-show $VPN_SERVICE_ID_1" "external_v4_ip")
VPN_SERVICE_V4_IP_2=$(get_args_colume_value "neutron vpn-service-show $VPN_SERVICE_ID_2" "external_v4_ip")

# vpn ipsec-site-connection
echo neutron ipsec-site-connection-create --vpnservice-id $VPN_SERVICE_ID_1 --ikepolicy-id $IKE_POLICY_ID_1 --ipsecpolicy-id $IPSEC_POLICY_ID_1 --peer-id  $VPN_SERVICE_V4_IP_2 --peer-address  $VPN_SERVICE_V4_IP_2 --psk $VPN_PSK --peer-cidr $SUBNET_IP_PREFIX$NUM_2.0/24 --name cf-ipsec-site-connection-$NUM_1
#neutron ipsec-site-connection-create --vpnservice-id $VPN_SERVICE_ID_1 --ikepolicy-id $IKE_POLICY_ID_1 --ipsecpolicy-id $IPSEC_POLICY_ID_1 --peer-id  $VPN_SERVICE_V4_IP_2 --peer-address  $VPN_SERVICE_V4_IP_2 --psk $VPN_PSK --peer-cidr $SUBNET_IP_PREFIX$NUM_2.0/24 --name cf-ipsec-site-connection-$NUM_1

echo neutron ipsec-site-connection-create --vpnservice-id $VPN_SERVICE_ID_2 --ikepolicy-id $IKE_POLICY_ID_2 --ipsecpolicy-id $IPSEC_POLICY_ID_2 --peer-id  $VPN_SERVICE_V4_IP_1 --peer-address  $VPN_SERVICE_V4_IP_1 --psk $VPN_PSK --peer-cidr $SUBNET_IP_PREFIX$NUM_1.0/24 --name cf-ipsec-site-connection-$NUM_2
#neutron ipsec-site-connection-create --vpnservice-id $VPN_SERVICE_ID_2 --ikepolicy-id $IKE_POLICY_ID_2 --ipsecpolicy-id $IPSEC_POLICY_ID_2 --peer-id  $VPN_SERVICE_V4_IP_1 --peer-address  $VPN_SERVICE_V4_IP_1 --psk $VPN_PSK --peer-cidr $SUBNET_IP_PREFIX$NUM_1.0/24 --name cf-ipsec-site-connection-$NUM_2
neutron ipsec-site-connection-list

