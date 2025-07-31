#!/bin/bash

set -e

LAYER_NAME="uuid"
LAYER_DIR="layer"

echo "Building $LAYER_NAME layer..."

# Clean and create layer directory
rm -rf $LAYER_DIR
mkdir -p $LAYER_DIR/bin

# Use util-linux uuidgen (already available)
docker run --rm -v $(pwd)/$LAYER_DIR:/output amazonlinux:2023 sh -c '
    dnf install -y util-linux
    cp /usr/bin/uuidgen /output/bin/
'

# Create layer zip
cd $LAYER_DIR
zip -r ../${LAYER_NAME}-layer.zip .
cd ..

echo "Layer built: ${LAYER_NAME}-layer.zip"