---
inclusion: always
---

# lambda-shell-layers

Pre-built Lambda layers containing statically-linked CLI tools and utilities for use with the shell-first Lambda ecosystem.

## Project Structure

Each layer lives in its own directory with:
- `Dockerfile` — multi-stage build (compile in AL2023 or native builder, final stage copies `/opt` to `scratch`)
- `build.sh` — builds Docker image, extracts `/opt`, zips it, runs a smoke test
- `README.md` — usage documentation

The `scripts/` directory contains:
- `build-all.sh` — builds all layers (update the LAYERS array when adding new ones)
- `deploy-layer.sh` — publishes a layer to AWS Lambda directly (rarely used, prefer Terraform)

## Conventions

- Binaries go in `/opt/bin/`, shared libraries in `/opt/lib/`
- Layer zips are created from inside `layer/opt/` so paths are relative to `/opt`
- AWS Lambda extracts layers to `/opt`, so binaries end up at `/opt/bin/<tool>` on PATH
- Architecture is controlled via `ARCH` env var (defaults to host `uname -m`); Docker `--platform` is set accordingly
- The build script names the zip `<layer-name>-layer.zip`; CI renames to `<layer-name>-<arch>-layer.zip`

## CI/CD

- GitHub Actions workflow at `.github/workflows/release.yml`
- Triggers on push to `main` (build + release) and on pull requests (build only, no release)
- Builds all layers for both `arm64` and `x86_64` using QEMU
- Publishes architecture-specific zips as GitHub Release assets via semantic-release
- Version determined from Conventional Commits (`fix:` = patch, `feat:` = minor, `feat!:` = major)

## Related Repositories

- **terraform-aws-lambda-layer** (`github.com/ql4b/terraform-aws-lambda-layer`) — Terraform module to provision layers from `source_dir`, `filename`, or `source_url` (e.g. a GitHub Release asset URL)
- **terraform-aws-lambda-shell-runtime-layer** (`github.com/ql4b/terraform-aws-lambda-shell-runtime-layer`) — Terraform module shipping the Go bootstrap as a Lambda layer (sub-25ms cold starts)
- **terraform-aws-lambda-function** (`github.com/ql4b/terraform-aws-lambda-function`) — Terraform module for deploying Lambda functions with layers

## Adding a New Layer

1. Create directory with the layer name
2. Add `Dockerfile` with multi-stage build (binaries to `/opt/bin`, libs to `/opt/lib` if needed)
3. Create `build.sh` following the pattern of existing layers
4. Add `README.md` with usage examples
5. Add to the `LAYERS` array in `scripts/build-all.sh`
6. Commit with `feat: add <name> layer` for a minor version bump

## Layer Compatibility

- Runtime: `provided.al2023`
- Architectures: `arm64`, `x86_64`
- Consumed via the `terraform-aws-lambda-layer` module using `source_url` pointing to GitHub Release assets

## Git Workflow

- Branch from `main`, open PR, CI validates the build
- Squash-merge to `main` triggers semantic-release
- Use Conventional Commits for commit messages
