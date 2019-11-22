#!/usr/bin/env bash
# Configure your paths and filenames
SOURCEBINPATH=.
SOURCEBIN=migration
DEBFOLDER=./dist
DEBVERSION=0.4

rm dist_*
rm migration-*
rm -rf dist-*

if [[ ! -z $1 ]]; then
    DEBVERSION=$1
fi
echo "Deb version: $DEBVERSION $1"

DEBFOLDERNAME=$DEBFOLDER-$DEBVERSION

# Create your scripts source dir
if [[ -d ${DEBFOLDERNAME} ]]; then
    rm -rf $DEBFOLDERNAME
fi
mkdir $DEBFOLDERNAME

# Copy your script to the source dir
cd $DEBFOLDERNAME

# Create the packaging skeleton (debian/*)
dh_make --indep --createorig
cd -


mkdir $DEBFOLDERNAME/usr
mkdir $DEBFOLDERNAME/usr/local
mkdir $DEBFOLDERNAME/usr/local/bin

cp ${SOURCEBIN} ./${DEBFOLDERNAME}/usr/local/bin/

sed -i "s/PACKAGE_VERSION=[0-9].[0-9]/PACKAGE_VERSION=$DEBVERSION/g" lib/lifecycle.sh
cp -R lib/ ${DEBFOLDERNAME}/usr/local/bin/
cp package-templates/control ${DEBFOLDERNAME}/debian/control

sed -i "s/Version: xx/Version: $DEBVERSION/g" ${DEBFOLDERNAME}/debian/control

mv ${DEBFOLDERNAME}/debian ${DEBFOLDERNAME}/DEBIAN
rm -rf ${DEBFOLDERNAME}/DEBIAN/source
dpkg-deb -b $DEBFOLDERNAME/ ./migration-$DEBVERSION.deb

