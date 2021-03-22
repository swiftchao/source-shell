#########################################################################
# File Name: build-disk-exporter-deb.sh 
# Author: chaofei
# mail: chaofeibest@163.com
# Created Time: 2021-3-18 13:42:51
#########################################################################
#!/bin/bash

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

init_disk_exporte_deb_build() {
  init_args_deb_build "$DISK_EXPORTER_TAR_NAME" "$DISK_EXPORTER_NAME-$DISK_EXPORTER_VERSION"
  DISK_EXPORTER_DEB_ROOT="$HOME/debbuild/$DISK_EXPORTER_NAME-$DISK_EXPORTER_VERSION"
  create_dir "$DISK_EXPORTER_DEB_ROOT/usr/bin"
  create_dir "$DISK_EXPORTER_DEB_ROOT/lib/systemd/system"
  create_dir "$DISK_EXPORTER_DEB_ROOT/etc/init.d"
  #create_dir "$DISK_EXPORTER_DEB_ROOT/usr/lib/systemd/system"
  safe_remove "$DISK_EXPORTER_DEB_ROOT/usr/local/src/$DISK_EXPORTER_NAME"
  create_dir "$DISK_EXPORTER_DEB_ROOT/usr/local/src/$DISK_EXPORTER_NAME"
  cp -rf "$SOFT_ROOT/python_exporter"/* "$DISK_EXPORTER_DEB_ROOT/usr/local/src/$DISK_EXPORTER_NAME/"
  #create_dir "$DISK_EXPORTER_DEB_ROOT/usr/lib/python2.7/site-packages/$DISK_EXPORTER_NAME"
  #cp -rf "$SOFT_ROOT/python_exporter/$DISK_EXPORTER_NAME"/* "$DISK_EXPORTER_DEB_ROOT/usr/lib/python2.7/site-packages/$DISK_EXPORTER_NAME/"
  create_dir "$DISK_EXPORTER_DEB_ROOT/usr/lib/python2.7/$DISK_EXPORTER_NAME"
  cp -rf "$SOFT_ROOT/python_exporter/$DISK_EXPORTER_NAME"/* "$DISK_EXPORTER_DEB_ROOT/usr/lib/python2.7/$DISK_EXPORTER_NAME/"
}

write_disk_exporter_debian_files() {
  # version info
  #DISK_EXPORTER_DEB_ROOT="$HOME/debbuild/$DISK_EXPORTER_NAME"  
  DISK_EXPORTER_DEB_ROOT="$HOME/debbuild/$DISK_EXPORTER_NAME-$DISK_EXPORTER_VERSION"
  cd "$DISK_EXPORTER_DEB_ROOT"
  tee $DISK_EXPORTER_DEB_ROOT/DEBIAN/control << EOF
Package: disk-exporter
Version: 1.0.0
Architecture: all
Maintainer: Fei Chao
Installed-Size: 180K
Recommends:
Suggests:
Section: devel
Priority: optional
Multi-Arch: foreign
Description: disk exporter for prometheus. 
EOF

  # postinst after unzip tar
cd $DISK_EXPORTER_DEB_ROOT/usr/local/src/$DISK_EXPORTER_NAME
  tee $DISK_EXPORTER_DEB_ROOT/DEBIAN/postinst  << EOF
echo "install disk_export" >/tmp/disk_export
cp /usr/local/src/$DISK_EXPORTER_NAME/disk-exporter-service /usr/bin/disk-exporter-service
cp /usr/local/src/$DISK_EXPORTER_NAME/$DISK_EXPORTER_NAME/disk_exporter.service  /lib/systemd/system/disk_exporter.service
cp /usr/local/src/$DISK_EXPORTER_NAME/disk_exporter.sh  /etc/init.d/disk_exporter
chmod a+x /etc/init.d/disk_exporter
cp -rf /usr/local/src/$DISK_EXPORTER_NAME/$DISK_EXPORTER_NAME /usr/lib/python2.7/
EOF
  
  # postrm after remove exec
  tee $DISK_EXPORTER_DEB_ROOT/DEBIAN/postrm << EOF
rm -rf /usr/bin/disk-exporter-service
rm -rf /etc/init.d/disk_exporter
rm -rf /usr/lib/systemd/system/disk_exporter.service
rm -rf /usr/lib/python2.7/disk_exporter
EOF
}

gen_disk_exporter_deb() {
  gen_args_deb "$DISK_EXPORTER_NAME-$DISK_EXPORTER_VERSION"
}

build_ecph_exporter() {
  #DISK_EXPORTER_DEB_ROOT="$HOME/debbuild/$DISK_EXPORTER_NAME"
  DISK_EXPORTER_DEB_ROOT="$HOME/debbuild/$DISK_EXPORTER_NAME-$DISK_EXPORTER_VERSION"
  cd $DISK_EXPORTER_DEB_ROOT/usr/local/src/$DISK_EXPORTER_NAME
  git init
  python setup.py build
  cp "$DISK_EXPORTER_DEB_ROOT/usr/local/src/$DISK_EXPORTER_NAME/disk-exporter-service" "$DISK_EXPORTER_DEB_ROOT/usr/bin/disk-exporter-service"
  chmod 775 "$DISK_EXPORTER_DEB_ROOT/usr/bin/disk-exporter-service"
  cp "$DISK_EXPORTER_DEB_ROOT/usr/local/src/$DISK_EXPORTER_NAME/$DISK_EXPORTER_NAME/disk_exporter.service" "$DISK_EXPORTER_DEB_ROOT/lib/systemd/system/disk_exporter.service"
  cp "$DISK_EXPORTER_DEB_ROOT/usr/local/src/$DISK_EXPORTER_NAME/disk_exporter.sh" "$DISK_EXPORTER_DEB_ROOT/etc/init.d/disk_exporter"
}

build_disk_exporter_deb(){
  init_disk_exporte_deb_build
  write_disk_exporter_debian_files 
  build_ecph_exporter
  gen_disk_exporter_deb
}


main() {
  convert_relative_path_to_absolute_path
  build_disk_exporter_deb  
}

main
