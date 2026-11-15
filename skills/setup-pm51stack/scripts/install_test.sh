#!/usr/bin/env bash
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
src="$here/install.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/bin" "$tmp/tree/skills/setup-pm51stack/scripts"
cp "$src" "$tmp/tree/skills/setup-pm51stack/scripts/install.sh"

cat >"$tmp/bin/node" <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == "-p" ]]; then
  printf '%s\n' "22.20.0"
  exit 0
fi
printf 'node stub\n' >&2
exit 1
EOF

cat >"$tmp/bin/npx" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"${NPX_LOG:?}"
exit 0
EOF

chmod +x "$tmp/bin/node" "$tmp/bin/npx"

export NPX_LOG="$tmp/npx.log"
export PATH="$tmp/bin:$PATH"
: >"$NPX_LOG"

set +e
bash "$tmp/tree/skills/setup-pm51stack/scripts/install.sh" user >"$tmp/out.txt" 2>"$tmp/err.txt"
code=$?
set -e

fail() {
  printf '%s\n' "$1" >&2
  printf 'exit=%s\n' "$code" >&2
  printf 'node=%s\n' "$(command -v node)" >&2
  printf 'stdout:\n' >&2
  cat "$tmp/out.txt" >&2
  printf 'stderr:\n' >&2
  cat "$tmp/err.txt" >&2
  printf 'npx:\n' >&2
  cat "$NPX_LOG" >&2
  exit 1
}

if [[ "$code" -ne 0 ]]; then
  fail "install.sh user exited $code"
fi
if [[ -n "$(cat "$tmp/err.txt")" ]]; then
  fail "install.sh user wrote to stderr"
fi
grep -q 'Installed into the user profile.' "$tmp/out.txt" || fail "missing user-profile confirmation"
grep -q 'add mattpocock/skills' "$NPX_LOG" || fail "npx did not add mattpocock/skills"
grep -q 'add addyosmani/agent-skills' "$NPX_LOG" || fail "npx did not add addyosmani/agent-skills"
grep -q -- '-g' "$NPX_LOG" || fail "user install did not pass -g"
if [[ -e "$tmp/tree/skills/grilling/SKILL.md" ]]; then
  fail "fixture included grilling"
fi
printf '%s\n' "ok"
