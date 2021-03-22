# Allow building noarch packages that contain binaries
%define _binaries_in_noarch_packages_terminate_build 0

# Use md5 file digest method��The first macro is the one used in RPM v4.9.1.1
%define _binary_filedigest_algorithm 1

# This is the macro I find on OSX when Homebrew provides rpmbuild (rpm v5.4.14)
%define _build_binary_file_digest_algo 1

# Use gzip payload compression
%define _binary_payload w9.gzdio

# others
%undefine __find_provides
%undefine __find_requires

# Do not try autogenerate prereq/conflicts/obsoletes and check files
%undefine __check_files
%undefine __find_prereq
%undefine __find_conflicts
%undefine __find_obsoletes

# Be sure buildpolicy set to do nothing
%define __spec_install_post %{nil}

# Something that need for rpm-4.1
%define _missing_doc_files_terminate_build 0

%define dist .el7

# Major informations here
Name:		disk_exporter
Version:	1.0.0
Epoch:      0
Release:	1%{?dist}
Summary:	disk exporter for prometheus.
Group:	    Development/Tools
License:	GPL
URL:		https://github.com/digitalocean/disk_exporter
BuildArch:  noarch
Vendor:     FiberHome
Packager:   admin
# Copyright: admin@fiberhome.com
# AutoProv:   no
# AutoReq:    no

Source0:	%{name}-%{version}.tar.gz
Provides:   %{name} == %{epoch}:%{version}-%{release}

# BuildRequires:	python-pbr >= 3.1.1
BuildRequires:	git, python-pbr, python-setuptools

Requires:   prometheus_client, python-pbr

Prefix:     /

%description
Prometheus exporter that scrapes meta information about a running disk cluster.


%prep
rm -rf ${RPM_BUILD_ROOT}/*

#%setup -q -n %{name}
%setup -q -n python_exporter


%build
git init
python setup.py build


%install
install -d ${RPM_BUILD_ROOT}/usr/lib/python2.7/site-packages/disk_exporter
cp -af disk_exporter ${RPM_BUILD_ROOT}/usr/lib/python2.7/site-packages/

install -d ${RPM_BUILD_ROOT}/usr/lib/systemd/system
cp -af disk_exporter/disk-exporter.service ${RPM_BUILD_ROOT}/usr/lib/systemd/system/disk-exporter.service

install -d ${RPM_BUILD_ROOT}/etc/disk_exporter
cp -af disk_exporter/disk_exporter.conf ${RPM_BUILD_ROOT}/etc/disk_exporter/disk_exporter.conf

install -d ${RPM_BUILD_ROOT}/usr/bin
cp -af disk-exporter-service ${RPM_BUILD_ROOT}/usr/bin/ 
chmod 755 ${RPM_BUILD_ROOT}/usr/bin/disk-exporter-service

%pre
mkdir -p /etc/disk_exporter
mkdir -p /var/log/exporters

%post
%systemd_post disk-exporter.service
systemctl start disk-exporter.service >/dev/null 2>&1 || : 
systemctl enable disk-exporter.service >/dev/null 2>&1 || : 

%preun
%systemd_preun disk-exporter.service

%postun
%systemd_postun_with_restart disk-exporter.service
%systemd_postun disk-exporter.service
rm -rf /etc/disk_exporter
rm -f /var/log/exporters/disk-exporter.log

%files
%defattr(-,root,root,-)
%attr(644,root,root) /etc/disk_exporter/disk_exporter.conf
%attr(644,root,root) /usr/lib/systemd/system/disk-exporter.service
%attr(644,root,root) /usr/lib/python2.7/site-packages/disk_exporter*
%attr(755,root,root) /usr/lib/python2.7/site-packages/disk_exporter/tools/smartctl
%attr(755,root,root) /usr/bin/disk-exporter-service

#%clean
#rm -rf ${RPM_BUILD_ROOT} 

%doc
%changelog

