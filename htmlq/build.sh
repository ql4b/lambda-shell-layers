#!/bin/bash

set -e

LAYER_NAME="htmlq"
LAYER_DIR="layer"

echo "Building $LAYER_NAME layer..."

# Clean previous build
rm -rf $LAYER_DIR *.zip

# Build Docker image
docker build -t lambda-shell-$LAYER_NAME .

# Extract layer contents
mkdir -p $LAYER_DIR
docker run --rm -v $(pwd)/$LAYER_DIR:/output lambda-shell-$LAYER_NAME sh -c "cp -r /opt /output/"

# Create zip file
cd $LAYER_DIR && zip -r ../$LAYER_NAME-layer.zip . && cd ..

echo "Layer built: $LAYER_NAME-layer.zip"
echo "Size: $(du -h $LAYER_NAME-layer.zip | cut -f1)"

# Test the binary
echo "Testing binary..."
echo '<html><body><h1>Test</h1></body></html>' | docker run --rm -i lambda-shell-$LAYER_NAME /opt/bin/htmlq 'h1' --text