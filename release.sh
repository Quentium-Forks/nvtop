#!/bin/bash
VERSION=3.2.0.1
DIR=nvtop-$VERSION
ARCH=$(uname -m)
ARCH_DPKG=$(dpkg --print-architecture)
export VERSION=$VERSION

# cleanup
rm -rf release build rpm/BUILDROOT rpm/*RPMS rpm/SOURCES

# build
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DNVIDIA_SUPPORT=ON -DAMDGPU_SUPPORT=ON
cmake --build build -j $(nproc)
strip -s build/src/nvtop

# assets
mkdir -p release/$DIR/nvtop
cp -r src include cmake CMakeLists.txt debian desktop manpage tests release/$DIR
cp desktop/nvtop.svg release/$DIR/nvtop
cat desktop/nvtop.desktop > release/$DIR/nvtop/default.desktop

if [ "$1" == "nightly" ]; then
    # Number of commits since last tag
    LAST_TAG=$(git describe --tags --abbrev=0 || echo "HEAD")
    COMMITS=$(git rev-list --count $LAST_TAG..HEAD)
    echo "Build number: $COMMITS"

    # Increase version number
    sed -i "s/$VERSION-/$VERSION+$COMMITS-/g" release/$DIR/debian/changelog

    # Change package name
    sed -i "s/^nvtop/nvtop-nightly/g" release/$DIR/debian/changelog
    sed -i "s/ nvtop$/ nvtop-nightly/g" release/$DIR/debian/control

    # Prevent conflict with nvtop
    sed -i "s/Recommends: systemd/Provides: nvtop\nRecommends: systemd/g" release/$DIR/debian/control
    sed -i "s/Recommends: systemd/Conflicts: nvtop\nRecommends: systemd/g" release/$DIR/debian/control
    sed -i "s/Recommends: systemd/Replaces: nvtop\nRecommends: systemd/g" release/$DIR/debian/control

    VERSION="$VERSION+$COMMITS"
    export VERSION=$VERSION
    mv release/$DIR release/nvtop-nightly-$VERSION
    DIR=nvtop-nightly-$VERSION
fi

# Change architecture
sed -i "s/^Architecture:\s\+.*$/Architecture: $ARCH_DPKG/g" release/$DIR/debian/control

# tarball
cp -r src CMakeLists.txt release/$DIR
tar -czf release/$DIR.tar.gz -C release $DIR

# Restablish for debian package
rm -rf release/$DIR/src release/$DIR/CMakeLists.txt
cp -r build/src/* release/$DIR/nvtop

# linuxdeploy
wget -qc https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-$ARCH.AppImage
chmod +x linuxdeploy-$ARCH.AppImage

# appimage
cmake -S . -B build -DNVIDIA_SUPPORT=ON -DAMDGPU_SUPPORT=ON -DCMAKE_INSTALL_PREFIX=/usr
DESTDIR=../release/$DIR cmake --build build --target install
./linuxdeploy-$ARCH.AppImage --appdir release/$DIR -i release/$DIR/nvtop/nvtop.svg -d release/$DIR/desktop/nvtop.desktop --output appimage
if [ "$1" == "nightly" ]; then
    mv nvtop-$VERSION-$ARCH.AppImage release/nvtop-nightly-$VERSION-$ARCH.AppImage
else
    mv nvtop-$VERSION-$ARCH.AppImage release
fi

rm linuxdeploy-$ARCH.AppImage

# debian package
cd release/$DIR
dh_make --createorig --indep --yes
debuild --no-lintian -us -uc
cd ../..

# rpm package
mkdir -p rpm/SOURCES/
cp release/$DIR.tar.gz rpm/SOURCES/
if [ "$1" == "nightly" ]; then
    # Create a new spec file for nightly builds
    cp rpm/SPECS/nvtop.spec rpm/SPECS/nvtop-nightly.spec
    # Change package name
    sed -i "s/^Name:\s\+nvtop$/Name: nvtop-nightly/g" rpm/SPECS/nvtop-nightly.spec
    # Increase version number
    sed -i "s/^Version:\s\+.*$/Version: $VERSION/g" rpm/SPECS/nvtop-nightly.spec
    # Change architecture
    sed -i "s/^BuildArch:\s\+.*$/BuildArch: $ARCH/g" rpm/SPECS/nvtop-nightly.spec

    rpmbuild -bb --build-in-place --define "_topdir $(pwd)/rpm" rpm/SPECS/nvtop-nightly.spec
    mv rpm/RPMS/$ARCH/nvtop-nightly-$VERSION-1.$ARCH.rpm release/nvtop-nightly-$VERSION.$ARCH.rpm
else
    # Change architecture
    sed -i "s/^BuildArch:\s\+.*$/BuildArch: $ARCH/g" rpm/SPECS/nvtop.spec

    rpmbuild -bb --build-in-place --define "_topdir $(pwd)/rpm" rpm/SPECS/nvtop.spec
    mv rpm/RPMS/$ARCH/nvtop-$VERSION-1.$ARCH.rpm release/nvtop-$VERSION.$ARCH.rpm
fi
