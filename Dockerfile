FROM ubuntu:latest

RUN apt-get update \
    && apt-get install -y curl

# Python
RUN apt-get install -y python3-pip python3-dev \
    && cd /usr/local/bin \
    && ln -s /usr/bin/python3 python \
    && pip3 install --upgrade pip

# Go
RUN mkdir -p /goroot \
    && curl https://storage.googleapis.com/golang/go1.14.7.linux-amd64.tar.gz | tar xvzf - -C /goroot --strip-components=1

ENV GOROOT /goroot
ENV GOPATH /gopath
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH

# Java
ENV DEBIAN_FRONTEND noninteractive

ARG JAVA_VERSION=8
ARG JAVA_RELEASE=JDK
RUN bash -c ' \
    set -euxo pipefail && \
    apt-get update && \
    pkg="openjdk-$JAVA_VERSION"; \
    if [ "$JAVA_RELEASE" = "JDK" ]; then \
        pkg="$pkg-jdk-headless"; \
    else \
        pkg="$pkg-jre-headless"; \
    fi; \
    apt-get install -y --no-install-recommends "$pkg" && \
    apt-get clean'

ENV JAVA_HOME=/usr

# Nodejs
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs

# Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Nim
RUN apt-get install -y nim


COPY . .
ENTRYPOINT [ "/test.sh" ]