#!/bin/sh

set -e

BASE_DIR=$(pwd)

NDILIB_VERSION="4.5.1"
NDILIB_INSTALLER_SHA256="e0bc795d2281cfa60fcc881366ce19156164a2c7bb1b9f95a1e213f8c87c91dc"
NDILIB_INSTALLER="/tmp/libndi-install.sh"

cd /tmp
curl -kL -o $NDILIB_INSTALLER https://slepin.fr/obs-ndi/ci/libndi-linux-v$NDILIB_VERSION-install.sh -f --retry 5
echo "$NDILIB_INSTALLER_SHA256 $NDILIB_INSTALLER" | sha256sum -c
chmod +x $NDILIB_INSTALLER
yes | PAGER="cat" sh $NDILIB_INSTALLER

rm -rf /tmp/ndisdk
mv "/tmp/NDI SDK for Linux" /tmp/ndisdk
ls /tmp/ndisdk

cd /root/obs-ndi

export GIT_HASH=$(git rev-parse --short HEAD)
export PKG_VERSION="1-$GIT_HASH-$TRAVIS_BRANCH-git"

if [ -n "${TRAVIS_TAG}" ]; then
	export PKG_VERSION="$TRAVIS_TAG"
fi

cd /root/obs-ndi/build

PAGER="cat" checkinstall -y --type=debian --fstrans=no --nodoc \
	--backup=no --deldoc=yes --install=no \
	--pkgname=obs-ndi --pkgversion="$PKG_VERSION" \
	--pkglicense="GPLv2" --maintainer="stephane.lepin@gmail.com" \
	--requires="libndi4>=$NDILIB_VERSION" --pkggroup="video" \
	--pkgsource="https://github.com/Palakis/obs-ndi" \
	--pakdir="/package"

PAGER="cat" checkinstall -y --type=debian --fstrans=no --nodoc \
        --backup=no --deldoc=yes --install=no \
        --pkgname=libndi4 --pkgversion="$NDILIB_VERSION" \
        --pkglicense="Proprietary" --maintainer="stephane.lepin@gmail.com" \
       	--pkggroup="video" \
        --pkgsource="http://ndi.newtek.com" \
        --pakdir="/package" ../CI/create-libndi-deb.sh

PAGER="cat" checkinstall -y --type=debian --fstrans=no --nodoc \
        --backup=no --deldoc=yes --install=no \
        --pkgname=libndi4-dev --pkgversion="$NDILIB_VERSION" --requires="libndi4>=$NDILIB_VERSION" \
        --pkglicense="Proprietary" --maintainer="stephane.lepin@gmail.com" \
        --pkggroup="video" \
        --pkgsource="http://ndi.newtek.com" \
        --pakdir="/package" ../CI/create-libndi-dev-deb.sh

chmod ao+r /package/*
