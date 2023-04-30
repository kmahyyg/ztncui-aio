#!/bin/bash

# Always do this to make sure the directory permissions are correct.
usermod -aG zerotier-one root
chown -R zerotier-one:zerotier-one /var/lib/zerotier-one

# ZT1 must run as root.
/usr/sbin/zerotier-one
