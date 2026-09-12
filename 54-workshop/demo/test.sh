#!/usr/bin/env bash
# Self-check for guard.sh, vendored from Agentic-AI-UIUC/54-workshop. Run: bash demo/test.sh
cd "$(dirname "$0")"
pass=0; fail=0
check() {
  got=$(printf '%s' "$2" | bash guard.sh | python3 -c 'import sys,json;print(json.load(sys.stdin)["permission"])')
  if [ "$got" = "$1" ]; then pass=$((pass+1)); printf '  PASS  %-6s %s\n' "$1" "$3"
  else fail=$((fail+1)); printf '  FAIL  want=%s got=%s  %s\n' "$1" "$got" "$3"; fi
}
check deny  '{"command":"git push --force origin main","cwd":"/x"}'   "force push"
check deny  '{"command":"git push -f","cwd":"/x"}'                    "force push short flag"
check deny  '{"command":"rm -rf node_modules","cwd":"/x"}'            "rm -rf"
check allow '{"command":"git push origin main","cwd":"/x"}'           "normal push"
check allow '{"command":"npm test","cwd":"/x"}'                       "harmless command"
check deny  '{"file_path":"/x/.env","content":"KEY=1"}'               "read .env"
check allow '{"file_path":"/x/.env.example","content":"KEY=1"}'       "read .env.example is fine"
check allow '{"file_path":"/x/src/app.ts","content":"rm -rf"}'        "content is not inspected, only path"
echo; echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
