#!/usr/bin/env bash
# Build the site and serve it locally.  usage: scripts/serve.sh [port]
# Re-run after editing a deck; there is no watch mode and it does not need one.
source "$(dirname "$0")/_common.sh"
PORT="${1:-8080}"
"$ROOT/scripts/build-site.sh"
echo
echo "  http://localhost:$PORT/            gallery"
echo "  http://localhost:$PORT/module01/   module page"
echo
exec python3 -m http.server -d "$ROOT/site" "$PORT"
