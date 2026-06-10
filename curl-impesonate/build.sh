#!/bin/bash

set -e

LAYER_NAME="curl-impersonate"
LAYER_DIR="$(dirname "$0")"
BUILD_DIR="$LAYER_DIR/layer"

echo "Building $LAYER_NAME layer..."

# Clean previous builds
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Get target architecture (default to current platform)
ARCH=${ARCH:-$(uname -m)}
if [[ "$ARCH" == "x86_64" ]]; then
    PLATFORM="linux/amd64"
else
    PLATFORM="linux/arm64"
fi

echo "Building for platform: $PLATFORM"

# Build Docker image and extract binary
docker build --platform $PLATFORM -t lambda-layer-$LAYER_NAME "$LAYER_DIR"

# Create temporary container and copy binary
CONTAINER_ID=$(docker create --platform $PLATFORM lambda-layer-$LAYER_NAME)
docker cp "$CONTAINER_ID:/opt" "$BUILD_DIR/"
echo "Contents of $BUILD_DIR/opt/bin/:"
ls -la "$BUILD_DIR/opt/bin/"
docker rm "$CONTAINER_ID"

# Verify binary
echo "Verifying curl-impersonate binary..."
file "$BUILD_DIR/opt/bin/curl-impersonate-chrome"

# Only test execution if we're on the same architecture
if file "$BUILD_DIR/opt/bin/curl-impersonate-chrome" | grep -q "$(uname -m)"; then
    "$BUILD_DIR/opt/bin/curl-impersonate" --version
else
    echo "Cross-compiled binary - skipping execution test"
fi

# Create layer zip (paths relative to /opt)
cd "$BUILD_DIR/opt"
zip -r "../../$LAYER_NAME-layer.zip" .
cd ../..

echo "✓ Layer built: $LAYER_NAME-layer.zip"
echo "✓ Size: $(du -h "$LAYER_NAME-layer.zip" | cut -f1)"

# Test the binary in Docker environment
echo "Testing curl-impersonate in Docker environment..."
docker run --entrypoint /bin/sh --rm lambda-layer-$LAYER_NAME -c "/opt/bin/curl-impersonate-chrome --version && echo '✓ curl-impersonate test passed'"
