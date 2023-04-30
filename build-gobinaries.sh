#!/bin/bash
set -xe
cd /buildsrc
mkdir -p binaries 
cd argon2g 
go mod download 
go build -ldflags='-s -w' -trimpath -o ../binaries/argon2g 
cd .. 
git clone https://github.com/jsha/minica 
cd minica 
go mod download 
go build -ldflags='-s -w' -trimpath -o ../binaries/minica 
cd .. 
git clone https://github.com/tianon/gosu 
cd gosu 
go mod download 
go build -o ../binaries/gosu -ldflags='-s -w' -trimpath 
cd .. 
cd fileserv 
go build -ldflags='-s -w' -trimpath -o ../binaries/fileserv main.go 
cd .. 
cd ztnode-genid 
go build -ldflags='-s -w' -trimpath -o ../binaries/ztnode-genid main.go 
cd .. 
cd ztnode-mkworld 
go build -ldflags='-s -w' -trimpath -o ../binaries/ztnode-mkworld main.go