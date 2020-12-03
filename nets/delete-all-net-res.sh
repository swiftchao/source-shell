#!/usr/bin/bash
PROJECT_ID="0007b5c6817d4ba39280b972c28974e6"
PROJECT_ARGS="--project ${PROJECT_ID}"

function get_args_colume_value() {
  if [ -n "$1" ] && [ -n "$2" ] ; then
    SHOW_CMD="${1}"
    COLUME_NAME="${2}"
    ARGS_VALUE=$($SHOW_CMD | grep -w "$COLUME_NAME" | awk -F '|' '{if(NR==1) {print $3}}' | xargs)
    echo "$ARGS_VALUE"
  fi
}


function get_args_all_res() {
  if [ -n "$1" ]  && [ -n "$2" ]; then 
    LIST_CMD=""
    echo "${3}" | grep "grep" >/dev/null
    IS_GREP=$?
    if [ "${IS_GREP}" -eq 0 ]; then
      LIST_CMD="${1}"
      echo $LIST_CMD | grep "${2}" | grep "[a-z]"  | awk -F '|' '{print $2}' | grep -v ID | xargs | sed 's| |,|g'
      $LIST_CMD | grep "${2}" | grep "[a-z]"  | awk -F '|' '{print $2}' | grep -v ID | xargs | sed 's| |,|g'
    else
      LIST_CMD="${1} ${2}"
      echo $LIST_CMD | grep "[a-z]"  | awk -F '|' '{print $2}' | grep -v ID | xargs | sed 's| |,|g'
      $LIST_CMD | grep "[a-z]"  | awk -F '|' '{print $2}' | grep -v ID | xargs | sed 's| |,|g'
    fi
  fi
}

function get_ports() {
  echo $(get_args_all_res "openstack port list" "${PROJECT_ARGS}")
}

function get_subnets() {
  echo $(get_args_all_res "openstack subnet list" "${PROJECT_ARGS}")
}

function get_subnetpools() {
  echo $(get_args_all_res "openstack subnet pool list" "${PROJECT_ARGS}")
}

function get_networks() {
  echo $(get_args_all_res "openstack network list" "${PROJECT_ARGS}")
}

function get_routers() {
  echo $(get_args_all_res "openstack router list" "${PROJECT_ARGS}")
}

function get_vpcs() {
  echo $(get_args_all_res "openstack vpc list" "${PROJECT_ID}" "grep")
}

function do_router_remove_subnets() {
  if [ -n "${1}" ] && [ -n "${2}" ]; then
    ALL_ARGS_RES="${1}"
    EXEC_ARGS_CMD="${2}"
    OLD_IFS="${IFS}"
    IFS=",${now},"
    for tmp_res in ${ALL_ARGS_RES}; do
      res=$(openstack port show $tmp_res | egrep "device_owner|device_id|fixed_ips" | awk -F '|' '{print $3}' | xargs)
      device_id=$(echo "$res" | awk '{print $1}')
      device_owner=$(echo "$res" | awk '{print $2}')
      subnet_id=$(echo "$res" | awk '{print $4}' | awk -F '=' '{print $2}')
      echo "$device_owner" | grep "router" >/dev/null
      IS_ROUTER_PORT=$?
      if [ "$IS_ROUTER_PORT" -eq 0 ]; then
        echo "$device_id $device_owner $subnet_id"
        echo openstack router remove subnet $device_id $subnet_id
        openstack router remove subnet $device_id $subnet_id
      fi
    done
    IFS="${OLD_IFS}"
  fi
}


function exec_args_cmd_2_res() {
  if [ -n "${1}" ] && [ -n "${2}" ]; then 
    ALL_ARGS_RES="${1}"
    EXEC_ARGS_CMD="${2}"
    OLD_IFS="${IFS}"
    IFS=",${now},"
    for tmp_res in ${ALL_ARGS_RES}; do
      echo ${EXEC_ARGS_CMD} $tmp_res
      DO_EXEC_CMD="${EXEC_ARGS_CMD} $tmp_res"
      `$($DO_EXEC_CMD)`
    done
    IFS="${OLD_IFS}"
  fi
}

function do_delete_ports() {
  if [ -n "${1}" ]; then 
    ALL_ARGS_RES="${1}"
    OLD_IFS="${IFS}"
    IFS=",${now},"
    for tmp_res in ${ALL_ARGS_RES}; do
      echo "openstack port delete $tmp_res"
      openstack port delete $tmp_res
    done
    IFS="${OLD_IFS}"
  fi
}

function do_delete_subnets() {
  if [ -n "${1}" ]; then 
    ALL_ARGS_RES="${1}"
    OLD_IFS="${IFS}"
    IFS=",${now},"
    for tmp_res in ${ALL_ARGS_RES}; do
      echo "openstack subnet delete $tmp_res"
      openstack subnet delete $tmp_res
    done
    IFS="${OLD_IFS}"
  fi
}

function do_delete_subnetpools() {
  if [ -n "${1}" ]; then 
    ALL_ARGS_RES="${1}"
    OLD_IFS="${IFS}"
    IFS=",${now},"
    for tmp_res in ${ALL_ARGS_RES}; do
      echo "openstack subnet pool delete $tmp_res"
      openstack subnet pool delete $tmp_res
    done
    IFS="${OLD_IFS}"
  fi
}

function do_delete_networks() {
  if [ -n "${1}" ]; then 
    ALL_ARGS_RES="${1}"
    OLD_IFS="${IFS}"
    IFS=",${now},"
    for tmp_res in ${ALL_ARGS_RES}; do
      echo "openstack network delete $tmp_res"
      openstack network delete $tmp_res
    done
    IFS="${OLD_IFS}"
  fi
}

function do_clear_routers() {
  if [ -n "${1}" ]; then 
    ALL_ARGS_RES="${1}"
    OLD_IFS="${IFS}"
    IFS=",${now},"
    for tmp_res in ${ALL_ARGS_RES}; do
      echo "neutron router-gateway-clear $tmp_res"
      neutron router-gateway-clear $tmp_res
    done
    IFS="${OLD_IFS}"
  fi
}

function do_delete_routers() {
  if [ -n "${1}" ]; then 
    ALL_ARGS_RES="${1}"
    OLD_IFS="${IFS}"
    IFS=",${now},"
    for tmp_res in ${ALL_ARGS_RES}; do
      echo "openstack router delete $tmp_res"
      openstack router delete $tmp_res
    done
    IFS="${OLD_IFS}"
  fi
}

function do_delete_vpcs() {
  if [ -n "${1}" ]; then 
    ALL_ARGS_RES="${1}"
    OLD_IFS="${IFS}"
    IFS=",${now},"
    for tmp_res in ${ALL_ARGS_RES}; do
      echo "openstack vpc delete $tmp_res"
      openstack vpc delete $tmp_res
    done
    IFS="${OLD_IFS}"
  fi
}


function router_remove_subnets() {
  ALL_PORTS=$(get_ports)
  do_router_remove_subnets "${ALL_PORTS}" "openstack port show"
}

function delete_ports() {
  ALL_PORTS=$(get_ports)
  do_delete_ports "${ALL_PORTS}"
}

function delete_subnets() {
  ALL_SUBNETS=$(get_subnets)
  do_delete_subnets "${ALL_SUBNETS}"
}

function delete_subnetpools() {
  ALL_SUBNETPOOLS=$(get_subnetpools)
  do_delete_subnetpools "${ALL_SUBNETPOOLS}"
}

function delete_networks() {
  ALL_NETWORKS=$(get_networks)
  do_delete_networks "${ALL_NETWORKS}"
}

function clear_routers() {
  ALL_ROUTERS=$(get_routers)
  do_clear_routers "${ALL_ROUTERS}"
}

function delete_routers() {
  ALL_ROUTERS=$(get_routers)
  do_delete_routers "${ALL_ROUTERS}"
}

function delete_vpcs() {
  ALL_VPCS=$(get_vpcs)
  do_delete_vpcs "${ALL_VPCS}"
}

function delete_all() {
  router_remove_subnets
  delete_ports
  delete_subnets
  delete_subnetpools
  delete_networks
  clear_routers
  delete_routers
  delete_vpcs 
}

delete_all


