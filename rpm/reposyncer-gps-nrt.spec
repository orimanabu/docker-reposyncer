Name:		reposyncer-gps-nrt
Version:	1
Release:	1
Summary:	Yum repository for internal mirror by reposyncer
Group:		System Environment/Base 
License:	GPLv2
URL:		https://github.com/orimanabu/docker-reposyncer
Source0:	reposyncer-gps-nrt.repo

BuildArch:	noarch
Requires:	redhat-release

%description
This package contains yum configuration for internal mirror by
reposyncer.

%prep
%setup -q  -c -T

%build

%install
rm -rf $RPM_BUILD_ROOT


# yum
install -dm 755 $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d
install -pm 644 %{SOURCE0} $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%config(noreplace) %{_sysconfdir}/yum.repos.d/*

%changelog
* Wed Aug 5 2015 Manabu Ori <ori@redhat.com> - 1-1
- Initial RPM Spec.
