#!/usr/bin/env bash
# Builds dist/<name>-<version>.zip from the working tree, committed or not.
# Portable manifests and hidden Claude/Codex configuration are included; only .git and dist are left out.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

name="$(jq -r .name plugin.json)"
version="$(jq -r .version plugin.json)"
out="dist/${name}-${version}.zip"

mkdir -p dist
rm -f "$out"
zip -qr "$out" . -x '.git/*' '.git' 'dist/*'
echo "$out"
