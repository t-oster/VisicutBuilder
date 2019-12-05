#!/bin/bash
set -e
echo "$(date) Build started."
TIME=$(date +%s)
BASEDIR="/app"
mkdir -p $BASEDIR/build $BASEDIR/output
REPODIR="$BASEDIR/build/VisiCut"
VISICUT_REPO=${VISICUT_REPO:-https://github.com/t-oster/VisiCut.git}
VISICUT_BRANCH=${VISICUT_BRANCH:-master}
VISICUT_UPDATE=${VISICUT_UPDATE:-true}
if [ ! -d "$REPODIR" ]
then
    git clone --recursive "$VISICUT_REPO" "$REPODIR"
fi
cd $REPODIR
if [ "$VISICUT_UPDATE" == "true" ]
then
    git checkout -f $VISICUT_BRANCH
    git reset --hard
    git pull
    # Build the latest GIT-Revision
    # git submodule init
    git submodule update || exit 1
    git fetch --tags
else
    echo "Skipping update due to VISICUT_UPDATE environment variable"
fi
VERSION="$(git describe --tags)"
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "branch is $BRANCH"
OUTDIR="/app/output/branch-$BRANCH"

echo "Version is: $VERSION on branch $BRANCH"
if [ -f $OUTDIR/All/VisiCut-$VERSION.zip ]
then
	echo "This version was already build. Exiting."
	exit
fi

echo "inserting windows binaries"
mkdir -p $REPODIR/distribute/windows/stream/
cp -r $BASEDIR/windows-addons/* $REPODIR/distribute/windows/stream/
echo "inserting mac osx binaries"
mkdir -p $REPODIR/distribute/mac/VisiCut.app/Contents/Resources/Java
cp -r $BASEDIR/mac-addons/* $REPODIR/distribute/mac/VisiCut.app/Contents/Resources/Java/

echo "Inserting Version Number"
pushd $REPODIR/src/main/resources/de/thomas_oster/visicut/gui/resources/
for i in VisicutApp*.properties
do
	cp $i /tmp/$i
	cat /tmp/$i|sed "s#^Application.version =.*#Application.version = $VERSION#g#" > $i
	rm /tmp/$i
done
popd
echo "Compiling"
pushd $REPODIR
make clean || exit 1
make || exit 1
popd

echo "Distributing"
pushd $REPODIR/distribute
echo -en "y\ny\ny\ny\n" | ./distribute.sh --nocompile || exit 1
popd
mkdir -p $OUTDIR/ArchLinux
mkdir -p $OUTDIR/MacOSX
mkdir -p $OUTDIR/All
mkdir -p $OUTDIR/Windows
mkdir -p $OUTDIR/Debian-Ubuntu-Mint
echo "Moving results to VisiCutNightly..."
mv $REPODIR/distribute/*.pkg.tar.xz $OUTDIR/ArchLinux/ || exit 1
mv $REPODIR/distribute/*Mac*.zip $OUTDIR/MacOSX/ || exit 1
# delete windows zip
rm $REPODIR/distribute/*-Windows-Installer.zip
mv $REPODIR/distribute/*.zip $OUTDIR/All/ || exit 1
mv $REPODIR/distribute/*.exe $OUTDIR/Windows/ || exit 1
mv $REPODIR/distribute/*.deb $OUTDIR/Debian-Ubuntu-Mint/ || exit 1
echo "done."
(( k=$(date +%s) - TIME ))
echo "Build took $k seconds."
echo "$(date) build finished."
echo "removing old builds..."
for dir in ArchLinux MacOSX All Windows Debian-Ubuntu-Mint
do
	pushd $OUTDIR/$dir
	for f in $(ls -c|tail -n +5)
	do
		rm -f $f
	done
	popd
done
