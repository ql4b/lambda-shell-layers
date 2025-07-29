#!/bin/bash

set -e

# LAYERS=(qrencode htmlq imagemagick pandoc sqlite)
LAYERS=(htmlq qrencode yq)


echo "Building all lambda-shell-layers..."

for layer in "${LAYERS[@]}"; do
    if [ -d "$layer" ]; then
        echo "Building $layer..."
        cd "$layer"
        ./build.sh
        cd ..
        echo "✓ $layer built successfully"
    else
        echo "⚠ $layer directory not found, skipping"
    fi
done

echo "All layers built successfully!"
echo "Layer files:"
find . -name "*-layer.zip" -exec ls -lh {} \;