#!/bin/bash

set -e

LAYER_NAME="vipsthumbnail"
LAYER_DIR="layer"

ARCH=${ARCH:-$(uname -m)}
if [[ "$ARCH" == "x86_64" ]]; then
    PLATFORM="linux/amd64"
else
    PLATFORM="linux/arm64"
fi

echo "Building $LAYER_NAME layer for $PLATFORM..."

# Clean previous builds
rm -rf "$LAYER_DIR" *.zip
mkdir -p "$LAYER_DIR"

# Build Docker image and extract binaries + libs
docker build --platform $PLATFORM -t lambda-layer-$LAYER_NAME .

# Create temporary container and copy /opt
CONTAINER_ID=$(docker create --platform $PLATFORM lambda-layer-$LAYER_NAME true)
docker cp "$CONTAINER_ID:/opt" "$LAYER_DIR/"
docker rm "$CONTAINER_ID"

# Create layer zip (zip from inside opt/ so paths are relative to /opt)
cd "$LAYER_DIR/opt"
zip -r ../../$LAYER_NAME-layer.zip .
cd ../..

echo "✓ Layer built: $LAYER_NAME-layer.zip"
echo "✓ Size: $(du -h $LAYER_NAME-layer.zip | cut -f1)"

# Test the binary using the layer structure we just extracted
echo "Testing vipsthumbnail..."
docker run --platform $PLATFORM --rm \
    -v "$(pwd)/$LAYER_DIR/opt:/opt:ro" \
    amazonlinux:2023 \
    /bin/sh -c "export LD_LIBRARY_PATH=/opt/lib:\$LD_LIBRARY_PATH && /opt/bin/vipsthumbnail.bin --version && echo '✓ vipsthumbnail test passed'"
