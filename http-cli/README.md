# http-cli Layer

Lambda layer containing the [http-cli](https://github.com/ql4b/http-cli) HTTP client for shell scripts.

## Usage

Add to your Lambda function:

```yml
# serverless.yml
functions:
  handler:
    layers:
      - ${ssm:/${env:NAMESPACE}/${env:NAME}/layers/http-cli}
    environment:
      PATH: "/opt/bin:${env:PATH}"
```

## Example

```bash
#!/bin/bash
# Simple GET request
response=$(http-cli https://httpbin.org/ip)
echo "$response"

# With headers and status codes
http-cli --dump-header - --status-codes \
    --user-agent "lambda-function/1.0" \
    https://httpbin.org/user-agent
```

## Building

```bash
./build.sh
```

Creates `http-cli-layer.zip` ready for Lambda deployment.