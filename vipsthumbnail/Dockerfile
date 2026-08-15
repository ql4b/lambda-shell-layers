FROM amazonlinux:2023 AS vips-builder

# Install build tools and dev libraries
RUN dnf install -y \
    gcc gcc-c++ make meson ninja-build cmake pkg-config \
    glib2-devel expat-devel \
    libjpeg-turbo-devel libpng-devel \
    libwebp-devel libtiff-devel \
    giflib-devel \
    wget tar xz \
    && dnf clean all

# Build libvips from source with static linking
ARG VIPS_VERSION=8.16.1
RUN wget -q https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.xz \
    && tar xf vips-${VIPS_VERSION}.tar.xz \
    && cd vips-${VIPS_VERSION} \
    && meson setup build \
        --prefix=/usr/local \
        --default-library=shared \
        --buildtype=release \
        -Dintrospection=disabled \
        -Dmodules=disabled \
        -Dcfitsio=disabled \
        -Dfftw=disabled \
        -Dimagequant=disabled \
        -Dopenexr=disabled \
        -Dpoppler=disabled \
        -Drsvg=disabled \
        -Dheif=disabled \
        -Dpango=disabled \
        -Dcgif=disabled \
        -Dopenslide=disabled \
        -Dspng=disabled \
        -Dnifti=disabled \
        -Dmatio=disabled \
        -Dlcms=disabled \
        -Dexif=disabled \
        -Djpeg-xl=disabled \
        -Dopus=disabled \
        -Darchive=disabled \
        -Dhighway=disabled \
    && cd build \
    && ninja \
    && ninja install

# Collect vipsthumbnail and its shared library dependencies
RUN mkdir -p /opt/bin /opt/lib \
    && cp /usr/local/bin/vipsthumbnail /opt/bin/vipsthumbnail \
    && strip /opt/bin/vipsthumbnail \
    && ldd /opt/bin/vipsthumbnail | grep "=> /" | awk '{print $3}' | while read lib; do \
        # Only copy libs not present in the Lambda base image
        case "$lib" in \
            /lib64/libc.so*|/lib64/libm.so*|/lib64/libpthread.so*|/lib64/libdl.so*|/lib64/librt.so*|/lib64/ld-linux*) \
                ;; \
            *) \
                cp "$lib" /opt/lib/ \
                ;; \
        esac; \
    done \
    && ldconfig /opt/lib

# Also collect transitive deps of the copied libs
RUN for lib in /opt/lib/*.so*; do \
        ldd "$lib" 2>/dev/null | grep "=> /" | awk '{print $3}' | while read dep; do \
            case "$dep" in \
                /lib64/libc.so*|/lib64/libm.so*|/lib64/libpthread.so*|/lib64/libdl.so*|/lib64/librt.so*|/lib64/ld-linux*) \
                    ;; \
                *) \
                    [ ! -f "/opt/lib/$(basename $dep)" ] && cp "$dep" /opt/lib/ || true \
                    ;; \
            esac; \
        done; \
    done && strip /opt/lib/*.so* 2>/dev/null || true

# Create wrapper that sets LD_LIBRARY_PATH
RUN mv /opt/bin/vipsthumbnail /opt/bin/vipsthumbnail.bin \
    && printf '#!/bin/sh\nexport LD_LIBRARY_PATH=/opt/lib:$LD_LIBRARY_PATH\nexec /opt/bin/vipsthumbnail.bin "$@"\n' > /opt/bin/vipsthumbnail \
    && chmod +x /opt/bin/vipsthumbnail

FROM scratch
COPY --from=vips-builder /opt /opt
