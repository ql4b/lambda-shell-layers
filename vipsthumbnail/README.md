# vipsthumbnail

> Lambda layer for high-performance image thumbnail generation using libvips

Statically compiled `vipsthumbnail` from [libvips](https://www.libvips.org/) 8.16.1, built on Amazon Linux 2023. Supports JPEG, PNG, WebP, TIFF, and GIF.

## Why vipsthumbnail

- Streaming pixel pipeline -- does not load the entire image into memory
- Significantly faster and lower memory than ImageMagick for resize operations
- Produces sharp thumbnails with lanczos3 resampling by default
- Single binary + shared libs, ~15-25 MB zipped

## Usage

```bash
# Basic thumbnail (fit within 200x200, preserving aspect ratio)
vipsthumbnail /tmp/input.jpg -s 200x200 -o /tmp/thumb.jpg

# Control JPEG quality
vipsthumbnail /tmp/input.jpg -s 300x300 -o /tmp/thumb.jpg[Q=75]

# Output as WebP
vipsthumbnail /tmp/input.jpg -s 400x400 -o /tmp/thumb.webp[Q=80]

# Crop to exact dimensions (smart crop)
vipsthumbnail /tmp/input.jpg -s 200x200 --smartcrop attention -o /tmp/thumb.jpg

# Strip metadata for smaller output
vipsthumbnail /tmp/input.jpg -s 200x200 --delete -o /tmp/thumb.jpg[Q=80,strip]
```

## Lambda shell runtime example

```bash
api_handler() {
    local input_key="$1"
    local output_key="$2"

    # Download source image from S3
    aws s3 cp "s3://$BUCKET/$input_key" /tmp/input.jpg

    # Generate thumbnail
    vipsthumbnail /tmp/input.jpg -s 200x200 -o /tmp/thumb.jpg[Q=80,strip]

    # Upload result
    aws s3 cp /tmp/thumb.jpg "s3://$BUCKET/$output_key"

    echo '{"status": "ok"}'
}
```

## Terraform

```hcl
module "vipsthumbnail" {
  source = "git::https://github.com/ql4b/terraform-aws-lambda-layer.git?ref=v1.2.0"

  name       = "vipsthumbnail"
  source_url = "https://github.com/ql4b/lambda-shell-layers/releases/download/v0.1.0/vipsthumbnail-arm64-layer.zip"
}
```

## Build

```bash
./build.sh              # native architecture
ARCH=x86_64 ./build.sh  # cross-compile for x86_64
```

## Supported formats

| Format | Read | Write |
|--------|------|-------|
| JPEG   | yes  | yes   |
| PNG    | yes  | yes   |
| WebP   | yes  | yes   |
| TIFF   | yes  | yes   |
| GIF    | yes  | no    |

## Layer contents

```
bin/vipsthumbnail      # wrapper script (sets LD_LIBRARY_PATH)
bin/vipsthumbnail.bin  # actual binary
lib/                   # shared libraries (libvips, libjpeg, libpng, libwebp, etc.)
```
