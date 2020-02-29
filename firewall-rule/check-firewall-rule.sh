########################################################################
# File Name: check.sh
# Author: chaofei
# mail: chaofeibest@163.com
# Created Time: 2020-02-24 15:10:38
#########################################################################
#!/bin/bash

export NSP_IP=172.21.202.14
export NSP_PORT=443
RESOURCE_CENTER_IP=
RESOURCE_CENTER_DB_IP=172.21.120.185
DB_USER=root
DB_PWD=root
DB_NAME=fitmgr_resourcecenter
IPGROUP=ipGroup
SERVICEGROUP=serviceGroup
FIREWALLRULE=firewallRule
ACTIVE=ACTIVE
OK_FILE_NAME=ok
ERROR_FILE_NAME=error
WRONG_FILE_NAME=wrong
OK=ok
WRONG=wrong

# EXPORT_DATA_SQL="SELECT uuid, src_ip_addresses, dst_ip_addresses, src_ports, dst_ports, protocol, action, status, created_at, firewall_rule_service_uuid, resource_type, resource_uuid, policy_uuid FROM  firewall_rule_services AS rule, firewall_rule_services_relation AS relation WHERE firewall_rule_service_uuid=rule.uuid AND firewall_rule_service_uuid= '24ae8da0-e047-4ab9-abd8-800230790ddd'"
# EXPORT_DATA_SQL="SELECT uuid, src_ip_addresses, dst_ip_addresses, src_ports, dst_ports, protocol, action, status, created_at, firewall_rule_service_uuid, resource_type, resource_uuid, policy_uuid FROM  firewall_rule_services AS rule, firewall_rule_services_relation AS relation WHERE firewall_rule_service_uuid=rule.uuid AND firewall_rule_service_uuid= '13655012-65a8-4bec-8df8-655ad6e387cd'"
# EXPORT_DATA_SQL="SELECT uuid, src_ip_addresses, dst_ip_addresses, src_ports, dst_ports, protocol, action, status, created_at, firewall_rule_service_uuid, resource_type, resource_uuid, policy_uuid FROM  firewall_rule_services AS rule, firewall_rule_services_relation AS relation WHERE firewall_rule_service_uuid=rule.uuid AND firewall_rule_service_uuid= '2863f8e7-1269-443d-874b-d8f8ee2a0d69'"
# EXPORT_DATA_SQL="SELECT uuid, src_ip_addresses, dst_ip_addresses, src_ports, dst_ports, protocol, action, status, created_at, firewall_rule_service_uuid, resource_type, resource_uuid, policy_uuid FROM  firewall_rule_services AS rule, firewall_rule_services_relation AS relation WHERE firewall_rule_service_uuid=rule.uuid AND firewall_rule_service_uuid= '2cb7ca0a-9510-4360-aaca-0becf136cec2'"
EXPORT_DATA_SQL="SELECT uuid, src_ip_addresses, dst_ip_addresses, src_ports, dst_ports, protocol, action, status, created_at, firewall_rule_service_uuid, resource_type, resource_uuid, policy_uuid FROM  firewall_rule_services AS rule, firewall_rule_services_relation AS relation WHERE firewall_rule_service_uuid=rule.uuid"

#############################################TOOLS FUNCTIONS##################################
if [ "${DEBUG}" == "true" ]; then
  set -x
fi

function load_args_file() {
  if [ -f "${1}" ]; then
    rpm -qa | grep dos2unix > /dev/null
    DOS2UNIX_IS_INSTALL=$?
    if [ "${DOS2UNIX_IS_INSTALL}" -eq 0 ]; then
      dos2unix "${1}" > /dev/null 2>&1
    fi
    source "${1}"
  fi
}

function convert_relative_path_to_absolute_path() {
  this="${0}"
  bin=`dirname "${this}"`
  script=`basename "${this}"`
  bin=`cd "${bin}"; pwd`
  this="${bin}/${script}"
}

function get_current_time() {
  CURRENT_TIME=`date +"%Y-%m-%d %H:%M:%S"`
  echo "${CURRENT_TIME}"
}

function get_current_ymdhms_time() {
  CURRENT_YMDHMS_TIME=$(date +"%Y-%m-%d-%H-%M-%S")
  echo "${CURRENT_YMDHMS_TIME}"
}

function get_current_user() {
  CURRENT_USER=`whoami`
  echo "${CURRENT_USER}"
}

function create_dir() {
  if [ ! -d "${1}" ]; then
    mkdir -p "${1}"
  fi
}

function safe_remove() {
  if [ -n "${1}" ]; then
    if [ -d "${1}" ] || [ -f "${1}" ] && [ "${1}" != "/" ]; then
      rm -rf "${1}"
    fi
  fi
}

function backup() {
  if [ -n "${1}" ] && [ -d "${1}" ] || [ -f "${1}" ]; then
    safe_remove "${1}.back"
    cp -r "${1}" "${1}.back"
  fi
}

#############################################NSP FUNCTIONS##################################

function get_nsp_token() {
   nsp_token_result=$(curl -H 'Content-Type:application/json' -X POST -d '{
   "grant_type":"password",
   "email":"x@yunshan.net.cn",
   "password":"admin"
 }' -k https://${NSP_IP}:${NSP_PORT}/auth/login)
  export nsp_token=$(echo ${nsp_token_result##*access_token} | awk -F ',' '{print $1}' | sed 's|"||g'| sed 's/:/Bearer/g')
  echo $nsp_token
}

function exec_args_query_in_nsp() {
  if [ -n "${1}" ]; then
    query_args_result=$(curl -H "Authorization:${nsp_token}" -X GET -k https://${NSP_IP}:${NSP_PORT}/${1})
    echo $query_args_result
  fi
}

function query_ip_group() {
  if [ -n "${1}" ]; then
    exec_args_query_in_nsp "api/cmp/v1/fwaas/ipgroups/${1}"
  fi
}

function query_service_group() {
  if [ -n "${1}" ]; then
    exec_args_query_in_nsp "api/cmp/v1/fwaas/servicegroups/${1}"
  fi
}

function get_args_field_value() {
  if [ -n "${1}" ] && [ -n "${2}" ]; then
    json_result="${1}"
    args_field_name="${2}"
    echo ${json_result#*${args_field_name}} | awk -F ',' '{print $1}' | sed 's|"||g' | sed 's|: ||g' | sed 's|}]||g' | sed 's|}||g'
  fi
}

function query_firewall_rules() {
  # 1uuid 2src_ip_addresses 3dst_ip_addresses 4src_ports 5dst_ports 6protocol 7action 8status 9created_at 10firewall_rule_service_uuid 11resource_type 12resource_uuid policy_uuid
  if [ -n "${1}" ] && [ -n "${2}" ] && [ -n "${3}" ] && [ -n "${4}" ] && [ -n "${5}" ] && [ -n "${6}" ]; then
    firewall_rule_uuid="${1}"
    src_ip_addresses="${2}"
    dst_ip_addresses="${3}"
    src_port="${4}"
    dst_ports="${5}"
    status="${6}"
    json_result=$(exec_args_query_in_nsp "api/cmp/v1/fwaas/firewall_rules/${firewall_rule_uuid}")
    export source_ip_group_uuid=$(get_args_field_value "${json_result}" "source_ip_group_uuid");
    export dest_ip_group_uuid=$(get_args_field_value "${json_result}" "dest_ip_group_uuid");
    export source_service_group_uuid=$(get_args_field_value "${json_result}" "source_service_group_uuid");
    export dest_service_group_uuid=$(get_args_field_value "${json_result}" "dest_service_group_uuid");
    # query s ipGroup
    s_ip_group_result=$(query_ip_group $source_ip_group_uuid)
    s_address_result=$(get_args_field_value "${s_ip_group_result}" "address")
    s_range_result=$(get_args_field_value "${s_ip_group_result}" "range")
    s_ip_group_is_ok="${WRONG}"
    d_ip_group_is_ok="${WRONG}"
    s_service_group_is_ok="${WRONG}"
    d_service_group_is_ok="${WRONG}"
    # address
    if [ -n "${s_address_result}" ] && [ "${s_address_result}" != "null" ]; then
      echo "${src_ip_addresses}" | grep -v grep | grep "${s_address_result}" > /dev/null 2>&1
      s_ip_group_tmp_address_is_ok="$?"
      if [ "${s_ip_group_tmp_address_is_ok}" -eq 0 ]; then
        s_ip_group_is_ok="${OK}"
      fi
    fi
    # range
    if [ -n "${s_range_result}" ] && [ "${s_range_result}" != "None-None" ]; then
      s_start_ip=$(echo "${s_range_result}" | awk -F '-'  '{print $1}')
      s_end_ip=$(echo "${s_range_result}" | awk -F '-'  '{print $2}')
      if [ "${s_start_ip}" == "${s_end_ip}" ]; then
        echo "${src_ip_addresses}" | grep -v grep | grep "${s_start_ip}" > /dev/null 2>&1
        s_ip_group_tmp_range_is_ok="$?"
        if [ "${s_ip_group_tmp_range_is_ok}" -eq 0 ]; then
          s_ip_group_is_ok="${OK}"
        fi
      else
        echo "${src_ip_addresses}" | grep -v grep | grep "${s_range_result}" > /dev/null 2>&1
        s_ip_group_tmp_range_is_ok="$?"
        if [ "${s_ip_group_tmp_range_is_ok}" -eq 0 ]; then
          s_ip_group_is_ok="${OK}"
        fi
      fi
    fi
   
    # query d ipGroup
    d_ip_group_result=$(query_ip_group $dest_ip_group_uuid)
    d_address_result=$(get_args_field_value "${d_ip_group_result}" "address")
    d_range_result=$(get_args_field_value "${d_ip_group_result}" "range")
    # address
    if [ -n "${d_address_result}" ] && [ "${d_address_result}" != "null" ]; then
      echo "${dst_ip_addresses}" | grep -v grep | grep "${d_address_result}" > /dev/null 2>&1
      d_ip_group_tmp_address_is_ok="$?"
      if [ "${d_ip_group_tmp_address_is_ok}" -eq 0 ]; then
        d_ip_group_is_ok="${OK}"
      fi
    fi
    # range
    if [ -n "${d_range_result}" ] && [ "${d_range_result}" != "None-None" ]; then
      d_start_ip=$(echo "${d_range_result}" | awk -F '-'  '{print $1}')
      d_end_ip=$(echo "${d_range_result}" | awk -F '-'  '{print $2}')
      if [ "${d_start_ip}" == "${d_end_ip}" ]; then
        echo "${dst_ip_addresses}" | grep -v grep | grep "${d_start_ip}" > /dev/null 2>&1
        d_ip_group_tmp_range_is_ok="$?"
        if [ "${d_ip_group_tmp_range_is_ok}" -eq 0 ]; then
          d_ip_group_is_ok="${OK}"
        fi
      else
        echo "${dst_ip_addresses}" | grep -v grep | grep "${d_range_result}" > /dev/null 2>&1
        d_ip_group_tmp_range_is_ok="$?"
        if [ "${d_ip_group_tmp_range_is_ok}" -eq 0 ]; then
          d_ip_group_is_ok="${OK}"
        fi
      fi
    fi    
    
    # query s serviceGroup
    s_service_group_result=$(query_service_group $source_service_group_uuid)
    s_port_max_result=$(get_args_field_value "${s_service_group_result}" "port_max")
    s_port_min_result=$(get_args_field_value "${s_service_group_result}" "port_min")
    # port_max
    if [ -n "${s_port_max_result}" ]; then
      echo "${src_port}" | grep -v grep | grep "${s_port_max_result}" > /dev/null 2>&1
      s_service_group_tmp_port_max_is_ok="$?"
      if [ "${s_service_group_tmp_port_max_is_ok}" -eq 0 ]; then
        s_service_group_is_ok="${OK}"
      else
        s_service_group_is_ok="${WRONG}"
      fi
    fi
    # port_min
    if [ -n "${s_port_min_result}" ]; then
      echo "${src_port}" | grep -v grep | grep "${s_port_min_result}" > /dev/null 2>&1
      s_service_group_tmp_port_min_is_ok="$?"
      if [ "${s_service_group_tmp_port_min_is_ok}" -eq 0 ]; then
        s_service_group_is_ok="${OK}"
      else
        s_service_group_is_ok="${WRONG}"
      fi
    fi
    
    # query d serviceGroup
    d_service_group_result=$(query_service_group $dest_service_group_uuid)
    d_port_max_result=$(get_args_field_value "${d_service_group_result}" "port_max")
    d_port_min_result=$(get_args_field_value "${d_service_group_result}" "port_min")
    # port_max
    if [ -n "${d_port_max_result}" ]; then
      echo "${dst_ports}" | grep -v grep | grep "${d_port_max_result}" > /dev/null 2>&1
      d_service_group_tmp_port_max_is_ok="$?"
      if [ "${d_service_group_tmp_port_max_is_ok}" -eq 0 ]; then
        d_service_group_is_ok="${OK}"
      else
        d_service_group_is_ok="${WRONG}"
      fi
    fi
    # port_min
    if [ -n "${d_port_min_result}" ]; then
      echo "${dst_ports}" | grep -v grep | grep "${d_port_min_result}" > /dev/null 2>&1
      d_service_group_tmp_port_min_is_ok="$?"
      if [ "${d_service_group_tmp_port_min_is_ok}" -eq 0 ]; then
        d_service_group_is_ok="${OK}"
      else
        d_service_group_is_ok="${WRONG}"
      fi
    fi
    
    ## total result
    if [ "${s_ip_group_is_ok}" == "ok" ] && [ "${d_ip_group_is_ok}" == "ok" ] && [ "${s_service_group_is_ok}" == "ok" ] && [ "${d_service_group_is_ok}" == "ok" ]; then
      echo "ok"
    else
      echo "wrong"
    fi
  fi
}

function exec_args_sql_in_mysql() {
  if [ -n "${1}" ]; then
    mysql -h ${RESOURCE_CENTER_DB_IP} -u${DB_USER} -p${DB_USER} ${DB_NAME} -e "${1}"
  fi
}

function export_mysql_data_2_csv() {
  CURRENT_USER=$(get_current_user)
  CURRENT_TIME=$(get_current_ymdhms_time)
  export CSV_FILE_NAME="${CURRENT_USER}-${CURRENT_TIME}.csv"
  exec_args_sql_in_mysql "${EXPORT_DATA_SQL}" > ${CSV_FILE_NAME}
}

function check_all_is_ok() {
  lINES=$(awk -F '\t' '{print $0}' $CSV_FILE_NAME | sed 's|\t|##|g')
  # OLD_IFS="${IFS}"
  # IFS=",${now},"
  create_dir "${OK_FILE_NAME}"
  create_dir "${ERROR_FILE_NAME}"
  create_dir "${WRONG_FILE_NAME}"
  CURRENT_USER=$(get_current_user)
  CURRENT_TIME=$(get_current_ymdhms_time)
  export OK_FILE="${OK_FILE_NAME}/${CURRENT_USER}-${CURRENT_TIME}-${OK_FILE_NAME}.csv"
  export ERROR_FILE="${ERROR_FILE_NAME}/${CURRENT_USER}-${CURRENT_TIME}-${ERROR_FILE_NAME}.csv"
  export WRONG_FILE="${WRONG_FILE_NAME}/${CURRENT_USER}-${CURRENT_TIME}-${WRONG_FILE_NAME}.csv"
  if [ -n "${lINES}" ]; then
    for LINE in ${lINES}; do
      if [ -n "${LINE}" ]; then
        # 1uuid 2src_ip_addresses 3dst_ip_addresses 4src_ports 5dst_ports 6protocol 7action 8status 9created_at 10firewall_rule_service_uuid 11resource_type 12resource_uuid policy_uuid
        uuid=$(echo "$LINE" | awk -F '##' '{print $1}')
        src_ip_addresses=$(echo "$LINE" | awk -F '##' '{print $2}')
        dst_ip_addresses=$(echo "$LINE" | awk -F '##' '{print $3}')
        src_ports=$(echo "$LINE" | awk -F '##' '{print $4}')
        dst_ports=$(echo "$LINE" | awk -F '##' '{print $5}')
        protocol=$(echo "$LINE" | awk -F '##' '{print $6}')
        action=$(echo "$LINE" | awk -F '##' '{print $7}')
        status=$(echo "$LINE" | awk -F '##' '{print $8}')
        created_at=$(echo "$LINE" | awk -F '##' '{print $9}')
        firewall_rule_service_uuid=$(echo "$LINE" | awk -F '##' '{print $10}')
        resource_type=$(echo "$LINE" | awk -F '##' '{print $11}')
        resource_uuid=$(echo "$LINE" | awk -F '##' '{print $12}')
        policy_uuid=$(echo "$LINE" | awk -F '##' '{print $13}')
        # echo "[$uuid $src_ip_addresses $dst_ip_addresses $src_ports $dst_ports $protocol $action $status $created_at $firewall_rule_service_uuid $resource_type $resource_uuid $policy_uuid]"
        if [ "${resource_type}" == "${FIREWALLRULE}" ]; then
          if [ "${status}" == "${ACTIVE}" ]; then
            check_result=$(query_firewall_rules "${resource_uuid}" "${src_ip_addresses}" "${dst_ip_addresses}" "${src_ports}" "${dst_ports}" "${status}")
            if [ -n "${check_result}" ] && [ "${check_result}" == "${OK}" ]; then
              echo -e "`get_current_time` [$uuid $src_ip_addresses $dst_ip_addresses $src_ports $dst_ports $protocol $action $status $created_at $firewall_rule_service_uuid $resource_type $resource_uuid $policy_uuid] -- \033[32mOK\033[0m"
              echo -e "[$uuid\t$src_ip_addresses\t$dst_ip_addresses\t$src_ports\t$dst_ports\t$protocol\t$action\t$status\t$created_at\t$firewall_rule_service_uuid\t$resource_type\t$resource_uuid\t$policy_uuid]" >> ${OK_FILE}
            else
              echo -e "`get_current_time` [$uuid $src_ip_addresses $dst_ip_addresses $src_ports $dst_ports $protocol $action $status $created_at $firewall_rule_service_uuid $resource_type $resource_uuid $policy_uuid] -- \033[31mWRONG\033[0m"
              echo -e "[$uuid\t$src_ip_addresses\t$dst_ip_addresses\t$src_ports\t$dst_ports\t$protocol\t$action\t$status\t$created_at\t$firewall_rule_service_uuid\t$resource_type\t$resource_uuid\t$policy_uuid]" >> ${WRONG_FILE}
            fi
          else
            echo -e "`get_current_time` [$uuid $src_ip_addresses $dst_ip_addresses $src_ports $dst_ports $protocol $action $status $created_at $firewall_rule_service_uuid $resource_type $resource_uuid $policy_uuid] -- \033[33mERROR\033[0m"
            echo -e "[$uuid\t$src_ip_addresses\t$dst_ip_addresses\t$src_ports\t$dst_ports\t$protocol\t$action\t$status\t$created_at\t$firewall_rule_service_uuid\t$resource_type\t$resource_uuid\t$policy_uuid]" >> ${ERROR_FILE}
          fi
          
        fi
      fi  
    done
  fi  
}

#############################################MAIN FUNCTIONS##################################
function main() {
  convert_relative_path_to_absolute_path
  get_nsp_token
  export_mysql_data_2_csv
  check_all_is_ok
}

main

