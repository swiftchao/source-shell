########################################################################
# File Name: check.sh
# Author: chaofei
# mail: chaofeibest@163.com
# Created Time: 2020-06-22 14:10:38
#########################################################################
#!/bin/bash

export NSP_IP=172.21.202.14
export NSP_PORT=443

### localhost
RESOURCE_CENTER_IP=localhost
RESOURCE_CENTER_DB_IP=localhost
DB_NAME=jx_sc_20200619
### localhost end

### jx sc
#RESOURCE_CENTER_IP=172.21.120.184
#RESOURCE_CENTER_DB_IP=172.21.120.185
#DB_NAME=fitmgr_resourcecenter
### jx sc end

RESOURCE_CENTER_PORT=9988
DB_USER=root
DB_PWD=root

ACTIVE=ACTIVE
OK_FILE_NAME=ok
ERROR_FILE_NAME=error
WRONG_FILE_NAME=wrong
OK=ok
WRONG=wrong

EXPORT_DATA_SQL_1="SELECT UUID,cidr,prefix_id,STATUS FROM ipam_pools WHERE cidr BETWEEN '10.225.56.0/24' AND '10.225.63.0/24' AND STATUS = 'free';"
EXPORT_DATA_SQL_2="SELECT UUID,cidr,prefix_id,STATUS FROM ipam_pools WHERE cidr BETWEEN '10.225.120.0/24' AND '10.225.127.0/24' AND STATUS = 'free';"
EXPORT_DATA_SQL="${EXPORT_DATA_SQL_1}@${EXPORT_DATA_SQL_2}"
EXPORT_SUBNET_SQL="SELECT UUID,NAME,prefixlen,ip_subnetpool_id,cidr,gateway,segment_type,segment_id,vpc_id,resource_zone_id,STATUS FROM subnet WHERE cidr ='10.225.61.0/24';"


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

function exec_args_query_in_cmp() {
  if [ -n "${1}" ]; then
    query_args_result=$(curl -H "" -X GET -k http://${RESOURCE_CENTER_IP}:${RESOURCE_CENTER_PORT}/${1})
    echo $query_args_result
  fi
}

function exec_args_put_in_cmp() {
  if [ -n "${1}" ] && [ -n "${2}" ]; then
  # -XPUT -HContent-type:text/plain --data "stuff:morestuff"
    query_args_result=$(curl -H "" -XPUT -HContent-type:application/json --data "${2}" -k http://${RESOURCE_CENTER_IP}:${RESOURCE_CENTER_PORT}/${1})
    echo $query_args_result
  fi
}

function exec_args_post_in_cmp() {
  if [ -n "${1}" ] && [ -n "${2}" ]; then
  # -XPUT -HContent-type:text/plain --data "stuff:morestuff"
    query_args_result=$(curl -H "" -XPOST -HContent-type:application/json --data "${2}" -k http://${RESOURCE_CENTER_IP}:${RESOURCE_CENTER_PORT}/${1})
    echo $query_args_result
  fi
}

function query_ip_subnetpool_get_cidrs() {
  if [ -n "${1}" ]; then
    exec_args_query_in_cmp "v1/ip_subnetpools/${1}/get_cidrs"
  fi
}

function ip_subnetpool_remove_cidrs() {
  if [ -n "${1}" ] && [ -n "${2}" ] && [ -n "${3}" ]; then
    body="{
\"uuid\":\"${2}\",
\"cidr\":\"${3}\"
}"
    exec_args_put_in_cmp "v1/ip_subnetpools/${1}/remove_prefix" "${body}"
  fi
}

function create_port() {
  if [ -n "${1}" ] && [ -n "${2}" ] && [ -n "${3}" ] && [ -n "${4}" ]; then
    body="{
\"name\":\"${1}\",
\"description\":\"${2}\",
\"ip_address\":\"${3}\",
\"subnet_id\":\"${4}\"
}"
    post_result=`exec_args_post_in_cmp "v1/ports" "${body}"`
    echo "$post_result"
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
    echo ${json_result#*${args_field_name}} | awk -F ',' '{print $1}' | sed 's|"||g' | sed 's|: ||g' | sed 's|}]||g' | sed 's|}||g' | sed 's|:||g'
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
  OLD_IFS="${IFS}"
  IFS="@${now}@"
  for ARGS_EXEC_SQL in ${EXPORT_DATA_SQL}; do
    exec_args_sql_in_mysql "${ARGS_EXEC_SQL}" >> ${CSV_FILE_NAME}
  done
  IFS="${OLD_IFS}"
}

function query_subnet_info_in_mysql_2_csv() {
  CURRENT_USER=$(get_current_user)
  CURRENT_TIME=$(get_current_ymdhms_time)
  export CSV_FILE_NAME="${CURRENT_USER}-${CURRENT_TIME}-subnet.csv"
  OLD_IFS="${IFS}"
  IFS="@${now}@"
  for ARGS_EXEC_SQL in ${EXPORT_SUBNET_SQL}; do
    exec_args_sql_in_mysql "${ARGS_EXEC_SQL}" >> ${CSV_FILE_NAME}
  done
  IFS="${OLD_IFS}"
}

function delete_cidr_in_cmp_db() {
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
        # 1uuid 2cidr 3prefix_id 4status
        echo ${LINE} | grep -v "^UUID"
        IS_NOT_HEADER=$?
        if [ "${IS_NOT_HEADER}" -eq "0" ]; then
          # echo ${LINE}
          uuid=$(echo "$LINE" | awk -F '##' '{print $1}')
          # 1230 code ipam_pools uuid is ip_subnetpool_id new code has ip_subnetpool_id colume
          ip_subnetpool_id=$(echo "$LINE" | awk -F '##' '{print $1}')
          cidr=$(echo "$LINE" | awk -F '##' '{print $2}')
          prefix_id=$(echo "$LINE" | awk -F '##' '{print $3}')
          status=$(echo "$LINE" | awk -F '##' '{print $4}')
          exec_args_sql_in_mysql "DELETE FROM ipam_pools WHERE cidr='${cidr}' AND STATUS='free' AND prefix_id='${prefix_id}';"
          RESULT=`exec_args_sql_in_mysql "SELECT * FROM ipam_pools WHERE cidr='${cidr}' AND STATUS='free' AND prefix_id='${prefix_id}';"`
          echo "${RESULT}" | grep -v "^UUID" | grep "[a-z]"    
          QUERY_RESULT=$?
          if [ "${QUERY_RESULT}" -ne 0 ]; then
            echo -e "`get_current_time` [DELETE cidr='${cidr}' AND STATUS='free' AND prefix_id='${prefix_id}']  -- \033[32mOK\033[0m"
            echo -e "`get_current_time` [$uuid\t$cidr\t$prefix_id\t$status\t$ip_subnetpool_id]" >> ${OK_FILE}
          else
            echo -e "`get_current_time` [DELETE cidr='${cidr}' AND STATUS='free' AND prefix_id='${prefix_id}'] -- \033[33mERROR\033[0m"
            echo -e "`get_current_time` [$uuid\t$cidr\t$prefix_id\t$status\t$ip_subnetpool_id]" >> ${ERROR_FILE}
          fi
        fi
        
       
      fi  
    done
  fi  
}

function create_port_by_subent_id() {
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
  export EXIST_PORT_FILE="${WRONG_FILE_NAME}/${CURRENT_USER}-${CURRENT_TIME}-${WRONG_FILE_NAME}.csv"
  export EXIST_PORT_CSV_FILE_NAME="${CURRENT_USER}-${CURRENT_TIME}-exist-port.csv"
  if [ -n "${lINES}" ]; then
    for LINE in ${lINES}; do
      if [ -n "${LINE}" ]; then
        # 1uuid 2name 3prefixlen 4ip_subnetpool_id 5cidr 6gateway 7segment_type 8segment_id 9vpc_id 10resource_zone_id 11status
        echo ${LINE} | grep -v "^UUID"
        IS_NOT_HEADER=$?
        if [ "${IS_NOT_HEADER}" -eq "0" ]; then
          # echo ${LINE}
          subnet_id=$(echo "$LINE" | awk -F '##' '{print $1}')
          name=$(echo "$LINE" | awk -F '##' '{print $2}')
          prefixlen=$(echo "$LINE" | awk -F '##' '{print $3}')
          ip_subnetpool_id=$(echo "$LINE" | awk -F '##' '{print $4}')
          cidr=$(echo "$LINE" | awk -F '##' '{print $5}')
          gateway=$(echo "$LINE" | awk -F '##' '{print $6}')
          segment_type=$(echo "$LINE" | awk -F '##' '{print $7}')
          segment_id=$(echo "$LINE" | awk -F '##' '{print $8}')
          vpc_id=$(echo "$LINE" | awk -F '##' '{print $9}')
          resource_zone_id=$(echo "$LINE" | awk -F '##' '{print $10}')
          status=$(echo "$LINE" | awk -F '##' '{print $11}')
          if [ ${status} == "ACTIVE" ]; then
            exec_args_sql_in_mysql "SELECT UUID,ip_address,subnet_id FROM PORT WHERE subnet_id='${subnet_id}' ORDER BY ip_address DESC;" >> "${EXIST_PORT_CSV_FILE_NAME}"
            begin_port_ip=$(echo "$cidr" | awk -F '/' '{print $1}')
            begin_port_ip_end_num=$(echo "$begin_port_ip" | awk -F '.' '{print $4}')
            begin_port_ip_prefix=$(echo "$begin_port_ip" | sed "s|.${begin_port_ip_end_num}$|.|")
            # 10.225.61.254 10.225.61.0/24 10.225.61.0 10.225.61.1
            let begin_port_ip_end_num++;
            while [ ${begin_port_ip_end_num} -lt 254 ]; do
              current_port_ip="$begin_port_ip_prefix$begin_port_ip_end_num"
              grep -w "${current_port_ip}" "${EXIST_PORT_CSV_FILE_NAME}" /dev/null 2>&1
              IS_EXIST_PORT=$?
              if [ "$IS_EXIST_PORT" -ne 0 ]; then
                create_result=`create_port "manual_allocated_${current_port_ip}" "manual_allocated_${current_port_ip}" "${current_port_ip}" "${subnet_id}"`
                create_port_result_code=$(get_args_field_value "${create_result}" "code")
                if [ "${create_port_result_code}" -eq 0 ]; then
                  echo -e "`get_current_time` [manual_allocated_${current_port_ip}\tmanual_allocated_${current_port_ip}\t${current_port_ip}\t${subnet_id}]  -- \033[32mOK\033[0m"
                  echo -e "`get_current_time` [manual_allocated_${current_port_ip}\tmanual_allocated_${current_port_ip}\t${current_port_ip}\t${subnet_id}]" >> ${OK_FILE}
                else
                  echo -e "`get_current_time` [manual_allocated_${current_port_ip}\tmanual_allocated_${current_port_ip}\t${current_port_ip}\t${subnet_id}] -- \033[33mERROR\033[0m"
                  echo -e "`get_current_time` [manual_allocated_${current_port_ip}\tmanual_allocated_${current_port_ip}\t${current_port_ip}\t${subnet_id}]" >> ${ERROR_FILE}
                fi
              fi
              let begin_port_ip_end_num++;
            done
          fi
        fi
        
       
      fi  
    done
  fi  
}


#############################################MAIN FUNCTIONS##################################
function main() {
  convert_relative_path_to_absolute_path
  #get_nsp_token
  export_mysql_data_2_csv
  delete_cidr_in_cmp_db
  query_subnet_info_in_mysql_2_csv
  create_port_by_subent_id
}

main

