# ztncui-aio

Licensed Under AGPL v3
## Usage

```bash
$ git clone https://github.com/kmahyyg/ztncui-aio # if you wanna use env file, you need to clone, else not.
$ docker pull kmahyyg/ztncui-aio
$ docker run -d -p3000:3000 -p9993:9993 -p3180:3180\
    --cap-add=NET_ADMIN --cap-add=SYS_ADMIN --device=/dev/net/tun \
    -v /mydata/ztncui:/opt/key-networks/ztncui/etc \
    -v /mydata/zt1:/var/lib/zerotier-one \
    --env-file ./denv <CHANGE HERE ACCORDING TO NEXT PART> \
    kmahyyg/ztncui-aio
```

## Supported Configuration via persistent storage

For ZTNCUI: https://github.com/key-networks/ztncui

| REQUIRED | Name | Explanation | Default Value |
|:--------:|:--------:|:--------:|:--------:|
|  no  | HTTPS_HOST | Only Listen on HTTPS_HOST:HTTPS_PORT | NO DEFAULT |
| no | HTTPS_PORT | HTTPS_PORT | 3443 |
| no | HTTP_PORT | HTTP_PORT | 3000 |
| no | HTTP_ALL_INTERFACES | Listen on all interfaces | NO DEFAULT |

This image additional specific:

| REQUIRED | Name | Explanation | Default Value |
|:--------:|:--------:|:--------:|:--------:|
| no | MYDOMAIN | generate TLS certs on the fly (if not exists) | ztncui.docker.test |
| no | ZTNCUI_PASSWD | generate admin password on the fly (if not exists) | password |
| YES | MYADDR | your ip address, public ip address preferred | NO DEFAULT |

Also, this image exposed an http server at port 3180, you could save file in `/mydata/ztncui/myfs/` to serve it. (You could use this to build your own root server and distribute planet file)

**WARNING: IF YOU DO NOT SET PASSWORD, YOU HAVE TO USE `docker exec -it <CONTAINER NAME> bash`, and then `cat /var/log/docker-ztncui.log` to get your random password. This is gatekeeper.**
