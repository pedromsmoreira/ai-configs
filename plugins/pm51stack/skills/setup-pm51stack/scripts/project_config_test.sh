#!/usr/bin/env bash
# User-profile project config lands in the profile's existing rules folder.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
src="$here/project_config.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

if [[ ! -f "$src" ]]; then
  fail "missing $src"
fi

profile="$tmp/profile"
mkdir -p "$profile/rules"
printf '%s\n' 'existing rule' >"$profile/rules/keep.mdc"

bash "$src" user rules github "$profile" >"$tmp/user-out.txt"

if [[ ! -f "$profile/rules/pm51stack.mdc" ]]; then
  fail "user profile config is not in the existing rules folder"
fi
if [[ -e "$profile/.cursor" ]]; then
  fail "user profile install created .cursor inside the profile"
fi
if [[ "$(cat "$profile/rules/keep.mdc")" != "existing rule" ]]; then
  fail "user profile install replaced the existing rules folder"
fi
grep -q '^rules: rules$' "$profile/rules/pm51stack.mdc" || fail "user profile config lost the rules path"
grep -q '^forge: github$' "$profile/rules/pm51stack.mdc" || fail "user profile config lost the forge"
grep -q '^alwaysApply: true$' "$profile/rules/pm51stack.mdc" || fail "user profile config is not always applied"

project="$tmp/project"
bash "$src" project .cursor/rules gitlab "$project" >"$tmp/project-out.txt"

if [[ ! -f "$project/.cursor/rules/pm51stack.mdc" ]]; then
  fail "project config is not at .cursor/rules/pm51stack.mdc"
fi
grep -q '^rules: .cursor/rules$' "$project/.cursor/rules/pm51stack.mdc" || fail "project config lost the rules path"
grep -q '^forge: gitlab$' "$project/.cursor/rules/pm51stack.mdc" || fail "project config lost the forge"

set +e
bash "$src" user ../secrets github "$profile" >"$tmp/bad.txt" 2>&1
bad=$?
set -e
if [[ "$bad" -eq 0 ]]; then
  fail "rules path with .. was accepted"
fi
if [[ -e "$profile/.cursor" ]]; then
  fail "rejected user write still created .cursor inside the profile"
fi

printf '%s\n' "ok"
