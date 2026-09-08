#!/usr/bin/env bash
# Scaffold a module from the template.  usage: scripts/new-module.sh 02 "Tool calling"
source "$(dirname "$0")/_common.sh"
NN="${1:?usage: new-module.sh <NN> \"Title\"}"
TITLE="${2:?usage: new-module.sh <NN> \"Title\"}"
DIR="$ROOT/module$NN"
[ -e "$DIR" ] && { echo "module$NN already exists" >&2; exit 1; }

mkdir -p "$DIR/demo"
sed -e "s/MODULE NN · TITLE IN CAPS/MODULE $NN · $(echo "$TITLE" | tr '[:lower:]' '[:upper:]')/" \
    -e "s/MODULE NN COMPLETE/MODULE $NN COMPLETE/" \
    "$ROOT/template/MODULE_TEMPLATE.md" > "$DIR/module$NN.md"

echo "created $DIR/module$NN.md"
echo "next:   scripts/present.sh $NN"
