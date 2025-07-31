FROM amazonlinux:2023 AS builder
RUN dnf install -y gcc make wget tar gzip
WORKDIR /build
RUN wget -O uuid.tar.gz https://www.ossp.org/pkg/lib/uuid/uuid-1.6.2.tar.gz && \
    tar xzf uuid.tar.gz && \
    cd uuid-1.6.2 && \
    ./configure --enable-static --disable-shared && \
    make

FROM scratch
COPY --from=builder /build/uuid-1.6.2/uuid /uuid-gen
