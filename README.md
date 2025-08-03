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

### Using Pre-built Layers

```yaml
# serverless.yml
provider:
  layers:
    - arn:aws:lambda:us-east-1:ACCOUNT:layer:ql4b-shell-qrencode:1
    - arn:aws:lambda:us-east-1:ACCOUNT:layer:ql4b-shell-htmlq:1

functions:
  handler:
    environment:
      PATH: "/opt/bin:${env:PATH}"
```

### Building Your Own

```bash
# Build specific layer
cd qrencode && ./build.sh

# Build all layers
./scripts/build-all.sh

# Deploy layer to AWS
./scripts/deploy-layer.sh qrencode
```

## Layer Structure

All layers follow the same structure:

```
/opt/
├── bin/           # Executable binaries
└── lib/           # Shared libraries (if needed)
```

Binaries are placed in `/opt/bin` and automatically available when you add `/opt/bin` to your `PATH`.

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

```hcl
# Reference pre-built layer
data "aws_lambda_layer_version" "qrencode" {
  layer_name = "ql4b-shell-qrencode"
}

# Use in function
resource "aws_lambda_function" "handler" {
  layers = [data.aws_lambda_layer_version.qrencode.arn]
  
  environment {
    variables = {
      PATH = "/opt/bin:${env:PATH}"
    }
  }
}
```

## Contributing

To add a new layer:

1. Create directory with layer name
2. Add Dockerfile with multi-stage build
3. Create build.sh script
4. Add README.md with usage examples
5. Test with lambda-shell-runtime

## Layer Compatibility

- **Runtime**: `provided.al2023`
- **Architecture**: `arm64`, `x86_64`
- **Compatible with**: [lambda-shell-runtime](https://github.com/ql4b/lambda-shell-runtime)

---

*Part of the [cloudless](https://github.com/ql4b/cloudless-api) ecosystem.*