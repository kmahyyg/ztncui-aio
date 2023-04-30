#!/bin/bash

# create dest folder
mkdir -p /etc/zt-mkworld

# make sure we've got it chowned
chown -R zerotier-one:zerotier-one /opt/key-networks/ztncui
chown -R zerotier-one:zerotier-one /var/lib/zerotier-one 

# detect if identity folder exists
if [ ! -d /var/lib/zerotier-one ]; then
    mkdir -p /var/lib/zerotier-one
fi

# detect if identity private key exists
if [ ! -f /var/lib/zerotier-one/identity.secret ]; then
    cd /var/lib/zerotier-one
    /usr/sbin/zerotier-idtool generate identity.secret identity.public
fi

# always make httpfs folder
mkdir -p /opt/key-networks/ztncui/etc/httpfs

# detect public ip
if [ -z $MYADDR ]; then
    echo "Set Your IP Address to continue."
    echo "If you don't do that, I will automatically detect."
    MYEXTADDR=$(curl --connect-timeout 5 ip.sb)
    if [ -z $MYEXTADDR ]; then
        MYINTADDR=$(ifconfig eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
        MYADDR=${MYINTADDR}
    else
        MYADDR=${MYEXTADDR}
    fi
fi

MYDOMAIN=${MYDOMAIN:-ztncui.docker.test}   # Used for planet comment

echo "YOUR IP: ${MYADDR}"
echo "YOUR DOMAIN: ${MYDOMAIN}"

cd /etc/zt-mkworld
# detect if ALREADY_INITED
if [ -f /etc/zt-mkworld/ALREADY_INITED ]; then
    echo "ALREADY_INITED detected."
    exit 0
    # if not exist, goto planet file generate.
else
    # if set to 0, won't do anything.
    if [[ $AUTOGEN_PLANET -eq 0 ]]; then
        # finally create ALREADY_INITED flag file
        echo "AUTOGEN_PLANET is 0. Set to inited and exit."
        touch /etc/zt-mkworld/ALREADY_INITED
        exit 0
    fi
    # AUTOGEN_PLANET is not 0, backup now.
    if [[ -f /var/lib/zerotier-one/planet ]]; then
        cp /var/lib/zerotier-one/planet /var/lib/zerotier-one/planet.bak.$(date +%s)
    fi

    # if AUTOGEN_PLANET is set to 1, check if identity.public exists,
    # then generate mkworld.config.json on the fly
    if [[ $AUTOGEN_PLANET -eq 1 ]]; then
        # check if identity.public exists
        if [ -f /var/lib/zerotier-one/identity.public ]; then
            # generate json config file
            rm -f /etc/zt-mkworld/mkworld.config.json
            # now heredoc
            cat << EOF > /etc/zt-mkworld/mkworld.config.json
{
    "rootNodes": [
      {
        "comments": "custom planet - ${MYDOMAIN} - ${MYADDR}",
        "identity": "$(cat /var/lib/zerotier-one/identity.public)",
        "endpoints": [
          "${MYADDR}/9993"
        ]
      }
    ],
    "signing": ["previous.c25519", "current.c25519"],
    "output": "planet.custom",
    "plID": 0,
    "plBirth": 0,
    "plRecommend": true
}
EOF
            # run program under corresponding workdir, check exit code is 0.
            cd /etc/zt-mkworld
            /usr/local/bin/ztmkworld -c /etc/zt-mkworld/mkworld.config.json
            # copy custom planet to /var/lib/zerotier-one and httpfs
            if [[ $? -eq 0 ]]; then
                cp -f ./planet.custom /var/lib/zerotier-one/planet
                cp -f ./planet.custom /opt/key-networks/ztncui/etc/httpfs
                chown -R zerotier-one:zerotier-one /var/lib/zerotier-one
                echo "planet successfully generated."
            else
                echo "planet generator failed. exit now."
                /run/s6/basedir/bin/halt
                exit 1
            fi
            # finally create ALREADY_INITED flag file
            echo "mkworld successfully ran."
            touch /etc/zt-mkworld/ALREADY_INITED
            exit 0
        else
            echo "identity.public does NOT exit, cannot generate planet file."
            /run/s6/basedir/bin/halt
            exit 1
        fi
    fi

    # if set to 2, only use mkworld.config.json provided
    # check if mkworld.config.json exists
    if [[ $AUTOGEN_PLANET -eq 2 ]]; then
        cd /etc/zt-mkworld
        if [ ! -f /etc/zt-mkworld/mkworld.config.json ]; then
            echo "/etc/zt-mkworld/mkworld.config.json not exists. exit now."
            /run/s6/basedir/bin/halt
            exit 1
        fi
        /usr/local/bin/ztmkworld -c /etc/zt-mkworld/mkworld.config.json
        # check if successfully exit
        # copy custom planet to /var/lib/zerotier-one and httpfs
        if [[ $? -eq 0 ]]; then
            cp -f ./planet.custom /var/lib/zerotier-one/planet
            cp -f ./planet.custom /opt/key-networks/ztncui/etc/httpfs
            chown -R zerotier-one:zerotier-one /var/lib/zerotier-one
            echo "planet successfully generated."
        else
            echo "planet generator failed. exit now."
            /run/s6/basedir/bin/halt
            exit 1
        fi
        # finally create ALREADY_INITED flag file
        echo "mkworld successfully ran."
        touch /etc/zt-mkworld/ALREADY_INITED
        exit 0
    fi
    # after generate, copy to httpfs folder, do not directly expose the mkworld config folder.
    # the config folder contains secret keys!
fi
