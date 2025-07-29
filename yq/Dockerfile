FROM public.ecr.aws/lambda/provided:al2023 AS yq-builder

# Get architecture
RUN mkdir -p /opt/bin && \
    curl -L "https://github.com/mikefarah/yq/releases/download/v4.44.3/yq_linux_$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')" \
    -o /opt/bin/yq && \
    chmod +x /opt/bin/yq

FROM scratch
COPY --from=yq-builder /opt /opt