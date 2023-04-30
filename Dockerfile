FROM debian:bullseye-slim AS jsbuilder
ENV NODEJS_MAJOR=18
ENV DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.source="https://github.com/kmahyyg/ztncui-aio"
LABEL MAINTAINER="Key Networks https://key-networks.com"
LABEL Description="ztncui (a ZeroTier network controller user interface) + ZeroTier network controller"
ADD VERSION .
ADD AIO_VERSION .

# BUILD ZTNCUI IN FIRST STAGE
WORKDIR /build
RUN apt update -y && \
    apt install curl gnupg2 ca-certificates zip unzip build-essential git --no-install-recommends -y && \
    curl -sL -o node_inst.sh https://deb.nodesource.com/setup_${NODEJS_MAJOR}.x && \
    bash node_inst.sh && \
    apt install -y nodejs --no-install-recommends && \
    rm -f node_inst.sh
COPY build-ztncui.sh /build/
RUN bash /build/build-ztncui.sh

# BUILD GO UTILS
FROM golang:bullseye AS gobuilder
WORKDIR /buildsrc
COPY argon2g /buildsrc/argon2g
COPY fileserv /buildsrc/fileserv
COPY ztnodeid /buildsrc/ztnodeid
COPY build-gobinaries.sh /buildsrc/build-gobinaries.sh
ENV CGO_ENABLED=0
RUN apt update -y && \ 
    apt install zip -y && \
    bash /buildsrc/build-gobinaries.sh

# START RUNNER
FROM debian:bullseye-slim AS runner
ENV DEBIAN_FRONTEND=noninteractive
ENV AUTOGEN_PLANET=0
WORKDIR /tmp
RUN apt update -y && \
    apt install curl gnupg2 ca-certificates gzip xz-utils iproute2 unzip net-tools procps --no-install-recommends -y && \
    curl -L -O https://github.com/just-containers/s6-overlay/releases/download/v3.1.3.0/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && rm /tmp/s6-overlay-noarch.tar.xz && \
    curl -L -O https://github.com/just-containers/s6-overlay/releases/download/v3.1.3.0/s6-overlay-x86_64.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz && rm /tmp/s6-overlay-x86_64.tar.xz && \
    groupadd -g 2222 zerotier-one && \
    useradd -u 2222 -g 2222 zerotier-one && \
    usermod -aG zerotier-one zerotier-one && \
    usermod -aG zerotier-one root && \
    curl -sL -o zt-one.sh https://install.zerotier.com && \
    bash zt-one.sh && \
    rm -f zt-one.sh && \
    apt clean -y && \
    rm -rf /var/lib/zerotier-one && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/key-networks/ztncui
COPY --from=jsbuilder /build/artifact.zip .
RUN unzip ./artifact.zip && \
    rm -f ./artifact.zip

WORKDIR /
COPY start_firsttime_init.sh /start_firsttime_init.sh
COPY start_zt1.sh /start_zt1.sh
COPY start_ztncui.sh /start_ztncui.sh

COPY --from=gobuilder /buildsrc/artifact-go.zip /tmp/
RUN unzip -d /usr/local/bin /tmp/artifact-go.zip && \
    rm -rf /tmp/artifact-go.zip && \
    chmod 0755 /usr/local/bin/* && \
    chmod 0755 /start_*.sh

COPY s6-rc.d /etc/s6-overlay/

EXPOSE 3000/tcp
EXPOSE 3180/tcp
EXPOSE 8000/tcp
EXPOSE 3443/tcp

VOLUME ["/opt/key-networks/ztncui/etc", "/etc/zt-mkworld", "/var/lib/zerotier-one"]
ENTRYPOINT [ "/init" ]
