#!/bin/bash

set -e

LAYER_NAME="pcre2grep"
LAYER_DIR="layer"

echo "Building $LAYER_NAME layer..."

# Clean previous build
rm -rf $LAYER_DIR *.zip

# Build Docker image
docker build -t lambda-shell-$LAYER_NAME .

# Extract layer contents
mkdir -p $LAYER_DIR
docker create --name temp-$LAYER_NAME lambda-shell-$LAYER_NAME true
docker cp temp-$LAYER_NAME:/opt $LAYER_DIR/
docker rm temp-$LAYER_NAME

# Create zip file
cd $LAYER_DIR && zip -r ../$LAYER_NAME-layer.zip . && cd ..

echo "Layer built: $LAYER_NAME-layer.zip"
echo "Size: $(du -h $LAYER_NAME-layer.zip | cut -f1)"

# Test the binary (use builder stage since scratch has no shell)
echo "Testing binary..."
docker build --target pcre2grep-installer -t lambda-shell-$LAYER_NAME-test .
docker run --entrypoint="/bin/sh" --rm lambda-shell-$LAYER_NAME-test -c "echo -e 'body { color: #ff3a27; background: #222; }' | pcre2grep '#[0-9a-fA-F]{3,6}' && echo '✓ pcre2grep test passed'"