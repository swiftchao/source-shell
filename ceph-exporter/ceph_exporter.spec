Name:		ceph_exporter
Version:	3.0.0
Release:	1%{?dist}
Summary:	ceph exporter for prometheus.

Group:	    Development/Tools
License:	GPL
URL:		https://github.com/digitalocean/ceph_exporter
Source0:	%{name}-%{version}.tar.gz

#BuildRequires:	librados-devel
#Requires:	librados-devel

%description
Prometheus exporter that scrapes meta information about a running ceph cluster.


%prep
rm -rf ${RPM_BUILD_ROOT}/*

%setup -q -n %{name}


%build
go get -d && go build -o ./bin/ceph_exporter


%install
install -d ${RPM_BUILD_ROOT}/usr/local/bin/
cp -af ./bin/ceph_exporter ${RPM_BUILD_ROOT}/usr/local/bin/

install -d ${RPM_BUILD_ROOT}/etc/ceph/
cp -af ./exporter.yml ${RPM_BUILD_ROOT}/etc/ceph/

install -d ${RPM_BUILD_ROOT}/usr/lib/systemd/system/
cp -af ./ceph_exporter.service ${RPM_BUILD_ROOT}/usr/lib/systemd/system/ceph_exporter.service


%files
%defattr(-,root,root,-) 
/usr/local/bin/ceph_exporter
/etc/ceph/exporter.yml
/usr/lib/systemd/system/ceph_exporter.service


%postun
rm -rf /usr/local/bin/ceph_exporter
rm -rf /etc/ceph/exporter.yml
rm -rf /usr/lib/systemd/system/ceph_exporter.service

#%clean
#rm -rf ${RPM_BUILD_ROOT} 

%doc
%changelog

