#syntax=docker/dockerfile:1.4.3

FROM golang:1.18-alpine3.14@sha256:70ba8ec1a0e26a828c802c76ecfc65d1efe15f3cc04d579747fd6b0b23e1cea5 AS go-md2man
RUN apk add --update-cache --no-cache \
        git \
        make
# renovate: datasource=github-releases depName=cpuguy83/go-md2man
ARG GO_MD2MAN_VERSION=2.0.2
WORKDIR $GOPATH/src/github.com/cpuguy83/go-md2man
RUN test -n "${GO_MD2MAN_VERSION}" \
 && git clone --config advice.detachedHead=false --depth 1 --branch "v${GO_MD2MAN_VERSION}" \
        https://github.com/cpuguy83/go-md2man.git .
ENV CGO_ENABLED=0
RUN make bin/go-md2man \
 && mv bin/go-md2man /usr/local/bin/
RUN mkdir -p /usr/local/share/man/man1/ \
 && go-md2man -in ./go-md2man.1.md -out ./go-md2man.1 \
 && mv go-md2man.1 /usr/local/share/man/man1/

FROM scratch AS local
COPY --from=go-md2man /usr/local/bin/go-md2man ./bin/
COPY --from=go-md2man /usr/local/share/man/man1/go-md2man.1 ./share/man/man1/
