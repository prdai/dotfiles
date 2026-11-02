#!/bin/bash
set -e

if [ ! -f "package.json" ]; then
  echo "No package.json found. Run this from the project root."
  exit 1
fi

if [ ! -f "index.html" ]; then
  echo "No index.html found in the project root."
  exit 1
fi

if ! npm ls vite-plugin-singlefile >/dev/null 2>&1; then
  echo "Installing vite-plugin-singlefile"
  npm install -D vite-plugin-singlefile
fi

rm -rf dist bundle.html

echo "Building with Vite"
npx vite build --outDir dist --emptyOutDir

cp dist/index.html bundle.html

BYTES=$(wc -c < bundle.html)
LIMIT=$((4 * 1024 * 1024))
SIZE=$(du -h bundle.html | cut -f1)

echo "Bundle: bundle.html ($SIZE)"

if [ "$BYTES" -gt "$LIMIT" ]; then
  echo "Bundle exceeds the 4 MiB Postplan limit. Remove unused dependencies and rebuild."
  exit 1
fi
