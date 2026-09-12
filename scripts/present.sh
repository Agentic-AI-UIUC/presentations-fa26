#!/usr/bin/env bash
# Present a module.  usage: scripts/present.sh 01 [extra presenterm flags]
source "$(dirname "$0")/_common.sh"
MODULE="${1:?usage: present.sh <NN|dir> [flags]}"; shift || true
# Accepts a module number (01) or a deck directory name (54-workshop).
DIR="$ROOT/module$MODULE"; [ -d "$DIR" ] || DIR="$ROOT/$MODULE"
[ -d "$DIR" ] || { echo "no such deck: $MODULE" >&2; exit 1; }
# cd so `demo/` imports and relative asset paths resolve.
cd "$DIR"
exec "$PRESENTERM" -c "$CONFIG" -x "$@" "$(basename "$DIR").md"
