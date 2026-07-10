FROM amazonlinux:2023 AS gzip-builder

RUN dnf install -y gzip && \
    mkdir -p /opt/bin && \
    cp /usr/bin/gzip /opt/bin/gzip

FROM scratch
COPY --from=gzip-builder /opt /opt
