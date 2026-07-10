#!/bin/bash

set -e

LAYER_NAME="gzip"
LAYER_DIR="layer"

ARCH=${ARCH:-$(uname -m)}
if [[ "$ARCH" == "x86_64" ]]; then
    PLATFORM="linux/amd64"
else
    PLATFORM="linux/arm64"
fi

echo "Building $LAYER_NAME layer for $PLATFORM..."

rm -rf "$LAYER_DIR" *.zip
mkdir -p "$LAYER_DIR"

docker build --platform $PLATFORM -t lambda-layer-$LAYER_NAME .

CONTAINER_ID=$(docker create --platform $PLATFORM lambda-layer-$LAYER_NAME true)
docker cp "$CONTAINER_ID:/opt" "$LAYER_DIR/"
docker rm "$CONTAINER_ID"

cd "$LAYER_DIR/opt"
zip -r ../../$LAYER_NAME-layer.zip .
cd ../..

echo "✓ Layer built: $LAYER_NAME-layer.zip"
echo "✓ Size: $(du -h $LAYER_NAME-layer.zip | cut -f1)"

echo "Testing gzip..."
docker build --platform $PLATFORM --target gzip-builder -t lambda-layer-$LAYER_NAME-test .
docker run --platform $PLATFORM --entrypoint /bin/sh --rm lambda-layer-$LAYER_NAME-test -c \
    "echo hello | /opt/bin/gzip | /opt/bin/gzip -d && echo '✓ gzip test passed'"
