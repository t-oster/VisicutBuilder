FROM debian:bullseye
# Note: Debian bullseye is from ca. 2021. Ubuntu 22 is unusable due to bugs. Ubuntu 18 is too old for the "Noto Sans light" font.
MAINTAINER Thomas Oster <mail@thomas-oster.de>
RUN apt-get update && \
# VisiCut build dependencies:
	apt-get -y install --no-install-recommends wget checkinstall nsis openjdk-11-jdk maven zip unzip librsvg2-bin git potrace fakeroot fonts-noto-extra sudo

# workaround nsis bug: https://sourceforge.net/p/nsis/bugs/1180/
ENV LANG C.UTF-8

RUN adduser docker --system --uid 12345
ADD build.sh /app/
ADD docker_cmd.sh /app/
ADD mac-addons /app/mac-addons
ADD windows-addons /app/windows-addons
RUN mkdir -p /app/output /app/build && \
	chown docker /app/output /app/build
VOLUME ["/app/output", "/app/build"]
WORKDIR /app
CMD ./docker_cmd.sh

