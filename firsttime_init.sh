#!/bin/bash

# detect if identity folder exists
if [[ ! -d /var/lib/zerotier-one ]]; then
    mkdir -p /var/lib/zerotier-one
fi

# detect if identity public key exists
if [[ -f /var/lib/zerotier-one/identity.secret ]]; then
    cd /var/lib/zerotier-one
    usermod -aG zerotier-one root
    /usr/sbin/zerotier-idtool generate identity.secret identity.public
fi

# always make httpfs folder
mkdir -p /opt/key-networks/ztncui/etc/httpfs

# make sure we've got it chowned
chown -R zerotier-one:zerotier-one /opt/key-networks/ztncui
chown -R zerotier-one:zerotier-one /var/lib/zerotier-one 

# detect if 