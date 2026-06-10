FROM amazonlinux:2023 AS impersonate-builder 

# Refresh repos and install build dependencies
RUN dnf swap -y curl-minimal curl-full \
 && dnf swap -y libcurl-minimal libcurl-full

 RUN dnf clean all && \
    dnf install -y \
    gcc \
    gcc-c++ \
    make \
    git \
    curl \
    openssl-devel \
    libnghttp2-devel \
    zlib-devel \
    libtool \
    autoconf \
    automake \
    findutils \
    make \
    which \
    brotli-devel \
    cmake \
    ninja-build \
    golang \
    bzip2 \
    xz \
    glibc-static \
    patch

WORKDIR /build

RUN git clone --recurse-submodules https://github.com/lwthiker/curl-impersonate && \
    cd curl-impersonate && \
    ./configure --enable-static && \
    make chrome-build && \
    make chrome-install  
    # make firefox-build && 
    # make firefox-install
    
ENTRYPOINT [ "/bin/bash" ]

FROM amazonlinux:2023

RUN mkdir -p /opt/bin && \
    PATH="/opt/bin:${PATH}"

COPY --from=impersonate-builder  \
    /usr/local/bin/curl-*  \
    /usr/local/bin/curl_*  \
        /opt/bin/



