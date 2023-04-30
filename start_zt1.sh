#!/bin/bash

# Always do this to make sure the directory permissions are correct.
chown -R zerotier-one:zerotier-one /var/lib/zerotier-one
# remove secrets
unset ZTNCUI_PASSWD
# ZT1 must run as root.
/usr/sbin/zerotier-one
