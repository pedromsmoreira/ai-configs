#!/usr/bin/env bash
# Installs Matt Pocock and Addy Osmani skills for Cursor.
# pstack is a Cursor plugin and is not part of either npx install.
set -euo pipefail

usage() {
  echo "Usage: install.sh <user|project> [project-root]" >&2
  echo "  user     user profile. Skills load in every project." >&2
  echo "  project  current project. project-root is required." >&2
}

choose_scope() {
  local choice
  {
    echo "Where should the skills be installed?"
    echo "  1) user profile"
    echo "  2) current project"
    printf "Choice: "
  } >/dev/tty
  read -r choice </dev/tty
  case "$choice" in
    1|user|"user profile") echo user ;;
    2|project|"current project") echo project ;;
    *)
      echo "setup-pm51stack: choose user profile or current project." >&2
      return 2
      ;;
  esac
}

scope="${1:-}"
project_root="${2:-}"
if [[ -z "$scope" ]]; then
  if [[ -t 0 ]]; then
    scope=$(choose_scope)
  else
    usage
    exit 2
  fi
fi

case "$scope" in
  user|profile|"user profile") scope=user ;;
  project|"current project") scope=project ;;
  *)
    usage
    echo "setup-pm51stack: unknown destination '${scope}'." >&2
    exit 2
    ;;
esac

if ! command -v node >/dev/null 2>&1 || ! command -v npx >/dev/null 2>&1; then
  echo "setup-pm51stack: install Node.js 22.20 or later so npx can run." >&2
  exit 1
fi

ver=$(node -p "process.versions.node")
major=${ver%%.*}
rest=${ver#*.}
minor=${rest%%.*}
if (( major < 22 )) || { (( major == 22 )) && (( minor < 20 )); }; then
  echo "setup-pm51stack: Node.js ${ver} is too old. The skills CLI needs Node.js 22.20 or later." >&2
  exit 1
fi

if [[ "$scope" == project && -z "$project_root" && -t 0 ]]; then
  printf "Workspace root: " >/dev/tty
  read -r project_root </dev/tty
fi

if [[ "$scope" == project ]]; then
  if [[ -z "$project_root" || ! -d "$project_root" ]]; then
    echo "setup-pm51stack: project install needs the workspace root." >&2
    exit 2
  fi
  cd "$project_root"
fi

run_add() {
  local repo="$1"
  shift
  if [[ "$scope" == user ]]; then
    npx --yes skills@latest add "$repo" "$@" -a cursor -g -y
  else
    npx --yes skills@latest add "$repo" "$@" -a cursor -y
  fi
}

# https://github.com/mattpocock/skills
run_add mattpocock/skills \
  --skill grilling \
  --skill domain-modeling \
  --skill diagnosing-bugs \
  --skill code-review \
  --skill pr \
  --skill wizard \
  --skill handoff \
  --skill to-spec \
  --skill to-tickets \
  --skill implement-spec \
  --skill tdd \
  --skill wayfinder \
  --skill research \
  --skill prototype \
  --skill setup-matt-pocock-skills
# https://github.com/addyosmani/agent-skills
run_add addyosmani/agent-skills \
  --skill security-and-hardening \
  --skill observability-and-instrumentation \
  --skill shipping-and-launch

if [[ "$scope" == user ]]; then
  echo "Installed into the user profile."
else
  echo "Installed into the current project: ${PWD}"
fi
echo "pstack is optional. In Cursor, /add-plugin pstack supplies how and why for a read-only question."
