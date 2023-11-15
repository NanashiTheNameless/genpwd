#!/bin/bash
GENPWD_VERSION=$(date +%s)
rm -rf ./tmp
rm -rf Genpwd_$GENPWD_VERSION
rm -f Genpwd_$GENPWD_VERSION.deb
mkdir -p Genpwd_$GENPWD_VERSION/usr/local/bin
cp ./genpwd.sh Genpwd_$GENPWD_VERSION/usr/local/bin/genpwd
cp ./genpwd.sh Genpwd_$GENPWD_VERSION/usr/local/bin/genpwd.sh
mkdir Genpwd_$GENPWD_VERSION/DEBIAN
touch Genpwd_$GENPWD_VERSION/DEBIAN/control
echo "Package: genpwd
Version: $GENPWD_VERSION
Depends: bash, wget
Recommends: zsh, tilix
Section: genpwd
Maintainer: Discord/NamelessNanashi
Priority: optional
Architecture: amd64
Provides: genpwd
Description: simple installer for my genpwd tool" > Genpwd_$GENPWD_VERSION/DEBIAN/control
dpkg-deb --build --root-owner-group Genpwd_$GENPWD_VERSION
rm -rf Genpwd_$GENPWD_VERSION
dpkg -x Genpwd_$GENPWD_VERSION.deb ./tmp
cd tmp ; tar -czvf Genpwd_$GENPWD_VERSION.debian.tar.gz * ; mv Genpwd_$GENPWD_VERSION.debian.tar.gz ../Genpwd_$GENPWD_VERSION.debian.tar.gz ; cd ..
rm -rf ./tmp
gh release create $GENPWD_VERSION --latest --generate-notes
gh release upload $GENPWD_VERSION genpwd.sh
gh release upload $GENPWD_VERSION Genpwd_$GENPWD_VERSION.deb
gh release upload $GENPWD_VERSION Genpwd_$GENPWD_VERSION.debian.tar.gz
rm -f Genpwd_$GENPWD_VERSION.deb
rm -f Genpwd_$GENPWD_VERSION.tar.gz
