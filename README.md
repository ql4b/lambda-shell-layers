# lambda-shell-layers

> Lambda layers for shell runtime tools and utilities

Pre-built Lambda layers containing common CLI tools and utilities for use with [lambda-shell-runtime](https://github.com/ql4b/lambda-shell-runtime). Each layer provides statically-linked binaries optimized for AWS Lambda.

## Available Layers

- **jq** - Command-line JSON processor
- **qrencode** - QR code generation from command line
- **htmlq** - HTML parsing and extraction tool
- **yq** - YAML/XML/JSON processing tool
- **http-cli** - Minimal HTTP client for shell scripts
- **pcre2grep** - Perl-compatible regex pattern matching
- **uuid** - UUID generation utility

## Quick Start

### Using GitHub Release Artifacts

Each release publishes architecture-specific zips:

```
jq-arm64-layer.zip
jq-x86_64-layer.zip
htmlq-arm64-layer.zip
...
```

Download from [Releases](https://github.com/ql4b/lambda-shell-layers/releases) and use with Terraform `source_url` or upload directly to AWS.

### Building Your Own

```bash
# Build specific layer
cd jq && ./build.sh

# Build all layers
./scripts/build-all.sh

# Build for specific architecture
ARCH=x86_64 ./scripts/build-all.sh
```

## Layer Zip Structure

All layer zips contain paths relative to `/opt`:

```
bin/              # Executable binaries
lib/              # Shared libraries (if needed)
```

AWS Lambda extracts layer zips into `/opt`, so binaries end up at `/opt/bin/<tool>` and are available in PATH.

## Usage Examples

### QR Code Generation

```bash
# In your Lambda function
api_handler() {
    local text="$1"
    qrencode -o /tmp/qr.png "$text"
    echo "QR code generated at /tmp/qr.png"
}
```

### HTML Parsing

```bash
# Extract data from HTML
api_handler() {
    local html="$1"
    echo "$html" | htmlq '.title' --text
}
```

### HTTP Requests

```bash
# Make HTTP requests
api_handler() {
    local response=$(http-cli --header "Content-Type: application/json" https://api.example.com)
    echo "$response" | jq '.data'
}
```

### Pattern Matching

```bash
# Find patterns in text
api_handler() {
    local text="$1"
    echo "$text" | pcre2grep -o "[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}" --ignore-case
}
```

### Generate UUIDs

```bash
# Generate a UUID
api_handler() {
    local uuid=$(uuidgen)
    echo "Generated UUID: $uuid"
}
```

## Building Layers

Each layer includes:

- **Dockerfile** - Multi-stage build for static binaries
- **build.sh** - Build and package script
- **README.md** - Usage documentation

### Build Requirements

- Docker
- AWS CLI (for deployment)
- zip utility

## Integration with Terraform

Using [terraform-aws-lambda-layer](https://github.com/ql4b/terraform-aws-lambda-layer) and [terraform-aws-lambda-shell-runtime-layer](https://github.com/ql4b/terraform-aws-lambda-shell-runtime-layer) modules:

```hcl
# Shell runtime (required)
module "runtime" {
  source = "git::https://github.com/ql4b/terraform-aws-lambda-shell-runtime-layer.git?ref=v1.0.0"

  name         = "shell-runtime"
  architecture = "arm64"
}

# From GitHub Release (recommended)
module "jq" {
  source = "git::https://github.com/ql4b/terraform-aws-lambda-layer.git?ref=v1.2.0"

  name       = "jq"
  source_url = "https://github.com/ql4b/lambda-shell-layers/releases/download/v0.0.3/jq-arm64-layer.zip"
}

# From local source directory
module "jq" {
  source = "git::https://github.com/ql4b/terraform-aws-lambda-layer.git?ref=v1.2.0"

  name       = "jq"
  source_dir = "path/to/lambda-shell-layers/jq/layer/opt"
}

# Use in function
module "handler" {
  source = "git::https://github.com/ql4b/terraform-aws-lambda-function.git?ref=v1.1.0"

  name         = "my-function"
  runtime      = "provided.al2023"
  handler      = "handler.run"
  architecture = "arm64"

  layers = [
    module.runtime.layer_arn,
    module.jq.layer_arn
  ]
}
```

## Releases

Tagging `v*` triggers the GitHub Actions workflow which:

1. Builds all layers for both `arm64` and `x86_64`
2. Publishes architecture-specific zips as release assets

## Contributing

To add a new layer:

1. Create directory with layer name
2. Add Dockerfile with multi-stage build (binaries go to `/opt/bin`)
3. Create `build.sh` — zip from `layer/opt/` so paths are relative to `/opt`
4. Add README.md with usage examples
5. Test with lambda-shell-runtime

## Layer Compatibility

- **Runtime**: `provided.al2023`
- **Architecture**: `arm64`, `x86_64`
- **Compatible with**: [lambda-shell-runtime](https://github.com/ql4b/lambda-shell-runtime)

---

*Part of the [cloudless](https://github.com/ql4b/cloudless-api) ecosystem.*