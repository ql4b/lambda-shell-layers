FROM public.ecr.aws/lambda/provided:al2023 AS qrencode-builder

RUN dnf install -y \
    autoconf automake libtool m4 gettext gcc make \
    glibc-static perl wget tar pkgconfig

WORKDIR /build

# Download and extract source
RUN wget https://github.com/fukuchi/libqrencode/archive/refs/tags/v4.1.1.tar.gz && \
    tar xzf v4.1.1.tar.gz

WORKDIR /build/libqrencode-4.1.1

# Build static binary
RUN autoreconf -fiv && \
    ./configure LDFLAGS="-static -static-libgcc" CFLAGS="-static" \
        --enable-static --disable-shared --disable-dependency-tracking && \
    make && \
    strip qrencode

# Create layer structure
RUN mkdir -p /opt/bin && \
    cp qrencode /opt/bin/qrencode && \
    chmod +x /opt/bin/qrencode

FROM scratch
COPY --from=qrencode-builder /opt /opt