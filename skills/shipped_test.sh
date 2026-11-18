#!/usr/bin/env bash
# Fails when the skill directories and the docs disagree.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/.." && pwd)
cd "$root"

keep=(
  conventional-commits
  database-migrations
  frontend-react
  git-commit
  go-backend
  rest-api-design
  tdd-workflow
  testing
)

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

printf '%s\n' "${keep[@]}" | sort >"$tmp/keep"

find skills -mindepth 2 -maxdepth 2 -name SKILL.md -printf '%h\n' \
  | xargs -n1 basename \
  | sort >"$tmp/found"

if ! diff -u "$tmp/keep" "$tmp/found" >"$tmp/diff"; then
  printf '%s\n' "skill directories do not match the keep list" >&2
  cat "$tmp/diff" >&2
  exit 1
fi

for name in "${keep[@]}"; do
  skill="skills/$name/SKILL.md"
  if ! awk -v n="$name" '
    BEGIN { f = 0; ok = 0 }
    /^---$/ { f++; next }
    f == 1 && $0 == "name: " n { ok = 1 }
    END { exit !ok }
  ' "$skill"; then
    fail "$skill frontmatter name is not $name"
  fi
  if ! grep -F -q -- "\`$name\`" skills/README.md; then
    fail "skills/README.md does not list $name"
  fi
  if ! grep -F -q -- "\`$name\`" rules/skills-index.mdc; then
    fail "rules/skills-index.mdc does not list $name"
  fi
done

if git grep -n -e 'to-prd' -e 'to-issues' -e 'clean-code' -e 'user-stories' -- . \
  ':(exclude)skills/shipped_test.sh' >"$tmp/gone"; then
  printf '%s\n' "a removed skill name is still in the tree" >&2
  cat "$tmp/gone" >&2
  exit 1
fi

printf '%s\n' "ok"
