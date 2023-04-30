FROM debian:bullseye-slim AS jsbuilder
ENV NODEJS_MAJOR=18

ARG DEBIAN_FRONTEND=noninteractive
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
ENV CGO_ENABLED=0
RUN bash /buildsrc/build-gobinaries.sh


# START RUNNER
FROM debian:bullseye-slim AS runner
RUN apt update -y && \
    apt install curl gnupg2 ca-certificates unzip net-tools procps --no-install-recommends -y && \
    groupadd -g 2222 zerotier-one && \
    useradd -u 2222 -g 2222 zerotier-one && \
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
COPY --from=gobuilder /buildsrc/gobinaries.zip /tmp/
RUN unzip -d /usr/local/bin /tmp/gobinaries.zip && \
    chmod 0755 /usr/local/bin/* && \
    chmod 0755 /start_*.sh

COPY start_zt1.sh /start_zt1.sh
COPY start_ztncui.sh /start_ztncui.sh

EXPOSE 3000/tcp
EXPOSE 3180/tcp
EXPOSE 8000/tcp
EXPOSE 3443/tcp

VOLUME ["/opt/key-networks/ztncui/etc", "/etc/ztncui-docker", "/var/lib/zerotier-one"]
ENTRYPOINT [ "/usr/bin/supervisord" ]
