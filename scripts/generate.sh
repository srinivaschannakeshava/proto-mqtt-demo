#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROTO_DIR="$ROOT_DIR/proto"
OUT_ROOT="$ROOT_DIR/gen"
PROTO_FILE="$PROTO_DIR/simple.proto"

echo "Proto dir: $PROTO_DIR"
echo "Output root: $OUT_ROOT"

if [ ! -f "$PROTO_FILE" ]; then
  echo "ERROR: Proto file not found: $PROTO_FILE" >&2
  exit 1
fi

ensure_dir() { mkdir -p "$1"; }
find_plugin() {
  name="$1"
  # prefer node_modules/.bin wrappers
  if [ -d "$ROOT_DIR/node_modules/.bin" ]; then
    if [ -x "$ROOT_DIR/node_modules/.bin/$name" ]; then
      echo "$ROOT_DIR/node_modules/.bin/$name"
      return 0
    fi
    if [ -x "$ROOT_DIR/node_modules/.bin/$name.cmd" ]; then
      echo "$ROOT_DIR/node_modules/.bin/$name.cmd"
      return 0
    fi
  fi
  # fallback to PATH
  if command -v "$name" >/dev/null 2>&1; then
    command -v "$name"
    return 0
  fi
  return 1
}

ensure_dir "$OUT_ROOT/java"
ensure_dir "$OUT_ROOT/python"
ensure_dir "$OUT_ROOT/ts"
ensure_dir "$OUT_ROOT/js"
ensure_dir "$OUT_ROOT/angular"

pushd "$ROOT_DIR" >/dev/null

echo "Generating Java to gen/java"
protoc -I=proto --java_out=gen/java proto/simple.proto || true

echo "Generating Python to gen/python"
protoc -I=proto --python_out=gen/python proto/simple.proto || true

TS_PLUGIN="$(find_plugin protoc-gen-ts || true)"
if [ -n "$TS_PLUGIN" ]; then
  echo "Found ts plugin: $TS_PLUGIN"
  protoc --plugin=protoc-gen-ts="$TS_PLUGIN" -I=proto --js_out=import_style=commonjs,binary:gen/ts --ts_out=service=grpc-node:gen/ts proto/simple.proto || true
else
  echo "Skipping TypeScript generation (ts-protoc-gen missing). Install with: npm install --save-dev ts-protoc-gen grpc-tools"
fi

JS_PLUGIN="$(find_plugin protoc-gen-js || true)"
if [ -n "$JS_PLUGIN" ]; then
  echo "Found js plugin: $JS_PLUGIN"
  protoc --plugin=protoc-gen-js="$JS_PLUGIN" -I=proto --js_out=import_style=commonjs,binary:gen/js proto/simple.proto || true
else
  echo "Skipping plain JS generation (protoc-gen-js missing). Install grpc-tools or ensure protoc supports js_out."
fi

TSPROTO_PLUGIN="$(find_plugin protoc-gen-ts_proto || true)"
if [ -n "$TSPROTO_PLUGIN" ]; then
  echo "Found ts-proto plugin: $TSPROTO_PLUGIN"
  protoc --plugin=protoc-gen-ts_proto="$TSPROTO_PLUGIN" -I=proto --ts_proto_out=gen/angular proto/simple.proto || true
else
  echo "Skipping ts-proto generation (protoc-gen-ts_proto missing). Install with: npm install --save-dev ts-proto"
fi

popd >/dev/null

echo "Done"
