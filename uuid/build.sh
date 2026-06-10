#!/bin/bash

set -e

LAYER_NAME="uuid"
LAYER_DIR="layer"

ARCH=${ARCH:-$(uname -m)}
if [[ "$ARCH" == "x86_64" ]]; then
    PLATFORM="linux/amd64"
else
    PLATFORM="linux/arm64"
fi

echo "Building $LAYER_NAME layer for $PLATFORM..."

# Clean previous builds
rm -rf $LAYER_DIR
mkdir -p $LAYER_DIR/opt/bin

# Build Docker image and extract binary
docker build --platform $PLATFORM -t lambda-layer-$LAYER_NAME .

# Create temporary container and copy binary
CONTAINER_ID=$(docker create --platform $PLATFORM lambda-layer-$LAYER_NAME)
docker cp "$CONTAINER_ID:/opt/bin/uuidgen" "$LAYER_DIR/opt/bin/"
docker rm "$CONTAINER_ID"

# Make binary executable
chmod +x "$LAYER_DIR/opt/bin/uuidgen"

# Create layer zip
cd $LAYER_DIR
zip -r ../${LAYER_NAME}-layer.zip .
cd ..

echo "Layer built: ${LAYER_NAME}-layer.zip"
echo "Size: $(du -h ${LAYER_NAME}-layer.zip | cut -f1)"

# Test the binary
echo "Testing uuidgen..."
docker run --platform $PLATFORM --entrypoint /bin/sh --rm lambda-layer-$LAYER_NAME -c "/opt/bin/uuidgen && echo '✓ uuidgen test passed'"
