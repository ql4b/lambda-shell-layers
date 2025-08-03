FROM public.ecr.aws/lambda/provided:al2023 AS uuid-builder

# Install util-linux which includes uuidgen
RUN dnf install -y util-linux

# Verify the binary works
RUN uuidgen

# Final stage - create layer structure
FROM public.ecr.aws/lambda/provided:al2023

# Create directory structure
RUN mkdir -p /opt/bin

# Copy binary to layer directory
COPY --from=uuid-builder /usr/bin/uuidgen /opt/bin/uuidgen

# Set executable permissions
RUN chmod +x /opt/bin/uuidgen