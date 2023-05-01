FROM ubuntu:20.04
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    lsb-release \
    software-properties-common \
    sudo \
    unzip \
    libicu-dev \
    libzip-dev \
    less \
    wget  \
    xsltproc

WORKDIR /azp

# Additional capabilities \
# Capabilities examples : https://github.com/actions/runner-images/tree/main/images/linux/scripts/installers
ENV foo=bar
## PHP 8.1
COPY ./install-php-8.1.sh .
RUN DEBIAN_FRONTEND=noninteractive sh install-php-8.1.sh

# Installing Nvm (https://www.kabisa.nl/tech/nvm-in-docker/)
#ENV NVM_VERSION=v0.39.3
#SHELL ["/bin/bash", "--login", "-i", "-c"]
#RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash
## Install Node 16
#ENV NODE_VERSION=16
#RUN source /root/.bashrc && nvm install $NODE_VERSION
#SHELL ["/bin/bash", "--login", "-c"]

# Install node16
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && apt-get install -y nodejs
# Enable npm capability for agent
ENV npm=/usr/bin/npm

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-arm64



COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT [ "./start.sh" ]
