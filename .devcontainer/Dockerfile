
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Note: You can use any Debian/Ubuntu based image you want. Using the microsoft base Ubuntu image.
FROM mcr.microsoft.com/vscode/devcontainers/base:focal

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Docker Compose version
ARG COMPOSE_VERSION=1.24.0

# Terraform Version: https://github.com/hashicorp/terraform/releases
ARG TF_Version="1.1.5"

# Go version:
ARG GO_VERSION="1.16.7"

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    && apt-get -y install git iproute2 procps bash-completion

# Install Docker CE CLI
RUN apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common lsb-release \
    && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT) \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli

# Install Docker Compose
RUN curl -sSL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Install Golang
# https://www.digitalocean.com/community/tutorials/how-to-install-go-on-ubuntu-20-04
RUN curl -OL https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz \
    && rm -rf /usr/local/go && tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin  

# Install Terraform
RUN apt-get install -y \
    wget \
    unzip \
  && rm -rf /var/lib/apt/lists/*
RUN wget --quiet https://releases.hashicorp.com/terraform/${TF_Version}/terraform_${TF_Version}_linux_amd64.zip \
  && unzip terraform_${TF_Version}_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_${TF_Version}_linux_amd64.zip

# Install Linux stuff
RUN apt-get update \
    && apt-get install tree -y \
    && apt-get install make -y

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/downloads

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog