FROM public.ecr.aws/lambda/provided:al2023 AS pcre2grep-installer

# Install pcre2-tools
RUN dnf install -y pcre2-tools

# Create directory structure
RUN mkdir -p /opt/bin && \
    cp /usr/bin/pcre2grep /opt/bin/

# Final stage
FROM scratch
COPY --from=pcre2grep-installer /opt /opt