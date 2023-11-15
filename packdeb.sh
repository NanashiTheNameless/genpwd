#!/bin/bash
GENPWD_VERSION=$(date +%s)
rm -rf ./tmp
rm -rf genpwd
rm -f genpwd.deb
mkdir -p genpwd/usr/local/bin
cp ./genpwd.sh genpwd/usr/local/bin/genpwd
cp ./genpwd.sh genpwd/usr/local/bin/genpwd.sh
mkdir genpwd/DEBIAN
touch genpwd/DEBIAN/control
echo "Package: genpwd
Version: $GENPWD_VERSION
Depends: bash, wget
Recommends: zsh, tilix
Section: genpwd
Maintainer: Discord/NamelessNanashi
Priority: optional
Architecture: amd64
Provides: genpwd
Description: simple installer for my genpwd tool" > genpwd/DEBIAN/control
dpkg-deb --build --root-owner-group genpwd
rm -rf genpwd
dpkg -x genpwd.deb ./tmp
cd tmp ; tar -czvf genpwd.orig.tar.gz * ; mv genpwd.orig.tar.gz ../genpwd.orig.tar.gz ; cd ..
rm -rf ./tmp
gh release create $GENPWD_VERSION --latest --generate-notes
gh release upload $GENPWD_VERSION genpwd.sh
gh release upload $GENPWD_VERSION genpwd.deb
gh release upload $GENPWD_VERSION genpwd.orig.tar.gz
rm -f genpwd.deb
rm -f genpwd.orig.tar.gz
