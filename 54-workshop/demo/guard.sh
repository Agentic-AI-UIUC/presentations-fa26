#!/usr/bin/env bash
# Demo guardrail. Denies the handful of things that wreck a live demo.
# Cursor pipes JSON in on stdin; we print a JSON permission decision.
#
# Add your own forbidden commands to BLOCK_CMDS. Keep it short.

BLOCK_CMDS=(
  'git push[^|]*--force'
  'git push[^|]*-f\b'
  'rm -rf'
  'git reset --hard'
  'git clean'
  'drop table'
)
BLOCK_READS=('\.env' 'secrets?\.' '\.pem$' 'id_rsa')

input=$(cat)

# Pull one field out of the JSON. python3 ships with Xcode CLT on macOS.
field() {
  printf '%s' "$input" | python3 -c 'import sys,json;print(json.load(sys.stdin).get(sys.argv[1],""))' "$1" 2>/dev/null
}

deny() {
  printf '{"permission":"deny","user_message":"%s","agent_message":"%s"}\n' "$1" "$1"
  exit 0
}

cmd=$(field command)
if [ -n "$cmd" ]; then
  for p in "${BLOCK_CMDS[@]}"; do
    if printf '%s' "$cmd" | grep -qiE "$p"; then
      deny "Blocked by guard.sh: matches '$p'. Not during the demo."
    fi
  done
fi

path=$(field file_path)
if [ -n "$path" ] && [[ "$path" != *.env.example ]]; then
  for p in "${BLOCK_READS[@]}"; do
    if printf '%s' "$path" | grep -qiE "$p"; then
      deny "Blocked by guard.sh: '$path' looks like a secret. Read .env.example instead."
    fi
  done
fi

echo '{"permission":"allow"}'
