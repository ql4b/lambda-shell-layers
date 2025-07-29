#!/bin/bash

set -e

LAYER_NAME="$1"
AWS_REGION="${AWS_REGION:-us-east-1}"

if [ -z "$LAYER_NAME" ]; then
    echo "Usage: $0 <layer-name>"
    # echo "Available layers: qrencode, htmlq, imagemagick, pandoc, sqlite"
    echo "Available layers: qrencode, htmlq"
    exit 1
fi

if [ ! -f "$LAYER_NAME/$LAYER_NAME-layer.zip" ]; then
    echo "Layer zip not found: $LAYER_NAME/$LAYER_NAME-layer.zip"
    echo "Run: cd $LAYER_NAME && ./build.sh"
    exit 1
fi

echo "Deploying $LAYER_NAME layer to AWS..."

aws lambda publish-layer-version \
    --layer-name "ql4b-shell-$LAYER_NAME" \
    --zip-file "fileb://$LAYER_NAME/$LAYER_NAME-layer.zip" \
    --compatible-runtimes provided.al2023 \
    --compatible-architectures arm64 x86_64 \
    --description "Shell runtime layer: $LAYER_NAME" \
    --region "$AWS_REGION"

echo "✓ Layer ql4b-shell-$LAYER_NAME deployed successfully"