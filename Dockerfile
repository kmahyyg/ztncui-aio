FROM debian:sid-slim AS builder
ENV NODEJS_MAJOR=14

# BUILD FIRST IN FIRST STAGE
WORKDIR /build
RUN apt update -y && \
    apt install curl gnupg2 ca-certificates zip unzip build-essential git --no-install-recommends -y && \
    curl -sL -o node_lts.sh https://deb.nodesource.com/setup_lts.x && \
    bash node_lts.sh && \
    apt install -y nodejs --no-install-recommends && \
    rm -f node_lts.sh && \
    git clone https://github.com/key-networks/ztncui && \
    npm install -g node-gyp pkg && \
    cd ztncui/src && \
    npm install && \
    pkg -c ./package.json -t "node${NODEJS_MAJOR}-linux-x64" bin/www -o ztncui && \
    zip -r /build/artifact.zip ztncui node_modules/argon2/build/Release


FROM golang:buster AS argong



# START RUNNER
FROM debian:sid-slim AS runner
RUN apt update -y && \
    apt install curl gnupg2 ca-certificates unzip supervisor --no-install-recommends -y && \
    curl -sL -o ztone.sh https://install.zerotier.com && \
    bash ztone.sh && \
    rm -f ztone.sh && \
    apt clean -y && \
    rm -rf /var/lib/zerotier-one

    
WORKDIR /opt/key-networks/ztncui
COPY --from=builder /build/artifact.zip .
RUN unzip ./artifact.zip && \
    rm -f ./artifact.zip

COPY gosu /bin/gosu
COPY minica /usr/local/bin/minica
COPY argon2gen /usr/local/bin/argon2gen

# INSTALL NODEJS AND ZT SECOND STAGE
# INSTALL MINICA AND GOSU
# REMOVE PREBUILT ZT IDENTITY
# COPY SUPERVISOR CONF
#RUN
# EXPOSE VOLUME

RUN apt update -y && \
    apt install curl gnupg2 ca-certificates build-essential supervisor --no-install-recommends -y && \
    curl -sL -o node_lts.sh https://deb.nodesource.com/setup_lts.x && \
    bash node_lts.sh && \
    apt install -y nodejs --no-install-recommends && \
    curl -sL -o ztone.sh https://install.zerotier.com && \
    bash ztone.sh && \
    curl -o ztncui.deb https://s3-us-west-1.amazonaws.com/key-networks/deb/ztncui/1/x86_64/ztncui_${ZTNCUI_VER}_amd64.deb && \
    dpkg -i ztncui.deb

COPY gosu /bin/gosu
COPY minica /usr/bin/minica

RUN rm -rf /var/lib/zerotier-one && \
    

