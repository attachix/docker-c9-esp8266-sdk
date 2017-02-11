Alpine Linux with Cloud9 and ESP8266 Toolchain. [![](https://images.microbadger.com/badges/image/attachix/c9-esp8266-sdk.svg)](https://microbadger.com/images/attachix/c9-esp8266-sdk "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/attachix/c9-esp8266-sdk.svg)](https://microbadger.com/version/attachix/c9-esp8266-sdk "Get your own version badge on microbadger.com")
=============

This repository contains Dockerfile of Cloud9 IDE, Xtensa GCC toolchain, Espressif SDK 2.0 running on Alpine Linux for Docker's automated build published to the public Docker Hub Registry.

# Base Docker Image
[gliderlabs/docker-alpine](https://github.com/gliderlabs/docker-alpine)

# Installation

## Install Docker.

Download automated build from public Docker Hub Registry: 
	
    docker pull attachix/c9-esp8266-sdk

(alternatively, you can build an image from Dockerfile: 

    docker build -t="attachix/c9-esp8266-sdk" github.com/attachix/c9-esp8266-sdk
)

## Usage

    docker run -it -d -p 80:80 attachix/c9-esp8266-sdk
    
You can add a workspace as a volume directory with the argument *-v /your-path/workspace/:/workspace/* like this :

    docker run -it -d -p 80:80 -v /your-path/workspace/:/workspace/ attachix/c9-esp8266-sdk
    
## Build and run with custom config directory

Get the latest version from github

    git clone https://github.com/attachix/c9-esp8266-sdk
    cd cloud9-docker/

Build it

    sudo docker build --force-rm=true --tag="$USER/c9-esp8266-sdk:latest" .
    
And run

    sudo docker run -d -p 80:80 -v /your-path/workspace/:/workspace/ $USER/c9-esp8266-sdk:latest

Enjoy !!
