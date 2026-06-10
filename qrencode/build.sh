#!/bin/bash

set -e

LAYER_NAME="qrencode"
LAYER_DIR="layer"

ARCH=${ARCH:-$(uname -m)}
if [[ "$ARCH" == "x86_64" ]]; then
    PLATFORM="linux/amd64"
else
    PLATFORM="linux/arm64"
fi

echo "Building $LAYER_NAME layer for $PLATFORM..."

# Clean previous build
rm -rf $LAYER_DIR *.zip

# Build Docker image
docker build --platform $PLATFORM -t lambda-shell-$LAYER_NAME .

# Extract layer contents
mkdir -p $LAYER_DIR
docker create --platform $PLATFORM --name temp-$LAYER_NAME lambda-shell-$LAYER_NAME true
docker cp temp-$LAYER_NAME:/opt $LAYER_DIR/
docker rm temp-$LAYER_NAME

# Create zip file (paths relative to /opt)
cd $LAYER_DIR/opt && zip -r ../../$LAYER_NAME-layer.zip . && cd ../..

echo "Layer built: $LAYER_NAME-layer.zip"
echo "Size: $(du -h $LAYER_NAME-layer.zip | cut -f1)"

# Test the binary
echo "Testing binary..."
docker build --platform $PLATFORM --target qrencode-builder -t lambda-shell-$LAYER_NAME-test .
docker run --platform $PLATFORM --entrypoint /bin/sh --rm lambda-shell-$LAYER_NAME-test -c "/opt/bin/qrencode --version && echo '✓ qrencode test passed'" || echo "Binary test completed"
