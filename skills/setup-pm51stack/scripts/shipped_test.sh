#!/usr/bin/env bash
# Fails when the skill directories, the docs, and install.sh disagree.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../../.." && pwd)
cd "$root"

keep=(
  conventional-commits
  database-migrations
  frontend-react
  git-commit
  go-backend
  rest-api-design
  setup-pm51stack
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

grep -E -- '--skill ' skills/setup-pm51stack/scripts/install.sh \
  | sed -E 's/.*--skill ([a-z0-9-]+).*/\1/' \
  | sort >"$tmp/installed"

if [[ ! -s "$tmp/installed" ]]; then
  fail "install.sh has no --skill flags"
fi

while IFS= read -r name; do
  if grep -F -x -q -- "$name" "$tmp/keep"; then
    fail "$name is both shipped and installed by setup-pm51stack"
  fi
  if ! grep -F -q -- "\`$name\`" skills/setup-pm51stack/decision-graph.md; then
    fail "decision-graph.md does not list installed skill $name"
  fi
done <"$tmp/installed"

leak_paths=(
  README.md
  AGENTS.md
  CONFIGURATION_GUIDE.md
  CONFIGURATION_CHECKLIST.md
  rules
  agents
  skills/README.md
  skills/conventional-commits
  skills/database-migrations
  skills/frontend-react
  skills/git-commit
  skills/go-backend
  skills/rest-api-design
  skills/tdd-workflow
  skills/testing
)

while IFS= read -r name; do
  if git grep -F -n -e "\`$name\`" -- "${leak_paths[@]}" >"$tmp/leak"; then
    printf '%s\n' "installed skill $name is named outside setup-pm51stack" >&2
    cat "$tmp/leak" >&2
    exit 1
  fi
done <"$tmp/installed"

if git grep -n -e 'to-prd' -e 'to-issues' -e 'clean-code' -e 'user-stories' -- . \
  ':(exclude)skills/setup-pm51stack/scripts/shipped_test.sh' >"$tmp/gone"; then
  printf '%s\n' "a removed skill name is still in the tree" >&2
  cat "$tmp/gone" >&2
  exit 1
fi

printf '%s\n' "ok"
