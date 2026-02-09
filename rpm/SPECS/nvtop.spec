Name:           nvtop
Version:        3.3.2
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
cmake -S . -B build \
    -DCMAKE_INSTALL_PREFIX=%{_prefix} \
    -DCMAKE_BUILD_TYPE=Release \
    -DNVIDIA_SUPPORT=ON \
    -DAMDGPU_SUPPORT=ON

cmake --build build -j $(nproc)

%install
rm -rf %{buildroot}

DESTDIR=%{buildroot} cmake --install build

%files
%license LICENSE
%doc README.markdown
%{_bindir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/metainfo/io.github.syllo.%{name}.metainfo.xml
%{_datadir}/icons/hicolor/scalable/apps/%{name}.svg
%{_mandir}/man1/%{name}.1.*

%changelog
