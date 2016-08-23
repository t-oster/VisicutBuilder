FROM hoverbear/archlinux
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm --needed jdk7-openjdk git apache-ant zip make base-devel inkscape sudo potrace
COPY checkinstall-1.6.2-3-x86_64.pkg.tar.xz \
     nsis-2.46-4-x86_64.pkg.tar.xz \
     mingw32-runtime-3.20-4-any.pkg.tar.xz \
     dpkg-1.16.10-2-x86_64.pkg.tar.xz \ 
    /tmp/
RUN pacman -U --noconfirm /tmp/*.pkg.tar.xz
RUN useradd docker && echo "docker ALL=NOPASSWD(ALL) ALL" >> /etc/sudoers
RUN mkdir /app \
    && mkdir /app/output \
    && mkdir /app/build \
    && chown docker /app -R
USER docker
ADD build.sh mac-addons windows-addons /app/
VOLUME ["/app/output"]
VOLUME ["/app/build"]
WORKDIR /app

CMD ./build.sh

