#!/bin/bash
EPOCH_TIME=$(date +%s)
rm -f genpwd-deb/usr/local/bin/genpwd.sh
rm -f genpwd-deb/usr/local/bin/genpwd
rm -f genpwd-deb/DEBIAN/control
rm -f genpwd.deb
cp genpwd.sh genpwd-deb/usr/local/bin/genpwd
cp genpwd.sh genpwd-deb/usr/local/bin/genpwd.sh
sed "s/VERSION/$EPOCH_TIME/g" control.bak > genpwd-deb/DEBIAN/control
dpkg-deb -b genpwd-deb genpwd.deb
rm -f genpwd-deb/usr/local/bin/genpwd.sh
rm -f genpwd-deb/usr/local/bin/genpwd
rm -f genpwd-deb/DEBIAN/control
gh release create $EPOCH_TIME --latest --generate-notes
gh release upload $EPOCH_TIME genpwd.sh
gh release upload $EPOCH_TIME genpwd.deb
rm -f genpwd.deb
