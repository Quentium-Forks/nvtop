Name:           nvtop
Version:        3.2.0.1
Release:        1%{?dist}
Summary:        GPU & Accelerator process monitoring for AMD, Apple, Huawei, Intel, NVIDIA and Qualcomm

License:        GPLv3
URL:            https://github.com/Quentium-Forks/nvtop
Source0:        %{name}-%{version}.tar.gz

BuildArch:      x86_64
Requires:       ncurses glibc systemd

%description
NVTOP stands for Neat Videocard TOP, a (h)top like task monitor for GPUs and accelerators. It can handle multiple GPUs and print information about them in a htop-familiar way.

%prep
%setup -q

%build
echo "No build step defined"

%install
rm -rf %{buildroot}

# Install binary
install -Dm755 %{_builddir}/release/%{name}-%{version}/nvtop/nvtop %{buildroot}/usr/bin/nvtop

# Install .desktop file
install -Dm644 %{_builddir}/release/%{name}-%{version}/desktop/nvtop.desktop %{buildroot}/usr/share/applications/nvtop.desktop

# Install svg icon
install -Dm644 %{_builddir}/release/%{name}-%{version}/desktop/nvtop.svg %{buildroot}/usr/share/icons/hicolor/scalable/apps/nvtop.png

# Install README doc
install -Dm644 %{_builddir}/README.markdown %{buildroot}/usr/share/doc/nvtop/README.md

%files
%license
%doc
/usr/bin/nvtop
/usr/share/applications/nvtop.desktop
/usr/share/icons/hicolor/scalable/apps/nvtop.png
/usr/share/doc/nvtop/README.md

%changelog
