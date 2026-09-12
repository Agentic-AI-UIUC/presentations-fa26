#!/usr/bin/env bash
# Parse every deck, flag slides that overflow, and run demo self-checks.
# This is exactly what CI runs.
source "$(dirname "$0")/_common.sh"
status=0

for deck in $(decks); do
  dir="$(dirname "$deck")"
  name="$(basename "$dir")"

  if [ -f "$dir/export.py" ]; then
    echo "── export self-check $name"
    python3 "$dir/export.py" --check || { echo "   FAILED"; status=1; }
  fi

  for demo in "$dir"/demo/*.py; do
    [ -e "$demo" ] || continue
    echo "── self-check $name/$(basename "$demo")"
    (cd "$dir" && python "demo/$(basename "$demo")" >/dev/null) || { echo "   FAILED"; status=1; }
  done

  # Validate twice: at export size, and at the smallest terminal we would
  # present on. The tight pass is the one that catches slides that only fit
  # on your 32-inch monitor.
  for cfg in "$CONFIG" "$ROOT/shared/config-tight.yaml"; do
    echo "── validate $name ($(basename "$cfg"))"
    (cd "$dir" && "$PRESENTERM" -c "$cfg" -x --image-protocol ascii-blocks \
        --validate-overflows --validate-snippets --export-html \
        -o /dev/null "$(basename "$deck")" </dev/null >/dev/null) \
      || { echo "   FAILED"; status=1; }
  done
done

[ $status -eq 0 ] && echo "all decks ok"
exit $status
