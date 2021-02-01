#!/bin/bash
ALL_NODES="controller-1,controller-2,controller-3"
#ALL_NODES="controller-2,controller-3"
#ALL_NODES="cdpm01,cdpm02,cdpm03"

function exec_args_cmd() {
  if [ -n "$1" ]; then
    EXEC_CMD="$1"
    OLD_IFS="${IFS}"
    IFS=",${now},"
    for nodes in ${ALL_NODES}; do
      ssh $nodes "$EXEC_CMD"
      echo "exec $EXEC_CMD on node host $nodes success"
    done
    IFS="${OLD_IFS}"
  fi
}

function scp_args_files () {
  if [ -n "$1" ] && [ "$2" ]; then
    SRC_FILE="$1"
    DST_DIR="$2"
    OLD_IFS="${IFS}"
    IFS=",${now},"
    for nodes in ${ALL_NODES}; do
      UPDATE_HOST=$nodes
      scp -r  "$SRC_FILE" $UPDATE_HOST:"$DST_DIR"
    done
    echo "update the node host $UPDATE_HOST all success"
    IFS="${OLD_IFS}"
  fi
}

function delete_pyc_file() {
#  exec_args_cmd "ls /usr/lib/python2.7/site-packages/drmanager/api/controllers/v1/backup_group.pyc"
#  exec_args_cmd "rm -rf /usr/lib/python2.7/site-packages/drmanager/api/controllers/v1/backup_group.pyc"
#  exec_args_cmd "ls /usr/lib/python2.7/site-packages/drmanager/api/controllers/v1/backup_group.pyc"

  exec_args_cmd "ls /usr/lib/python2.7/site-packages/drmanager/api/manager.pyc"
  exec_args_cmd "rm -rf /usr/lib/python2.7/site-packages/drmanager/api/manager.pyc"
  exec_args_cmd "ls /usr/lib/python2.7/site-packages/drmanager/api/manager.pyc"

#  exec_args_cmd "ls /usr/lib/python2.7/site-packages/drmanager/api/controllers/v1/recovery_group.pyc"
#  exec_args_cmd "rm -rf /usr/lib/python2.7/site-packages/drmanager/api/controllers/v1/recovery_group.pyc"
#  exec_args_cmd "ls /usr/lib/python2.7/site-packages/drmanager/api/controllers/v1/recovery_group.pyc"

  exec_args_cmd "ls /usr/lib/python2.7/site-packages/drmanager/db/sqlalchemy/drmanager_api.pyc"
  exec_args_cmd "rm -rf /usr/lib/python2.7/site-packages/drmanager/db/sqlalchemy/drmanager_api.pyc"
  exec_args_cmd "ls /usr/lib/python2.7/site-packages/drmanager/db/sqlalchemy/drmanager_api.pyc"
}

function main() {
  #scp_args_files $*
  delete_pyc_file 
}

main $*
