#########################################################################
# File Name: build-disk-exporter-rpm.sh 
# Author: chaofei
# mail: chaofeibest@163.com
# Created Time: 2021-3-18 13:42:51
#########################################################################
#!/bin/bash

CEPH_EXPORTER_NAME="ceph_exporter"
CEPH_EXPORTER_VERSION="3.0.0"
CEPH_EXPORTER_TAR_NAME="$CEPH_EXPORTER_NAME-$CEPH_EXPORTER_VERSION.tar.gz"

DISK_EXPORTER_NAME="disk_exporter"
DISK_EXPORTER_VERSION="1.0.0"
DISK_EXPORTER_TAR_NAME="$DISK_EXPORTER_NAME-$DISK_EXPORTER_VERSION.tar.gz"

convert_relative_path_to_absolute_path() {
  this="${0}"
  bin=`dirname "${this}"`
  script=`basename "${this}"`
  SOFT_ROOT=`cd "${bin}"; pwd`
  this="${SOFT_ROOT}/${script}"
}

tar_args_file() {
  ARGS_GEN_TAR_DIR="${1}"
  if [ -n "${ARGS_GEN_TAR_DIR}" ] && [ -d "${ARGS_GEN_TAR_DIR}" ]; then
    cd "${ARGS_GEN_TAR_DIR}"
  fi
  ARGS_TAR_NAME="${2}"
  ARGS_FILE="${3}"
  if [ -n "${ARGS_TAR_NAME}" ] && [ -n "${ARGS_FILE}" ] && [ -e "${ARGS_FILE}" ]; then
    if [ -e "${ARGS_TAR_NAME}" ]; then
      rm -f "${ARGS_TAR_NAME}"
    fi
    tar -cjvf "$ARGS_TAR_NAME" "$ARGS_FILE"
  fi
}


init_args_rpm_build() {
  ARGS_TAR_NAME="${1}"
  ARGS_SPEC_FILE="${2}"
  if [ -n "${ARGS_TAR_NAME}" ] && [ -n "${ARGS_SPEC_FILE}" ] && [ -f "${ARGS_SPEC_FILE}" ]; then
    cd $HOME
    rpmdev-setuptree
    rm -f "$HOME/rpmbuild/SOURCES/$ARGS_TAR_NAME"
    cp -r "$SOFT_ROOT/$ARGS_TAR_NAME" "$HOME/rpmbuild/SOURCES/"
    cp -f "${ARGS_SPEC_FILE}" "$HOME/rpmbuild/SPECS/"
  fi
}

gen_args_rpm() {
  ARGS_NAME="${1}"
  ARGS_SPEC_FILE="$HOME/rpmbuild/SPECS/${ARGS_NAME}.spec"
  if [ -n "${ARGS_NAME}" ] && [ -f "${ARGS_SPEC_FILE}" ]; then
    rpmbuild -ba "${ARGS_SPEC_FILE}" 
  fi
}

replace_args_file_dos2unix() {
  ARGS_FILE="${1}"
  if [ -n "${ARGS_FILE}" ] && [ -f "${ARGS_FILE}" ]; then
    sed -i 's/\r//' "${ARGS_FILE}"
  fi
}

replace_ceph_exporter_dos2unix() {
  replace_args_file_dos2unix ""$SOFT_ROOT/$CEPH_EXPORTER_NAME/$CEPH_EXPORTER_NAME.spec""
  replace_args_file_dos2unix ""$SOFT_ROOT/$CEPH_EXPORTER_NAME/$CEPH_EXPORTER_NAME.service""
}

tar_ceph_exporter() {
  tar_args_file "$SOFT_ROOT" "$CEPH_EXPORTER_TAR_NAME" "$CEPH_EXPORTER_NAME"
}

init_ceph_exporter_rpm_build() {
  init_args_rpm_build "$CEPH_EXPORTER_TAR_NAME" "$SOFT_ROOT/$CEPH_EXPORTER_NAME/$CEPH_EXPORTER_NAME.spec"
}

gen_ceph_exporter_rpm() {
  gen_args_rpm "$CEPH_EXPORTER_NAME"
}

replace_disk_exporter_dos2unix() {
  replace_args_file_dos2unix ""$SOFT_ROOT/python_exporter/$DISK_EXPORTER_NAME.spec""
  replace_args_file_dos2unix ""$SOFT_ROOT/python_exporter/$DISK_EXPORTER_NAME.service""
}

tar_disk_exporter() {
  tar_args_file "$SOFT_ROOT" "$DISK_EXPORTER_TAR_NAME" "python_exporter"
}

init_disk_exporter_rpm_build() {
  init_args_rpm_build "$DISK_EXPORTER_TAR_NAME" "$SOFT_ROOT/python_exporter/$DISK_EXPORTER_NAME.spec"
}

gen_disk_exporter_rpm() {
  gen_args_rpm "$DISK_EXPORTER_NAME"
}

# build ceph_exporter rpm
build_ceph_exporter_rpm() {
  replace_ceph_exporter_dos2unix
  tar_ceph_exporter
  init_ceph_exporter_rpm_build
  gen_ceph_exporter_rpm 
}

# build disk_exporter rpm
build_disk_exporter_rpm() {
  replace_disk_exporter_dos2unix
  tar_disk_exporter
  init_disk_exporter_rpm_build
  gen_disk_exporter_rpm 
}

main() {
  convert_relative_path_to_absolute_path
  #build_ceph_exporter_rpm  
  build_disk_exporter_rpm  
}

main
