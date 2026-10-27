# Build PocketBase from the official Go module with a pinned toolchain
# instead of repackaging the prebuilt binary. Go stdlib CVEs are fixed by
# bumping GO_VERSION below (tracked automatically by Dependabot) without
# waiting for an upstream binary rebuild.
ARG GO_VERSION=1.27.3

FROM golang:${GO_VERSION}-alpine AS builder

ARG VERSION
ARG TARGETOS
ARG TARGETARCH

ENV GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH} \
    CGO_ENABLED=0 \
    GOTOOLCHAIN=local

WORKDIR /src
RUN go mod init pocketbase-build && \
    printf 'package main\n\nimport _ "ganigeorgiev.com/pocketbase/pocketbase/examples/base"\n\nfunc main() {}\n' > main.go && \
    go mod edit -require=ganigeorgiev.com/pocketbase/pocketbase@v${VERSION} && \
    go mod tidy && \
    go build -trimpath \
      -ldflags "-s -w -X ganigeorgiev.com/pocketbase/pocketbase.Version=${VERSION}" \
      -o /pocketbase \
      ganigeorgiev.com/pocketbase/pocketbase/examples/base && \
    /pocketbase --version

FROM alpine:3.24.3
RUN apk update && apk add ca-certificates tzdata && rm -rf /var/cache/apk/*

COPY --from=builder /pocketbase /usr/local/bin/pocketbase
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
