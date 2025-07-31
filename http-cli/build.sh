#!/bin/bash

set -e

LAYER_NAME="http-cli"
LAYER_DIR="layer"

echo "Building $LAYER_NAME layer..."

# Clean and create layer directory
rm -rf $LAYER_DIR
mkdir -p $LAYER_DIR/bin

# Fetch http-cli script
curl -sL https://raw.githubusercontent.com/ql4b/http-cli/refs/heads/main/http-cli \
    -o $LAYER_DIR/bin/http-cli

# Make executable
chmod +x $LAYER_DIR/bin/http-cli

# Create layer zip
cd $LAYER_DIR
zip -r ../${LAYER_NAME}-layer.zip .
cd ..

echo "Layer built: ${LAYER_NAME}-layer.zip"

