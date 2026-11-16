#!/usr/bin/env bash
# Writes pm51stack.mdc.
# user: the profile's existing rules folder. The profile is already the .cursor directory.
# project: .cursor/rules from the project root.
set -euo pipefail

usage() {
  echo "Usage: project_config.sh <user|project> <rules-path> <github|gitlab> [root]" >&2
}

if [[ $# -lt 3 || $# -gt 4 ]]; then
  usage
  exit 2
fi

scope="$1"
rules_path="$2"
forge="$3"
root="${4:-}"

case "$scope" in
  user|profile|"user profile") scope=user ;;
  project|"current project") scope=project ;;
  *)
    usage
    echo "setup-pm51stack: unknown destination '${scope}'." >&2
    exit 2
    ;;
esac

case "$forge" in
  github|gitlab) ;;
  *)
    echo "setup-pm51stack: forge must be github or gitlab." >&2
    exit 2
    ;;
esac

if [[ "$rules_path" == *\\* || "$rules_path" == /* || "$rules_path" =~ ^[A-Za-z]: ]]; then
  echo "setup-pm51stack: rules path must be relative to the project root." >&2
  exit 2
fi

IFS=/ read -ra parts <<< "$rules_path"
if [[ ${#parts[@]} -eq 0 ]]; then
  echo "setup-pm51stack: rules path must be relative to the project root." >&2
  exit 2
fi
for part in "${parts[@]}"; do
  if [[ -z "$part" || "$part" == "." || "$part" == ".." ]]; then
    echo "setup-pm51stack: rules path must be relative to the project root." >&2
    exit 2
  fi
done

if [[ "$scope" == user ]]; then
  if [[ -z "$root" ]]; then
    root="${HOME}/.cursor"
  fi
  dest="${root}/rules/pm51stack.mdc"
else
  if [[ -z "$root" ]]; then
    root="$(pwd)"
  fi
  dest="${root}/.cursor/rules/pm51stack.mdc"
fi

case "$dest" in
  */.cursor/.cursor/*)
    echo "setup-pm51stack: refusing to create .cursor/rules inside the user profile." >&2
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
