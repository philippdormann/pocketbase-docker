FROM alpine:3.24.2 AS downloader

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG VERSION

ENV BUILDX_ARCH="${TARGETOS:-linux}_${TARGETARCH:-amd64}${TARGETVARIANT}"
ENV POCKETBASE_HOST="https://ganigeorgiev.com"
ENV POCKETBASE_PROJECT="pocketbase"
ENV POCKETBASE_REPO="pocketbase"

RUN wget ${POCKETBASE_HOST}/meta/${POCKETBASE_PROJECT}/${POCKETBASE_REPO}/download/v${VERSION}/pocketbase_${VERSION}_${BUILDX_ARCH}.zip \
    && unzip pocketbase_${VERSION}_${BUILDX_ARCH}.zip \
    && chmod +x /pocketbase

FROM alpine:3.24.2
RUN apk update && apk add ca-certificates tzdata && rm -rf /var/cache/apk/*

COPY --from=downloader /pocketbase /usr/local/bin/pocketbase
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
