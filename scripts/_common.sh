# Shared bits for the presentation scripts.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT/shared/config.yaml"
PRESENTERM="${PRESENTERM:-$(command -v presenterm || echo "$HOME/.cargo/bin/presenterm")}"

[ -x "$PRESENTERM" ] || { echo "presenterm not found. cargo install presenterm" >&2; exit 1; }

# Every <dir>/<dir>.md deck (module01/module01.md, 54-workshop/54-workshop.md), in order.
decks() {
  for d in "$ROOT"/*/; do
    d="${d%/}"; f="$d/$(basename "$d").md"
    [ -f "$f" ] && echo "$f"
  done | sort
}
