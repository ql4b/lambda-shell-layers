FROM amazonlinux:2023 AS jq-builder

RUN mkdir -p /opt/bin && \
    curl -L "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')" \
    -o /opt/bin/jq && \
    chmod +x /opt/bin/jq

FROM scratch
COPY --from=jq-builder /opt /opt
