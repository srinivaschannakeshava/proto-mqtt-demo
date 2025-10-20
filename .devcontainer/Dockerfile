FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

ARG USERNAME=vscode

# Install essentials: protoc, python, node, npm, unzip
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    unzip \
    python3 \
    python3-pip \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js LTS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install protoc latest release (using a known release). Adjust version if needed.
ARG PROTOC_VERSION=33.0
RUN mkdir -p /tmp/protoc_install \
    && wget -qO /tmp/protoc_install/protoc.zip https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip \
    && unzip /tmp/protoc_install/protoc.zip -d /tmp/protoc_install \
    && mv /tmp/protoc_install/bin/* /usr/local/bin/ \
    && mv /tmp/protoc_install/include/* /usr/local/include/ \
    && rm -rf /tmp/protoc_install

# Make sure npm global installs are accessible to vscode user
RUN npm config set prefix /usr/local

USER $USERNAME
