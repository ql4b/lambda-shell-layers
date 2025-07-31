# uuid Layer

Lambda layer containing the `uuidgen` command for generating UUIDs.

## Usage

```yml
# serverless.yml
functions:
  handler:
    layers:
      - ${ssm:/${env:NAMESPACE}/${env:NAME}/layers/uuid}
    environment:
      PATH: "/opt/bin:${env:PATH}"
```

## Example

```bash
#!/bin/bash
# Generate random UUID
uuid=$(uuidgen)
echo '{"id": "'$uuid'"}'

# Generate multiple UUIDs
for i in {1..5}; do
    uuidgen
done
```

## Building

```bash
./build.sh
```