#!/bin/bash
#
# Derived from https://medium.com/travis-on-docker/how-to-version-your-docker-images-1d5c577ebf54
#
# This script has only been used by docker.io/key-networks/ztncui
# 
# In kmahyyg/ztncui-aio, the publishing process is done by github-action
#

set -ex

USERNAME=keynetworks
IMAGE=ztncui

# bump version
docker run --rm -v "$PWD":/app treeder/bump patch
version=`cat VERSION`
echo "version: $version"

# build
docker build -t $USERNAME/$IMAGE:latest .

# tag it
git add -A
git commit -m "version $version"
git tag -a "$version" -m "version $version"
docker tag $USERNAME/$IMAGE:latest $USERNAME/$IMAGE:$version

# push it
docker login --username=$USERNAME
docker push $USERNAME/$IMAGE:latest
docker push $USERNAME/$IMAGE:$version
