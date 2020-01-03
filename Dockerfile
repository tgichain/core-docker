FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

RUN adduser --disabled-password --gecos '' tgic

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    git \
    sudo \
    curl \
    wget \ 
    gnupg2 \
    apt-transport-https \ 
    update-notifier \
    build-essential \
    libcairo2-dev \
    pkg-config \
    libtool \
    autoconf \
    automake \
    libpq-dev \
    ntp \
    jq \
    iptables \
    python \
    vim
RUN sudo rm -rf /usr/local/{lib/node{,/.npm,_modules},bin,share/man}/{npm*,node*,man1/node*}
RUN sudo rm -rf ~/{.npm,.forever,.node*,.cache,.nvm}
RUN sudo wget --quiet -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add - 
RUN (echo "deb https://deb.nodesource.com/node_11.x $(lsb_release -s -c) main" | sudo tee /etc/apt/sources.list.d/nodesource.list)
RUN sudo apt-get update && \
    sudo apt-get install nodejs -y
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - 
RUN (echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list)
RUN sudo apt-get update && \
    sudo apt-get install -y yarn
RUN sudo yarn global add pm2 && \
    pm2 install pm2-logrotate && \
    pm2 set pm2-logrotate:max_size 500M && \
    pm2 set pm2-logrotate:compress true && \
    pm2 set pm2-logrotate:retain 7
RUN sudo apt-get update && \
    sudo apt-get upgrade -yqq && \
    sudo apt-get dist-upgrade -yq && \
    sudo apt-get autoremove -yyq && \
    sudo apt-get autoclean -yq 
RUN sudo rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/tgichain/core /home/tgic/core-bridgechain \
    && cd /home/tgic/core-bridgechain && git checkout chore/bridgechain-changes \
    && yarn setup

ADD entrypoint.sh /home/tgic/entrypoint.sh
RUN sudo chmod +x /home/tgic/entrypoint.sh
RUN echo 'tgic ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER tgic
WORKDIR /home/tgic
EXPOSE 4102 4103
ENTRYPOINT ["bash", "-c", "/home/tgic/entrypoint.sh \"$@\"", "--"]
