#!/bin/bash

set -e

LAYERS=(jq htmlq yq qrencode pcre2grep uuid http-cli curl-impesonate)

ARCH=${ARCH:-$(uname -m)}
echo "Building all lambda-shell-layers for ${ARCH}..."

for layer in "${LAYERS[@]}"; do
    if [ -d "$layer" ] && [ -f "$layer/build.sh" ]; then
        echo "Building $layer..."
        cd "$layer"
        ARCH=$ARCH ./build.sh
        cd ..
        echo "✓ $layer built successfully"
    else
        echo "⚠ $layer directory or build.sh not found, skipping"
    fi
done

echo "All layers built successfully!"
echo "Layer files:"
find . -name "*-layer.zip" -exec ls -lh {} \;
