#!/usr/bin/env bash
# Writes <project>/.cursor/rules/pm51stack.mdc.
# The forge and the standards path belong to one project. The file is never
# written into the Cursor user profile.
set -euo pipefail

usage() {
  echo "Usage: project_config.sh <rules-path> <github|gitlab> <project-root>" >&2
}

if [[ $# -ne 3 ]]; then
  usage
  exit 2
fi

rules_path="$1"
forge="$2"
root="$3"

case "$forge" in
  github|gitlab) ;;
  *)
    echo "setup-pm51stack: forge must be github or gitlab." >&2
    exit 2
    ;;
esac

if [[ "$rules_path" == *[[:cntrl:]]* || "$rules_path" == *\\* || "$rules_path" == /* || "$rules_path" =~ ^[A-Za-z]: ]]; then
  echo "setup-pm51stack: rules path must be a single relative path." >&2
  exit 2
fi

IFS=/ read -ra parts <<< "$rules_path"
if [[ ${#parts[@]} -eq 0 ]]; then
  echo "setup-pm51stack: rules path must be a single relative path." >&2
  exit 2
fi
for part in "${parts[@]}"; do
  if [[ -z "$part" || "$part" == "." || "$part" == ".." ]]; then
    echo "setup-pm51stack: rules path must be a single relative path." >&2
    exit 2
  fi
done

if [[ -z "$root" || ! -d "$root" ]]; then
  echo "setup-pm51stack: project root is required." >&2
  exit 2
fi

cd "$root"
dest="${PWD}/.cursor/rules/pm51stack.mdc"
case "$dest" in
  */.cursor/.cursor/*)
    echo "setup-pm51stack: refusing to create .cursor/rules inside a directory that is already .cursor." >&2
    exit 1
    ;;
esac

mkdir -p "$(dirname "$dest")"
cat >"$dest" <<EOF
---
description: pm51stack project choices for the standards directory and the forge
alwaysApply: true
---
# pm51stack project

rules: ${rules_path}
forge: ${forge}

Standards are the other .mdc files in the rules directory. This file records the choices.
forge github: open a pull request on GitHub.
forge gitlab: open a merge request on GitLab.
EOF

printf '%s\n' "$dest"
