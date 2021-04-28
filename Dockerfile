FROM multiarch/crossbuild

ENV CROSS_TRIPLE=arm-linux-gnueabi

ENV TAMAGO_VERSION=1.16.3
RUN curl -L https://github.com/f-secure-foundry/tamago-go/releases/download/tamago-go${TAMAGO_VERSION}/tamago-go${TAMAGO_VERSION}.linux-amd64.tar.gz | tar -zxf - -C /
ENV TAMAGO=/usr/local/tamago-go/bin/go

COPY build.sh boot.S config.txt /tamago-build/

ENTRYPOINT ["crossbuild", "/tamago-build/build.sh"]
CMD ["."]
