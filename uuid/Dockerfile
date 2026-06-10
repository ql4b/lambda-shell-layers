FROM amazonlinux:2023 AS uuid-builder

# Install util-linux which includes uuidgen
RUN dnf install -y util-linux

# Verify the binary works
RUN uuidgen

# Final stage - create layer structure
FROM amazonlinux:2023

# Create directory structure
RUN mkdir -p /opt/bin /opt/lib

# Copy binary and shared library
COPY --from=uuid-builder /usr/bin/uuidgen /opt/bin/uuidgen
COPY --from=uuid-builder /lib64/libuuid.so.1 /opt/lib/libuuid.so.1

# Set executable permissions
RUN chmod +x /opt/bin/uuidgen
