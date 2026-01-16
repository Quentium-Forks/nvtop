Name:           nvtop
Version:        3.3.0
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
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DNVIDIA_SUPPORT=ON -DAMDGPU_SUPPORT=ON
cmake --build build -j $(nproc)

%install
rm -rf %{buildroot}

# Install binary
install -Dm755 build/src/nvtop %{buildroot}/usr/bin/nvtop

# Install .desktop file
install -Dm644 desktop/nvtop.desktop %{buildroot}/usr/share/applications/nvtop.desktop

# Install svg icon
install -Dm644 desktop/nvtop.svg %{buildroot}/usr/share/icons/hicolor/scalable/apps/nvtop.svg

# Install README doc
install -Dm644 README.markdown %{buildroot}/usr/share/doc/nvtop/README.md

%files
%license
%doc
/usr/bin/nvtop
/usr/share/applications/nvtop.desktop
/usr/share/icons/hicolor/scalable/apps/nvtop.svg
/usr/share/doc/nvtop/README.md

%changelog
