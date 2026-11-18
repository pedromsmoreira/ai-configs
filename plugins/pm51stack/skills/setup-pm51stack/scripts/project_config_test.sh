#!/usr/bin/env bash
# Project config is written only under the given project root.
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

project="$tmp/project"
mkdir -p "$project"
profile="$tmp/profile"
mkdir -p "$profile/rules"
printf '%s\n' 'existing rule' >"$profile/rules/keep.mdc"

bash "$src" .cursor/rules gitlab "$project" >"$tmp/project-out.txt"

if [[ ! -f "$project/.cursor/rules/pm51stack.mdc" ]]; then
  fail "project config is not at .cursor/rules/pm51stack.mdc"
fi
grep -q '^rules: .cursor/rules$' "$project/.cursor/rules/pm51stack.mdc" || fail "project config lost the rules path"
grep -q '^forge: gitlab$' "$project/.cursor/rules/pm51stack.mdc" || fail "project config lost the forge"
grep -q '^alwaysApply: true$' "$project/.cursor/rules/pm51stack.mdc" || fail "project config is not always applied"
if [[ -e "$profile/rules/pm51stack.mdc" || -e "$profile/.cursor" ]]; then
  fail "project config was written into the user profile"
fi
if [[ "$(cat "$profile/rules/keep.mdc")" != "existing rule" ]]; then
  fail "project config changed the user profile rules folder"
fi

set +e
bash "$src" ../secrets github "$project" >"$tmp/bad.txt" 2>&1
bad=$?
set -e
if [[ "$bad" -eq 0 ]]; then
  fail "rules path with .. was accepted"
fi

set +e
bash "$src" $'rules\nINJECTED' github "$project" >"$tmp/newline.txt" 2>&1
newline=$?
set -e
if [[ "$newline" -eq 0 ]]; then
  fail "rules path with a newline was accepted"
fi
if grep -q 'INJECTED' "$project/.cursor/rules/pm51stack.mdc"; then
  fail "rejected newline path was still written"
fi

cursor_dir="$tmp/cursor-home/.cursor"
mkdir -p "$cursor_dir"
set +e
bash "$src" rules github "$cursor_dir" >"$tmp/nested.txt" 2>&1
nested=$?
set -e
if [[ "$nested" -eq 0 ]]; then
  fail "writing .cursor/rules inside a .cursor directory was accepted"
fi
if [[ -e "$cursor_dir/.cursor" ]]; then
  fail "rejected nested write still created .cursor inside the profile"
fi

set +e
bash "$src" rules github >"$tmp/noroot.txt" 2>&1
noroot=$?
set -e
if [[ "$noroot" -eq 0 ]]; then
  fail "missing project root was accepted"
fi

printf '%s\n' "ok"
