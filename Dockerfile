FROM ubuntu:18.04
MAINTAINER Thomas Oster <mail@thomas-oster.de>
RUN apt-get update && \
# VisiCut build dependencies:
	apt-get -y install --no-install-recommends wget checkinstall nsis openjdk-8-jdk ant ant-optional zip librsvg2-bin git potrace fakeroot && \
# Build Arch's pacman on Ubuntu:
# (It is  one of the few things on earth for which there is no Debian/Ubuntu package.)
	apt-get -y install --no-install-recommends libarchive-dev bsdtar build-essential autogen autoconf autoconf-archive autopoint automake libtool gettext pkg-config
RUN git clone --quiet --branch v5.0.2 --depth 1 git://projects.archlinux.org/pacman.git /tmp/pacman && \
	cd /tmp/pacman && \
	./autogen.sh && \
# for some strange reason, we have to explicitly add libarchive here:
	./configure --disable-doc LDFLAGS="-larchive" && \
# to debug the make process: RUN VERBOSE=1 make
	make && \
	make install && \
	rm -r /tmp/pacman && \
# initialize pacman DB by querying something
	pacman -Q fooo 2>/dev/null || true && \
	echo PKGEXT=.pkg.tar.xz >> /usr/local/etc/makepkg.conf
# export library path
ENV LD_LIBRARY_PATH=/usr/local/lib


# to make `makepkg` happy, add a fake Arch Linux package that provides the dependencies we have installed
ADD fake-arch-packages /tmp/fake-arch-packages
RUN cd /tmp/fake-arch-packages && \
	chown nobody . && \
	su -s /bin/bash nobody  -c  makepkg && \
	pacman --noconfirm -U *.pkg.*

RUN adduser docker --system --uid 12345
ADD build.sh /app/
ADD mac-addons /app/mac-addons
ADD windows-addons /app/windows-addons
RUN mkdir -p /app/output /app/build && \
	chown docker /app/output /app/build
USER docker
VOLUME ["/app/output", "/app/build"]
WORKDIR /app
CMD ./build.sh

