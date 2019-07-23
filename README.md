[![](https://images.microbadger.com/badges/image/meyay/docker-dind.svg)](https://microbadger.com/images/meyay/docker-dind "Get your own image badge on microbadger.com")[![](https://images.microbadger.com/badges/version/meyay/docker-dind.svg)](https://microbadger.com/images/meyay/docker-dind "Get your own version badge on microbadger.com")[![](https://images.microbadger.com/badges/commit/meyay/docker-dind.svg)](https://microbadger.com/images/meyay/docker-dind "Get your own commit badge on microbadger.com")
# Docker in Docker (DinD)

Based on the official docker:dind image, which is for time beeing the latest 19.03.x version.

This image includes additionaly git, curl, expect, python3 and docker-compose.

## Docker CLI Usage 
```sh
docker network create \
  --driver macvlan \
  -o parent=ovs_eth0 \
  --subnet=192.168.200.0/24 \
  --gateway=192.168.200.1 \
  --ip-range=192.168.200.17/32 \
  macvlan0

docker run -d \
 --name=docker-dind \
 --privileged \
 --restart="always" \
 --network="macvlan0" \
 --ip="192.168.200.17" \
 --ipc="host" \
 --env TZ=Europe/Berlin \
 --volume /volume1/docker/dind/root-data:/var/lib/docker:shared \
 --volume /volume1/docker/dind/data:/data:shared \
  meyay/docker-dind:19.03.0
```

The macvlan network needs to be created only once!

## Docker Compose Usage 
```
services:
  docker-dind:
    image:  meyay/docker-dind:19.03.0
    container_name: docker-dind
    privileged: true
    restart: always
    networks:
      macvlan0:
        ipv4_address: 192.168.200.17
    ipc: host
    environment:
      TZ: Europe/Berlin
    volumes:
    - /volume1/docker/dind/root-data:/var/lib/docker:shared
    - /volume1/docker/dind/data:/data:shared

networks:
  macvlan0:
    driver: macvlan
    driver_opts:
      parent: ovs_eth0
    ipam:
      config:
      - subnet: 192.168.200.0/24
        gateway: 192.168.200.1
        ip_range: 192.168.200.17/32
```
Docker-Compose will creat the network on `up` and remove it on `down` 

## Parameters
The environment parameters are split into two halves, separated by an equal, the left hand side representing the host and the right the container side.

| ENV| DEFAULT | DESCRIPTION |
| ------ | ------ | ------ |
| TZ | Europe/Berlin | The timezone to use for file operations and the log. |

The volume parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side.

| VOLUMES |  DESCRIPTION |
| ------ | ------ |
| /var/lib/docker | Docker root-data folder. Needs to be mount bind to a host folder to persist state of the dind environment. |

## Shell access
For shell access while the container is running, `docker exec -it docker-dind /bin/sh`

