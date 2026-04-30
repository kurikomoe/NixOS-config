# For opencode ai agent
# Provide a stable solo development environment

FROM ubuntu:26.04

ARG LOCAL_UID=1000
ARG LOCAL_GID=1000

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /build

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        sudo \
        bash \
        vim

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup install stable

RUN cargo install cargo-binstall

RUN cargo binstall ripgrep fd-find

RUN mkdir -p /build

COPY ./scripts ./scripts

RUN apt-get install -y tar wget

RUN bash scripts/build-opencode.sh

# Enter Development Env
WORKDIR /work

CMD ["opencode"]
