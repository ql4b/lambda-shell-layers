# QREncode Lambda Layer

QR code generation tool for AWS Lambda shell functions.

## What's Included

- `qrencode` - Command-line QR code generator
- Statically linked binary (no dependencies)
- Compatible with `provided.al2023` runtime

## Usage

### In Serverless Framework

```yaml
provider:
  layers:
    - arn:aws:lambda:us-east-1:ACCOUNT:layer:ql4b-shell-qrencode:1

functions:
  handler:
    environment:
      PATH: "/opt/bin:${env:PATH}"
```

### In Shell Function

```bash
api_handler() {
    local event="$1"
    local text=$(echo "$event" | jq -r '.text')
    
    # Generate QR code
    qrencode -o /tmp/qr.png "$text"
    
    # Return success
    echo '{"statusCode": 200, "body": "QR code generated"}'
}
```

### Command Options

```bash
# Generate QR code to file
qrencode -o output.png "Hello World"

# Generate to stdout (ASCII art)
qrencode -t ANSI "Hello World"

# Set error correction level
qrencode -l H -o output.png "Hello World"

# Set size and margin
qrencode -s 10 -m 2 -o output.png "Hello World"
```

## Building

```bash
./build.sh
```

Creates `qrencode-layer.zip` ready for Lambda deployment.

## Deployment

```bash
aws lambda publish-layer-version \
    --layer-name ql4b-shell-qrencode \
    --zip-file fileb://qrencode-layer.zip \
    --compatible-runtimes provided.al2023 \
    --compatible-architectures arm64 x86_64
```

## Size

Approximately 150KB compressed.