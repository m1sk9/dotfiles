#!/usr/bin/env bash
set -eu
here="$(dirname "$0")/files"
cp "$here/Cargo.toml" .
mkdir -p .github/workflows
cp "$here/dotgithub-workflows/ci.yaml" .github/workflows/ci.yaml
