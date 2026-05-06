# Stable solo development environment for opencode ai agent

FROM ubuntu:26.04

ARG LOCAL_USER=ubuntu
ARG OPENCODE_VERSION=latest

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.cargo/bin:${PATH}"

# System dependencies and utilities for AI agent development
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        binutils \
        ca-certificates \
        curl \
        wget \
        git \
        tar \
        zip \
        unzip \
        gzip \
        bzip2 \
        xz-utils \
        sudo \
        vim \
        nano \
        less \
        man-db \
        fastfetch \
        nodejs \
        node-corepack \
        python3 \
        python3-pip \
        ripgrep \
        fd-find \
        fzf \
        jq \
        gh \
        make \
        tree \
        file \
        tmux \
        gpg \
        openssh-client \
        sqlite3 \
        git-lfs \
    && rm -rf /var/lib/apt/lists/*

# Install Python package manager (uv)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Rust and tools
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --default-toolchain stable \
    && curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

# Install Rust-based utilities (eza for better ls, bat for better cat)
RUN cargo binstall -y fd-find eza bat 2>/dev/null || true


RUN mkdir -p \
        /home/${LOCAL_USER}/.agenix \
        /home/${LOCAL_USER}/.agents \
        /home/${LOCAL_USER}/.cache/opencode \
        /home/${LOCAL_USER}/.config/opencode \
        /home/${LOCAL_USER}/.local/share/opencode \
        /home/${LOCAL_USER}/.local/state/opencode

# Mount points for configuration and persistent data
VOLUME ["/home/${LOCAL_USER}/.config/opencode", \
        "/home/${LOCAL_USER}/.local/state/opencode", \
        "/home/${LOCAL_USER}/.local/share/opencode", \
        "/home/${LOCAL_USER}/.cache/opencode", \
        "/home/${LOCAL_USER}/.agents"]

WORKDIR /build

COPY ./scripts ./scripts

RUN bash scripts/build-opencode.sh "${OPENCODE_VERSION}"

WORKDIR /work

CMD ["opencode"]
