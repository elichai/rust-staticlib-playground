#!/usr/bin/env bash

set -ex

[ $# -eq 0 ] && { echo "Usage: $0 <path_to_staticlib>"; exit 1; }

LIB_PATH="$(realpath "$1")"
[ ! -f "$LIB_PATH" ] && { echo "Error: Library not found: $LIB_PATH"; exit 1; }

TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

LIB_NAME=$(basename "$LIB_PATH")
cp "$LIB_PATH" "$TEMP_DIR/"
cd "$TEMP_DIR"

ar x "$LIB_NAME"
rm "$LIB_NAME"
ld -r -O3 *.o -o combined.o
objcopy --strip-all --wildcard --keep-symbol='rustlib_*' combined.o
ar rcs "$LIB_NAME" combined.o
echo "Library size: $(du -h "$LIB_PATH" | cut -f1) -> $(du -h "$LIB_NAME" | cut -f1)"
cp "$LIB_NAME" "$LIB_PATH"
