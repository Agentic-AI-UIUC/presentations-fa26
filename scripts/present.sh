#!/usr/bin/env bash
# Present a module.  usage: scripts/present.sh 01 [extra presenterm flags]
source "$(dirname "$0")/_common.sh"
MODULE="${1:?usage: present.sh <NN> [flags]}"; shift || true
DIR="$ROOT/module$MODULE"
[ -d "$DIR" ] || { echo "no such module: $DIR" >&2; exit 1; }
# cd so `demo/` imports and relative asset paths resolve.
cd "$DIR"
exec "$PRESENTERM" -c "$CONFIG" -x "$@" "module$MODULE.md"
