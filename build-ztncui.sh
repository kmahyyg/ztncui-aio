#!/bin/bash
set -xe
git clone https://github.com/key-networks/ztncui
npm install -g node-gyp pkg
cd ztncui/src 
npm install

MACHINE_ARCHITECTURE=$(uname -m)
export NODEJS_PACK_ARCH=""
case ${MACHINE_ARCHITECTURE} in 
    "arm")
        # armv6 is too old, and unsupported by pkg, and should be deprecated, so we won't support
        # armv7 is unsupported by pkg, you could try build yourself, but no guarantee here
        echo "Upstream unsupported architecture: ${MACHINE_ARCHITECTURE}. Treat as armv7. But will still try to build."
        NODEJS_PACK_ARCH="armv7"
        ;;
    "aarch64")
        NODEJS_PACK_ARCH="arm64"
        ;;
    "x86_64")
        NODEJS_PACK_ARCH="x64"
        ;;
    *)
        echo "Unsupported Architecture: ${MACHINE_ARCHITECTURE}. Exit now."
        exit 127
        ;;
esac

pkg -c ./package.json -C Brotli --no-bytecode --public -t "node${NODEJS_MAJOR}-linux-x64" bin/www -o ztncui
zip -r /build/artifact.zip ztncui node_modules/argon2/build/Release
