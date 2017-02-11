FROM gliderlabs/alpine
MAINTAINER Slavey Karadzhov <slav@attachix.com>
# Based on https://github.com/anatolinicolae/cloud9-docker.git

# ------------------------------------------------------------------------------
# Install Cloud9 and Supervisor
# ------------------------------------------------------------------------------

RUN apk --update add build-base g++ make curl wget openssl-dev apache2-utils git libxml2-dev sshfs nodejs bash tmux supervisor python python-dev py-pip \
 && rm -f /var/cache/apk/*\
 && git clone https://github.com/c9/core.git /cloud9 \
 && curl -s -L https://raw.githubusercontent.com/c9/install/master/link.sh | bash \
 && /cloud9/scripts/install-sdk.sh \
 && sed -i -e 's_127.0.0.1_0.0.0.0_g' /cloud9/configs/standalone.js \
 && mkdir /workspace \
 && mkdir -p /var/log/supervisor

ADD supervisord.conf /etc/

# VOLUME /workspace

# ------------------------------------------------------------------------------
# Install Xtensa GCC toolchain
# ------------------------------------------------------------------------------

# Download and install glibc compatability

ENV GLIBC_VERSION 2.25-r0

RUN apk add --update curl && \
  curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
  curl -Lo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
  curl -Lo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
  apk add glibc-bin.apk glibc.apk && \
  /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
  echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
  rm -rf glibc.apk glibc-bin.apk /var/cache/apk/*

RUN cd /tmp && \
    mkdir -p /opt/esp-open-sdk && \
    wget https://github.com/nodemcu/nodemcu-firmware/raw/master/tools/esp-open-sdk.tar.xz && \
    tar -Jxvf esp-open-sdk.tar.xz && \ 
    mv esp-open-sdk/xtensa-lx106-elf /opt/esp-open-sdk/. && \
    rm esp-open-sdk.tar.xz && \
    echo 'export PATH=/opt/esp-open-sdk/xtensa-lx106-elf/bin:$PATH' >> /etc/profile.d/esp8266.sh 

# ------------------------------------------------------------------------------    
# Install Espressif NONOS SDK v2.0
# ------------------------------------------------------------------------------

RUN cd /tmp && \
    wget http://bbs.espressif.com/download/file.php?id=1690 -O sdk.zip && \
    unzip sdk.zip && \
    mv `pwd`/ESP8266_NONOS_SDK/ /opt/esp-open-sdk/sdk && \
    rm sdk.zip

# ------------------------------------------------------------------------------
# Set Environment
# ------------------------------------------------------------------------------

ENV PATH /opt/esp-open-sdk/xtensa-lx106-elf/bin:$PATH
ENV XTENSA_TOOLS_ROOT /opt/esp-open-sdk/xtensa-lx106-elf/bin
ENV SDK_BASE /opt/esp-open-sdk/sdk
ENV FW_TOOL /opt/esp-open-sdk/xtensa-lx106-elf/bin/esptool.py  

ENV ESP_HOME /opt/esp-open-sdk

# ------------------------------------------------------------------------------
# Install ESP8266 Tools
# ------------------------------------------------------------------------------

# Install python-serial
RUN pip install pyserial

# Install esptool.py
RUN cd /tmp && \
    wget https://github.com/espressif/esptool/archive/master.zip && \
    unzip master.zip && \
    mv esptool-master $ESP_HOME/esptool && rm master.zip

# Install esptool2
RUN cd $ESP_HOME && git clone https://github.com/raburton/esptool2 && cd $ESP_HOME/esptool2 && git checkout ec0e2c72952f4fa8242eedd307c58a479d845abe && \
    cd $ESP_HOME/esptool2 && make && echo 'export PATH=$ESP_HOME/esptool2:$PATH' >> /etc/profile.d/esp8266.sh 

ENV PATH $ESP_HOME/esptool2:$PATH

EXPOSE 80

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
