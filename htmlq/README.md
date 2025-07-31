# HTMLq Lambda Layer

HTML parsing and extraction tool for AWS Lambda shell functions.

## What's Included

- `htmlq` - Command-line HTML parser using CSS selectors
- Statically linked binary (no dependencies)
- Compatible with `provided.al2023` runtime

## Usage

### In Shell Function

```bash
api_handler() {
    local event="$1"
    local url=$(echo "$event" | jq -r '.url')
    
    # Fetch and parse HTML
    local title=$(curl -s "$url" | htmlq 'title' --text)
    local links=$(curl -s "$url" | htmlq 'a' --attribute href)
    
    echo "{\"title\": \"$title\", \"links\": $links}"
}
```

### Command Examples

```bash
# Extract text content
echo '<h1>Hello World</h1>' | htmlq 'h1' --text

# Extract attributes
echo '<a href="/page">Link</a>' | htmlq 'a' --attribute href

# Extract HTML
echo '<div><p>Content</p></div>' | htmlq 'p'

# Multiple selectors
echo '<html>...</html>' | htmlq 'h1, h2, h3' --text

# Pretty print
echo '<html>...</html>' | htmlq --pretty
```

## Building

```bash
./build.sh
```

## Size

Approximately 2MB compressed.