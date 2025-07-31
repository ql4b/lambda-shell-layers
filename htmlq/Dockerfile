FROM rust:latest AS htmlq-builder

# Build htmlq from source
RUN cargo install htmlq

# Create layer structure
RUN mkdir -p /opt/bin && \
    cp /usr/local/cargo/bin/htmlq /opt/bin/htmlq && \
    chmod +x /opt/bin/htmlq && \
    strip /opt/bin/htmlq

FROM scratch
COPY --from=htmlq-builder /opt /opt