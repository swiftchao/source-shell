######################################################################### 
# File Name: build-ceph_exporter-deb.sh
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

create_dir() {
  if [ ! -d "${1}" ]; then
    mkdir -p "${1}"
  fi
}

create_file() {
  if [ ! -f "${1}" ]; then
    touch "${1}"
  fi
}

safe_remove() {
  if [ -n "${1}" ]; then
    if [ -d "${1}" ] || [ -f "${1}" ] && [ "${1}" != "/" ]; then
      rm -rf "${1}"
    fi
  fi
}


init_args_deb_build() {
  ARGS_TAR_NAME="${1}"
  ARGS_NAME="${2}"
  if [ -n "${ARGS_TAR_NAME}" ] && [ -n "${ARGS_NAME}" ]; then
    cd $HOME
    ARGS_DEB_ROOT="$HOME/debbuild/$ARGS_NAME"
    create_dir "$ARGS_DEB_ROOT"
    create_dir "$ARGS_DEB_ROOT/DEBIAN"
    create_dir "$ARGS_DEB_ROOT/usr/local/src/$ARGS_NAME" 
    create_file "$ARGS_DEB_ROOT/DEBIAN/control"
    create_file "$ARGS_DEB_ROOT/DEBIAN/postinst"
    create_file "$ARGS_DEB_ROOT/DEBIAN/postrm"
    chmod 775 "$ARGS_DEB_ROOT/DEBIAN/postinst"
    chmod 775 "$ARGS_DEB_ROOT/DEBIAN/postrm"
  fi
}

gen_args_deb() {
  ARGS_NAME="${1}" 
  if [ -n "${ARGS_NAME}" ]; then
    ARGS_DEB_ROOT="$HOME/debbuild/$ARGS_NAME"
    cd "$ARGS_DEB_ROOT/.."
    dpkg -b "$ARGS_NAME" "$ARGS_NAME.deb"
  fi
}

init_ceph_exporte_deb_build() {
  init_args_deb_build "$CEPH_EXPORTER_TAR_NAME" "$CEPH_EXPORTER_NAME-$CEPH_EXPORTER_VERSION"
  #CEPH_EXPORTER_DEB_ROOT="$HOME/debbuild/$CEPH_EXPORTER_NAME"
  CEPH_EXPORTER_DEB_ROOT="$HOME/debbuild/$CEPH_EXPORTER_NAME-$CEPH_EXPORTER_VERSION"
  create_dir "$CEPH_EXPORTER_DEB_ROOT/usr/local/bin"
  create_dir "$CEPH_EXPORTER_DEB_ROOT/etc/ceph"
  create_dir "$CEPH_EXPORTER_DEB_ROOT/lib/systemd/system"
  create_dir "$CEPH_EXPORTER_DEB_ROOT/etc/init.d"
  #create_dir "$CEPH_EXPORTER_DEB_ROOT/usr/lib/systemd/system"
  safe_remove "$CEPH_EXPORTER_DEB_ROOT/usr/local/src/$CEPH_EXPORTER_NAME"
  create_dir "$CEPH_EXPORTER_DEB_ROOT/usr/local/src/$CEPH_EXPORTER_NAME"
  cp -rf "$SOFT_ROOT/$CEPH_EXPORTER_NAME"/* "$CEPH_EXPORTER_DEB_ROOT/usr/local/src/$CEPH_EXPORTER_NAME/"
}

write_ceph_exporter_debian_files() {
  # version info
  #CEPH_EXPORTER_DEB_ROOT="$HOME/debbuild/$CEPH_EXPORTER_NAME"  
  CEPH_EXPORTER_DEB_ROOT="$HOME/debbuild/$CEPH_EXPORTER_NAME-$CEPH_EXPORTER_VERSION"
  cd "$CEPH_EXPORTER_DEB_ROOT"
  tee $CEPH_EXPORTER_DEB_ROOT/DEBIAN/control << EOF
Package: ceph-exporter
Version: 3.0.0
Architecture: all
Maintainer: Fei Chao
Installed-Size: 9.9M
Recommends:
Suggests:
Section: devel
Priority: optional
Multi-Arch: foreign
Description: ceph exporter for prometheus. 
EOF

  # postinst after unzip tar
cd $CEPH_EXPORTER_DEB_ROOT/usr/local/src/$CEPH_EXPORTER_NAME
  tee $CEPH_EXPORTER_DEB_ROOT/DEBIAN/postinst  << EOF
echo "install ceph_export" >/tmp/ceph_export
cp /usr/local/src/$CEPH_EXPORTER_NAME/bin/ceph_exporter /usr/local/bin/ceph_exporter
cp /usr/local/src/$CEPH_EXPORTER_NAME/exporter.yml /etc/ceph/exporter.yml
cp /usr/local/src/$CEPH_EXPORTER_NAME/ceph_exporter.service  /lib/systemd/system/ceph_exporter.service
cp /usr/local/src/$CEPH_EXPORTER_NAME/ceph_exporter.sh /etc/init.d/ceph_exporter
chmod a+x /etc/init.d/ceph_exporter
chmod a+x /usr/local/bin/ceph_exporter
EOF
  
  # postrm after remove exec
  tee $CEPH_EXPORTER_DEB_ROOT/DEBIAN/postrm << EOF
rm -rf /usr/local/bin/ceph_exporter
rm -rf /etc/ceph/exporter.yml
rm -rf /usr/lib/systemd/system/ceph_exporter.service
rm -rf /etc/init.d/ceph_exporter
EOF
}

gen_ceph_exporter_deb() {
  #gen_args_deb "${CEPH_EXPORTER_NAME}"
  gen_args_deb "$CEPH_EXPORTER_NAME-$CEPH_EXPORTER_VERSION"
}

build_ecph_exporter() {
  CEPH_EXPORTER_DEB_ROOT="$HOME/debbuild/$CEPH_EXPORTER_NAME-$CEPH_EXPORTER_VERSION"
  cd $CEPH_EXPORTER_DEB_ROOT/usr/local/src/$CEPH_EXPORTER_NAME
  go get -d && go build -o ./bin/ceph_exporter
  cp "./bin/ceph_exporter" "$CEPH_EXPORTER_DEB_ROOT/usr/local/bin/ceph_exporter"
  chmod a+x "$CEPH_EXPORTER_DEB_ROOT/usr/local/bin/ceph_exporter"
  cp "$CEPH_EXPORTER_DEB_ROOT/usr/local/src/$CEPH_EXPORTER_NAME/exporter.yml" "$CEPH_EXPORTER_DEB_ROOT/etc/ceph/exporter.yml"
  cp "$CEPH_EXPORTER_DEB_ROOT/usr/local/src/$CEPH_EXPORTER_NAME/ceph_exporter.service" "$CEPH_EXPORTER_DEB_ROOT/lib/systemd/system/ceph_exporter.service"
  cp "$CEPH_EXPORTER_DEB_ROOT/usr/local/src/$CEPH_EXPORTER_NAME/ceph_exporter.sh" "$CEPH_EXPORTER_DEB_ROOT/etc/init.d/ceph_exporter"
  chmod a+x "$CEPH_EXPORTER_DEB_ROOT/etc/init.d/ceph_exporter"
}

build_ceph_exporter_deb(){
  init_ceph_exporte_deb_build
  write_ceph_exporter_debian_files 
  build_ecph_exporter
  gen_ceph_exporter_deb
}


main() {
  convert_relative_path_to_absolute_path
  build_ceph_exporter_deb  
}

main
