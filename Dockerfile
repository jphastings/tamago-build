ARG TAMAGO_VERSION=1.16.4
ARG TAMAGO_FROM=binary

# Compiles from source
FROM golang:$TAMAGO_VERSION as from_source

ARG TAMAGO_VERSION

RUN cd /usr/local && \
    git clone --depth 1 --branch "tamago${TAMAGO_VERSION}" "https://github.com/f-secure-foundry/tamago-go"
RUN cd /usr/local/tamago-go/src && \
    ./all.bash

# Download the referenced build from the Github repo
FROM golang:$TAMAGO_VERSION as from_binary

ARG TAMAGO_VERSION
RUN curl -L https://github.com/f-secure-foundry/tamago-go/releases/download/tamago-go${TAMAGO_VERSION}/tamago-go${TAMAGO_VERSION}.linux-amd64.tar.gz | tar -zxf - -C /

# Get tamago-go; workaround cos ARG can't be used in COPY
FROM from_$TAMAGO_FROM as tamago_go

# Resulting image
FROM multiarch/crossbuild

COPY --from=tamago_go /usr/local/tamago-go /usr/local/tamago-go
RUN export TAMAGO=/usr/local/tamago-go/bin/go

ENV CROSS_TRIPLE=arm-linux-gnueabi
COPY build.sh boot.S config.txt /tamago-build/

ENTRYPOINT ["crossbuild", "/tamago-build/build.sh"]
CMD ["."]
