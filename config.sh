#!/bin/bash

# The name of the docker image
PROJECT_NAME="vnc"

# BUILD ARGS
BUILD_ARGS=(
    --build-arg DOCKER_USERID=$(id -u)
    --build-arg DOCKER_GROUPID=$(id -g)
    --build-arg DOCKER_USERNAME=$(whoami)

    --build-arg PHP_VERSION="7.2"

    --build-arg VNC_PASSWORD='0parola0'
    --build-arg DOCKER_USER_PASS='0parola0'
    )

# LAUNCH ARGS
RUN_ARGS=(
    -h "$PROJECT_NAME"

    -v `pwd`/data:/home/$(whoami)
    -v /media:/media
    -v /home/$(whoami)/dev:/home/$(whoami)/dev
    -v /home/$(whoami)/.bin:/home/$(whoami)/.bin
    -v /home/$(whoami)/dev/git/docker-dropbox/data/Dropbox:/home/$(whoami)/Dropbox

    -v /dev/dri:/dev/dri

    --shm-size 2g

    #-v /dev/sr0:/dev/cdrom
    --privileged

    --device /dev/snd

    -p 5902:5901

    # -e VNC_GEOMETRY='1920x1080'
    -e VNC_GEOMETRY='1280x800'
    -e VNC_DEPTH='24'

    --dns="`sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pi-hole`"

    --memory="12g"
    --cpu-shares=1024

    --rm
    -d
    )
