# Shared bits for the presentation scripts.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT/shared/config.yaml"
PRESENTERM="${PRESENTERM:-$(command -v presenterm || echo "$HOME/.cargo/bin/presenterm")}"

[ -x "$PRESENTERM" ] || { echo "presenterm not found. cargo install presenterm" >&2; exit 1; }

# Every moduleNN/moduleNN.md, in order.
decks() { find "$ROOT" -mindepth 2 -maxdepth 2 -name 'module*.md' | sort; }
