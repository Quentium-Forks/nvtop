#!/bin/bash
VERSION=3.2.0
DIR=nvtop-$VERSION
export VERSION=$VERSION

rm -rf release build
mkdir release build
cd build
cmake -DCMAKE_BUILD_TYPE=Debug -DNVIDIA_SUPPORT=ON -DAMDGPU_SUPPORT=ON -DCMAKE_CXX_COMPILER=g++ ..
make -j $(nproc)
cd ..

mkdir -p release/$DIR/nvtop
cp -r desktop debian release/$DIR
cp -r build/src/* release/$DIR/nvtop
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

    VERSION="$VERSION+$COMMITS"
    export VERSION=$VERSION
    mv release/$DIR release/nvtop-nightly-$VERSION
    DIR=nvtop-nightly-$VERSION
fi

# tarball
tar -czf release/$DIR.tar.gz -C release $DIR

# linuxdeploy AppImage
wget -qc https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage

cmake -S . -B build -DNVIDIA_SUPPORT=ON -DAMDGPU_SUPPORT=ON -DCMAKE_INSTALL_PREFIX=/usr
DESTDIR=../release/$DIR cmake --build build --target install
./linuxdeploy-x86_64.AppImage --appdir release/$DIR -i release/$DIR/nvtop/nvtop.svg -d release/$DIR/desktop/nvtop.desktop --output appimage
if [ "$1" == "nightly" ]; then
    mv nvtop-$VERSION-x86_64.AppImage release/nvtop-nightly-$VERSION-x86_64.AppImage
else
    mv nvtop-$VERSION-x86_64.AppImage release
fi

rm linuxdeploy-x86_64.AppImage

# debian package
cd release/$DIR
dh_make --createorig --indep --yes
debuild --no-lintian -us -uc
