#!/bin/bash
VERSION=3.2.0.1
DIR=nvtop-$VERSION
ARCH=$(uname -m)
ARCH_DPKG=$(dpkg --print-architecture)
export VERSION=$VERSION

# cleanup
rm -rf release build rpm/BUILDROOT rpm/*RPMS rpm/SOURCES

# Prepare source for tarball
mkdir -p release/$DIR
cp -r src include cmake CMakeLists.txt desktop debian release/$DIR
cp desktop/nvtop.svg release/$DIR/desktop/
cat desktop/nvtop.desktop > release/$DIR/desktop/default.desktop

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
tar -czf release/$DIR.tar.gz -C release $DIR
