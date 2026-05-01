# Stable solo development environment for opencode ai agent

FROM ubuntu:26.04

ARG LOCAL_USER=ubuntu

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.cargo/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        ca-certificates \
        curl \
        git \
        tar \
        wget \
        sudo \
        vim \
        fastfetch \
    && curl https://sh.rustup.rs -sSf | bash -s -- -y --default-toolchain stable \
    && cargo install cargo-binstall \
    && cargo binstall -y ripgrep fd-find

RUN mkdir -p \
        /home/${LOCAL_USER}/.agenix \
        /home/${LOCAL_USER}/.agents \
        /home/${LOCAL_USER}/.cache/opencode \
        /home/${LOCAL_USER}/.config/opencode \
        /home/${LOCAL_USER}/.local/share/opencode \
        /home/${LOCAL_USER}/.local/state/opencode

WORKDIR /build

COPY ./scripts ./scripts

RUN bash scripts/build-opencode.sh

WORKDIR /work

CMD ["opencode"]
