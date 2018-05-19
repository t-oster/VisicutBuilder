FROM ubuntu:18.04
MAINTAINER Thomas Oster <mail@thomas-oster.de>
RUN apt-get update
# VisiCut build dependencies:
RUN apt-get -y install --no-install-recommends checkinstall nsis openjdk-8-jdk ant ant-optional zip librsvg2-bin git potrace fakeroot

# Build Arch's pacman on Ubuntu:
# (It is  one of the few things on earth for which there is no Debian/Ubuntu package.)
RUN apt-get -y install --no-install-recommends libarchive-dev bsdtar build-essential autogen autoconf autoconf-archive autopoint automake libtool gettext
RUN git clone --quiet --branch v5.0.2 --depth 1 git://projects.archlinux.org/pacman.git /tmp/pacman
WORKDIR /tmp/pacman
RUN apt-get -y install pkg-config
RUN ./autogen.sh
# for some strange reason, we have to explicitly add libarchive here:
RUN ./configure --disable-doc LDFLAGS="-larchive"
# to debug the make process: RUN VERBOSE=1 make
RUN make
RUN make install
# export library path
ENV LD_LIBRARY_PATH=/usr/local/lib
WORKDIR /
RUN rm -r /tmp/pacman
# initialize pacman DB by querying something
RUN pacman -Q fooo 2>/dev/null || true
RUN echo PKGEXT=.pkg.tar.xz >> /usr/local/etc/makepkg.conf

# to make `makepkg` happy, add a fake Arch Linux package that provides the dependencies we have installed
ADD fake-arch-packages /tmp/fake-arch-packages
WORKDIR /tmp/fake-arch-packages
RUN chown nobody .
USER nobody
RUN makepkg
USER root
RUN pacman --noconfirm -U *.pkg.*

RUN adduser docker --system --uid 12345
ADD build.sh /app/
ADD mac-addons /app/mac-addons
ADD windows-addons /app/windows-addons
RUN mkdir -p /app/output /app/build
RUN chown docker /app/output /app/build
USER docker
VOLUME ["/app/output", "/app/build"]
WORKDIR /app
CMD ./build.sh

