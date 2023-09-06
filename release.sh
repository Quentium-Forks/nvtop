#!/bin/bash
VERSION=3.1.0
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

# linuxdeploy
wget -qc https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage

cmake -S . -B build -DNVIDIA_SUPPORT=ON -DAMDGPU_SUPPORT=ON -DCMAKE_INSTALL_PREFIX=/usr
DESTDIR=../release/$DIR cmake --build build --target install
./linuxdeploy-x86_64.AppImage --appdir release/$DIR -i release/$DIR/nvtop/nvtop.svg -d release/$DIR/desktop/nvtop.desktop --output appimage
mv nvtop-*.AppImage release

rm linuxdeploy-x86_64.AppImage

if [ "$1" == "deb" ]; then
    cd release/$DIR
    dh_make --createorig --indep --yes
    debuild --no-lintian -us -uc
fi
