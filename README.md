# ztncui-aio

![](https://github.com/kmahyyg/ztncui-aio/actions/workflows/docker4commit.yml/badge.svg)

Current Version: 20230501-1.10.6-0.8.13

## From ztncui author

Say a huge thank you to their work!

### ZeroTier network controller user interface in a Docker container

This is to build a Docker image that contains **[ZeroTier One](https://www.zerotier.com/download.shtml)** and **[ztncui](https://key-networks.com/ztncui)** to set up a **standalone ZeroTier network controller** with a web user interface in a container.

Follow us on [![alt @key_networks on Twitter](https://i.imgur.com/wWzX9uB.png)](https://twitter.com/key_networks)

Licensed Under GNU GPLv3

## Build yourself

We support aarch64 (arm64/v8), amd64 by default. 

Armv7(means armhf) might work, but is not tested. 

Others are unsupported.

```bash
$ git clone https://github.com/kmahyyg/ztncui-aio
$ docker build . --build-arg OVERLAY_S6_ARCH=<one of aarch64,x86_64> -t ghcr.io/kmahyyg/ztncui-aio:latest
```

Change `NODEJS_MAJOR` variable in Dockerfile to use different nodejs version.

Never use `node_lts.x` as your installation script of nodejs whose version might changed without further notice due to time shift.

## Usage

### Golang auto-mkworld (already embedded in docker image)

This feature allows you to generate a planet file without using C code and compiler.

Also, due to limitation of IPC of Zerotier-One UI and multiple issues, we do NOT support customized port, you can ONLY use port 9993/udp here.

Set the following environment variable when create the container, and according to your needs:

| MANDATORY | Name | Explanation | Default Value |
|:--------:|:--------:|:--------:|:--------:|
| no | AUTOGEN_PLANET | If set to 1, will use this node identity to generate a `planet` file and put to `httpfs` folder to serve it outside. If set to 2, will use config in `/etc/zt-mkworld/mkworld.config.json`. If set to 0, will do nothing. | 0 |

The reference config file can be found on `ztnodeid/assets/mkworld.conf.json`. 

You could also define yourself, and check the stdout output to get C header of customized planet. After that, you will find the custom planet file under http file server root and also ca certificate.

The configuration JSON can be understand like this:

```json
{
    "rootNodes": [   // array of node, can be multiple
        {
            "comments": "amsterdam official",   // node object, comment, will auto generate if AUTOGEN_PLANET=1
            "identity": "992fcf1db7:0:206ed59350b31916f749a1f85dffb3a8787dcbf83b8c6e9448d4e3ea0e3369301be716c3609344a9d1533850fb4460c50af43322bcfc8e13d3301a1f1003ceb6",  
            // node identity.public ^^ , if node is not initialized, will initialize at the container start
            "endpoints": [
                "195.181.173.159/443",   // node service location, in format: ip/port, will auto generate if AUTOGEN_PLANET=1
                "2a02:6ea0:c024::/443"   // must be less than or equal to two endpoints, one for IPv4, one for IPv6. if you have multiple IP, set multiple node with different identity.
            ]
        }
    ],
    "signing": [
        "previous.c25519",   // planet signing key, if not exist, will generate
        "current.c25519"   // same, used for iteration and update
    ],
    "output": "planet.custom",   // output filename
    "plID": 0,    // planet numeric ID, if you don't know, do not modify, and set plRecommend to true
    "plBirth": 0,  // planet creation timestamp, if you don't know, do not modify, and set plRecommend to true
    "plRecommend": true  // set plRecommend to true, auto-recommend plID, plBirth value. For more details, read mkworld source code in zerotier-one official repo
}
```

### Docker image

```bash
$ git clone https://github.com/kmahyyg/ztncui-aio # to get a copy of denv file, otherwise make your own
$ docker pull ghcr.io/kmahyyg/ztncui-aio
$ docker run -d -p3443:3443 -p3180:3180 -p9993:9993/udp \
    -v /mydata/ztncui:/opt/key-networks/ztncui/etc \  
    -v /mydata/zt1:/var/lib/zerotier-one \
    -v /mydata/zt-mkworld-conf:/etc/zt-mkworld \
    --env-file ./denv <CHANGE THIS FILE ACCORDING TO NEXT PART> \
    --restart always \
    --cap-add=NET_ADMIN --device /dev/net/tun:/dev/net/tun \
    --name ztncui \
    ghcr.io/kmahyyg/ztncui-aio # /mydata above is the data folder that you use to save the supporting files
```

## Supported Configuration using local persistent storage

For ZTNCUI: https://github.com/key-networks/ztncui

Set the following environment variable when create the container, and according to your needs:

| MANDATORY | Name | Explanation | Default Value |
|:--------:|:--------:|:--------:|:--------:|
| YES | NODE_ENV | https://pugjs.org/api/express.html | production |
| no | HTTPS_HOST | Only Listen on HTTPS_HOST:HTTPS_PORT | NO DEFAULT |
| no | HTTPS_PORT | HTTPS_PORT | 3443 |
| no | HTTP_PORT | HTTP_PORT | 3000 |
| no | HTTP_ALL_INTERFACES | Listen on all interfaces, useful for reverse proxy, HTTP only | NO DEFAULT |

Note: If you do NOT set `HTTP_ALL_INTERFACES`, the 3000 port will only get listened inside container.

Set the following environment variable when create the container, and according to your needs:

| MANDATORY | Name | Explanation | Default Value |
|:--------:|:--------:|:--------:|:--------:|
| no | MYDOMAIN | generate TLS certs on the fly (if not exists) | ztncui.docker.test |
| no | ZTNCUI_PASSWD | generate admin password on the fly (if not exists) | password |
| YES | MYADDR | your ip address, public ip address preferred, will auto-detect if not set | NO DEFAULT |

Also, this image exposed an http server at port 3180, you could save file in `/mydata/ztncui/httpfs/` to serve it. 
(You could use this to build your own root server and distribute planet file, even though, that won't hurt you, I still suggest to set a protection for this http server in front)

**WARNING: IF YOU DO NOT SET PASSWORD, YOU HAVE TO USE `docker container logs <CONTAINER_NAME / CONTAINER_ID>` to get your random password. This is a gatekeeper.**

## Chinese users only

This script use https:///ip.sb for public IP detection purpose, which is blocked in some area of China Mainland. Under this circumstance, the program will try to detect public IP using `ifconfig` tool and might lead to unwanted result, to prevent this, make sure you set `MYADDR` environment variable when docker container is up.

**This repo (https://github.com/kmahyyg/ztncui-aio) only accept Issues and PRs in English. Other languages will be closed directly without any further notice. If you come from some non-English countries, use Google Translate, and state that at the beginning of the text body.**

