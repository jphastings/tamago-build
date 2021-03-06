ARG TAMAGO_VERSION=1.16.4

# If downloading binary build from Github
FROM golang:$TAMAGO_VERSION as tamago_go

ARG TAMAGO_VERSION
RUN curl -L https://github.com/f-secure-foundry/tamago-go/releases/download/tamago-go${TAMAGO_VERSION}/tamago-go${TAMAGO_VERSION}.linux-amd64.tar.gz | tar -zxf - -C /

# Resulting image
FROM multiarch/crossbuild

COPY --from=tamago_go /usr/local/tamago-go /usr/local/tamago-go
RUN export TAMAGO=/usr/local/tamago-go/bin/go

ENV CROSS_TRIPLE=arm-linux-gnueabi
COPY build.sh boot.S config.txt /tamago-build/

ENTRYPOINT ["crossbuild", "/tamago-build/build.sh"]
CMD ["."]
