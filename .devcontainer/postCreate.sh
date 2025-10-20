#!/usr/bin/env bash
set -e

echo "Running post-create steps: installing npm and python deps"

# Install node deps for TypeScript generation
if [ -d "./gen/ts" ]; then
  pushd gen/ts
  if [ -f package.json ]; then
    npm install || true
  fi
  popd
fi

# Install python deps for generation (if requirements file exists)
if [ -f "./gen/python/requirements.txt" ]; then
  python3 -m pip install --user -r ./gen/python/requirements.txt || true
fi

echo "Post-create steps completed. protoc version: $(protoc --version)"
