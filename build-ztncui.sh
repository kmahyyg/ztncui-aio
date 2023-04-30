#!/bin/bash
set -xe
git clone https://github.com/key-networks/ztncui
npm install -g node-gyp pkg
cd ztncui/src 
npm install
pkg -c ./package.json -t "node${NODEJS_MAJOR}-linux-x64" bin/www -o ztncui 
zip -r /build/artifact.zip ztncui node_modules/argon2/build/Release
