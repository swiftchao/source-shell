# network 
NUM_1=31
NUM_2=32
NUM_3=33
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
VYOS_IMAGE_NAME=vyos-cloud-init.qcow2


function get_args_colume_value() {
  if [ -n "$1" ] && [ -n "$2" ] ; then 
    SHOW_CMD="${1}" 
    COLUME_NAME="${2}"
    ARGS_VALUE=$($SHOW_CMD | grep -w "$COLUME_NAME" | awk -F '|' '{if(NR==1) {print $3}}' | xargs)
    echo "$ARGS_VALUE"
  fi
}

source /root/admin-openrc.sh 


# ext network
#echo openstack network create --external --provider-network-type vxlan cf-vpn-network-external-$EXT_NUM_1
#openstack network create --external --provider-network-type vxlan cf-vpn-network-external-$EXT_NUM_1
EXT_NET_ID_1=$(get_args_colume_value "openstack network show cf-vpn-network-external-$EXT_NUM_1" "id")
EXTERNAL_NETWORK_ID=$EXT_NET_ID_1

# ext subnet
#echo openstack subnet create cf-vpn-external-subnet-$EXT_SUBNET_IP_PREFIX$EXT_NUM_1-24 --ip-version 4 --subnet-range $EXT_SUBNET_IP_PREFIX$EXT_NUM_1.0/24 --allocation-pool start=$EXT_SUBNET_IP_PREFIX$EXT_NUM_1.1,end=$EXT_SUBNET_IP_PREFIX$EXT_NUM_1.253 --gateway $EXT_SUBNET_IP_PREFIX$EXT_NUM_1.254 --network $EXT_NET_ID_1 --no-dhcp
#openstack subnet create cf-vpn-external-subnet-$EXT_SUBNET_IP_PREFIX$EXT_NUM_1-24 --ip-version 4 --subnet-range $EXT_SUBNET_IP_PREFIX$EXT_NUM_1.0/24 --allocation-pool start=$EXT_SUBNET_IP_PREFIX$EXT_NUM_1.1,end=$EXT_SUBNET_IP_PREFIX$EXT_NUM_1.253 --gateway $EXT_SUBNET_IP_PREFIX$EXT_NUM_1.254 --network $EXT_NET_ID_1 --no-dhcp
EXT_SUBNET_ID_1=$(get_args_colume_value "openstack subnet show cf-vpn-external-subnet-$EXT_SUBNET_IP_PREFIX$EXT_NUM_1-24" "id")

# flavor
#echo openstack flavor create --id $FLAVOR_ID --swap 2048 --disk 10 --vcpus 2 $FLAVOR_ID
#openstack flavor create --id $FLAVOR_ID --swap 2048 --disk 10 --vcpus 2 $FLAVOR_ID

# image
#echo glance image-create --name $VYOS_IMAGE_NAME --file img/$VYOS_IMAGE_NAME --disk-format qcow2 --container-format bare --visibility public --progress
#glance image-create --name $VYOS_IMAGE_NAME --file img/$VYOS_IMAGE_NAME --disk-format qcow2 --container-format bare --visibility public --progress
VYOS_IMAGE_ID=$(get_args_colume_value "openstack image show $VYOS_IMAGE_NAME" "id")

# port
echo openstack port create cf-vpn-port-$EXT_SUBNET_IP_PREFIX$EXT_NUM_1-$NUM_1 --fixed-ip subnet=$EXT_SUBNT_ID_1,ip-address=$EXT_SUBNET_IP_PREFIX$EXT_NUM_1.$NUM_1 --network $EXT_NET_ID_1
openstack port create cf-vpn-port-$EXT_SUBNET_IP_PREFIX$EXT_NUM_1-$NUM_1 --fixed-ip subnet=$EXT_SUBNT_ID_1,ip-address=$EXT_SUBNET_IP_PREFIX$EXT_NUM_1.$NUM_1 --network $EXT_NET_ID_1
EXT_PORT_ID_1=$(get_args_colume_value "openstack port show cf-vpn-port-$EXT_SUBNET_IP_PREFIX$EXT_NUM_1-$NUM_1" "id")
echo openstack port create cf-vpn-port-$EXT_SUBNET_IP_PREFIX$EXT_NUM_1-$NUM_2 --fixed-ip subnet=$EXT_SUBNT_ID_1,ip-address=$EXT_SUBNET_IP_PREFIX$EXT_NUM_1.$NUM_2 --network $EXT_NET_ID_1
openstack port create cf-vpn-port-$EXT_SUBNET_IP_PREFIX$EXT_NUM_1-$NUM_2 --fixed-ip subnet=$EXT_SUBNT_ID_1,ip-address=$EXT_SUBNET_IP_PREFIX$EXT_NUM_1.$NUM_2 --network $EXT_NET_ID_1
EXT_PORT_ID_2=$(get_args_colume_value "openstack port show cf-vpn-port-$EXT_SUBNET_IP_PREFIX$EXT_NUM_1-$NUM_2" "id")
echo openstack port create cf-vpn-port-$EXT_SUBNET_IP_PREFIX$EXT_NUM_1-$NUM_3 --fixed-ip subnet=$EXT_SUBNT_ID_1,ip-address=$EXT_SUBNET_IP_PREFIX$EXT_NUM_1.$NUM_3 --network $EXT_NET_ID_1
openstack port create cf-vpn-port-$EXT_SUBNET_IP_PREFIX$EXT_NUM_1-$NUM_3 --fixed-ip subnet=$EXT_SUBNT_ID_1,ip-address=$EXT_SUBNET_IP_PREFIX$EXT_NUM_1.$NUM_3 --network $EXT_NET_ID_1
EXT_PORT_ID_3=$(get_args_colume_value "openstack port show cf-vpn-port-$EXT_SUBNET_IP_PREFIX$EXT_NUM_1-$NUM_3" "id")


# server vm
echo openstack server create --port $EXT_PORT_ID_1 --image $VYOS_IMAGE_ID --flavor $FLAVOR_ID cf-vpn-vm-vyos-$NUM_1
openstack server create --port $EXT_PORT_ID_1 --image $VYOS_IMAGE_ID --flavor $FLAVOR_ID cf-vpn-vm-vyos-$NUM_1
echo openstack server create --port $EXT_PORT_ID_2 --image $VYOS_IMAGE_ID --flavor $FLAVOR_ID cf-vpn-vm-vyos-$NUM_2
openstack server create --port $EXT_PORT_ID_2 --image $VYOS_IMAGE_ID --flavor $FLAVOR_ID cf-vpn-vm-vyos-$NUM_2
echo openstack server create --port $EXT_PORT_ID_3 --image $VYOS_IMAGE_ID --flavor $FLAVOR_ID cf-vpn-vm-vyos-$NUM_3
openstack server create --port $EXT_PORT_ID_3 --image $VYOS_IMAGE_ID --flavor $FLAVOR_ID cf-vpn-vm-vyos-$NUM_3

