#!/usr/bin/env bash
# Fails when the plugin manifest, playbooks, and installed skill names disagree.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../../.." && pwd)
cd "$root"

plugin="plugins/pm51stack"
fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

python3 - "$plugin/.cursor-plugin/plugin.json" ".cursor-plugin/marketplace.json" <<'PY' || exit 1
import json, sys
plugin_path, market_path = sys.argv[1:]
plugin = json.load(open(plugin_path))
market = json.load(open(market_path))
if plugin.get("name") != "pm51stack":
    raise SystemExit("plugin name is not pm51stack")
for key in ("description", "version", "license", "logo"):
    if not plugin.get(key):
        raise SystemExit(f"plugin.json missing {key}")
if plugin.get("logo") != "assets/logo.svg":
    raise SystemExit("plugin logo path is not assets/logo.svg")
for field in ("skills", "agents", "rules"):
    value = plugin.get(field, "")
    if not isinstance(value, str) or value.startswith("/") or ".." in value:
        raise SystemExit(f"plugin.json {field} must be a relative path")
entries = [item for item in market.get("plugins", []) if item.get("name") == "pm51stack"]
if len(entries) != 1:
    raise SystemExit("marketplace.json must list pm51stack once")
if entries[0].get("source") != "plugins/pm51stack":
    raise SystemExit("marketplace source is not plugins/pm51stack")
PY

if [[ ! -f "$plugin/assets/logo.svg" ]]; then
  fail "missing $plugin/assets/logo.svg"
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

find "$plugin/skills" -mindepth 2 -maxdepth 2 -name SKILL.md -printf '%h\n' \
  | xargs -n1 basename \
  | sort >"$tmp/skills"

printf '%s\n' pm51-help pm51-mode setup-pm51stack | sort >"$tmp/expect-skills"
if ! diff -u "$tmp/expect-skills" "$tmp/skills" >"$tmp/skill-diff"; then
  printf '%s\n' "plugin skill directories drifted" >&2
  cat "$tmp/skill-diff" >&2
  exit 1
fi

for name in pm51-help pm51-mode setup-pm51stack; do
  skill="$plugin/skills/$name/SKILL.md"
  if ! awk -v n="$name" '
    BEGIN { f = 0; ok = 0; desc = 0 }
    /^---$/ { f++; next }
    f == 1 && $0 == "name: " n { ok = 1 }
    f == 1 && $0 ~ /^description: / { desc = 1 }
    END { exit !(ok && desc) }
  ' "$skill"; then
    fail "$skill frontmatter needs name: $name and a description"
  fi
  if ! grep -F -q 'disable-model-invocation: true' "$skill"; then
    fail "$skill must set disable-model-invocation: true"
  fi
done

grep -oE 'playbooks/[a-z0-9-]+\.md' "$plugin/skills/pm51-mode/routing.md" \
  | sort -u >"$tmp/linked"
find "$plugin/skills/pm51-mode/playbooks" -maxdepth 1 -name '*.md' -printf '%f\n' \
  | sed 's#^#playbooks/#' \
  | sort >"$tmp/files"
if ! diff -u "$tmp/linked" "$tmp/files" >"$tmp/play-diff"; then
  printf '%s\n' "routing.md playbook links and playbook files disagree" >&2
  cat "$tmp/play-diff" >&2
  exit 1
fi

while IFS= read -r rel; do
  id=${rel#playbooks/}
  id=${id%.md}
  if ! grep -E -q "^# ${id^}\$" "$plugin/skills/pm51-mode/$rel"; then
    fail "$rel heading is not ${id^}"
  fi
  if ! grep -E -q '^1\. ' "$plugin/skills/pm51-mode/$rel"; then
    fail "$rel has no numbered steps"
  fi
done <"$tmp/files"

grep -E -- '--skill ' skills/setup-pm51stack/scripts/install.sh \
  | sed -E 's/.*--skill ([a-z0-9-]+).*/\1/' \
  | sort -u >"$tmp/installed"

if [[ ! -s "$tmp/installed" ]]; then
  fail "install.sh has no --skill flags"
fi

grep -E -- '--skill ' "$plugin/skills/setup-pm51stack/SKILL.md" \
  | grep -oE -- '--skill [a-z0-9-]+' \
  | sed -E 's/--skill //' \
  | sort -u >"$tmp/plugin-installed"

if ! diff -u "$tmp/installed" "$tmp/plugin-installed" >"$tmp/install-diff"; then
  printf '%s\n' "plugin setup skill and install.sh list different skills" >&2
  cat "$tmp/install-diff" >&2
  exit 1
fi

while IFS= read -r name; do
  if ! grep -F -q -- "\`$name\`" "$plugin/skills/pm51-mode/routing.md"; then
    fail "routing.md does not name installed skill $name"
  fi
  if [[ -e "$plugin/skills/$name/SKILL.md" ]]; then
    fail "plugin vendors installed skill $name"
  fi
done <"$tmp/installed"

for banned in poteto-mode how why setup-pstack; do
  if [[ -e "$plugin/skills/$banned/SKILL.md" ]]; then
    fail "plugin vendors pstack skill $banned"
  fi
done

config="$plugin/skills/pm51-mode/project-config.md"
if [[ ! -f "$config" ]]; then
  fail "missing $config"
fi

for phrase in \
  '.cursor/pm51stack.md' \
  '.cursor/rules' \
  'A path I will type' \
  'GitHub' \
  'GitLab' \
  'forge: github' \
  'forge: gitlab' \
  'The git remote is not an answer'
do
  if ! grep -F -q -- "$phrase" "$config"; then
    fail "project-config.md is missing: $phrase"
  fi
done

for phrase in '.cursor/pm51stack.md' 'GitHub' 'GitLab' 'project-config.md'; do
  if ! grep -F -q -- "$phrase" "$plugin/skills/pm51-mode/SKILL.md"; then
    fail "pm51-mode is missing: $phrase"
  fi
done

for path in \
  "$plugin/skills/setup-pm51stack/SKILL.md" \
  skills/setup-pm51stack/SKILL.md
do
  for phrase in '.cursor/pm51stack.md' 'GitHub' 'GitLab' '.cursor/rules' 'A path I will type'; do
    if ! grep -F -q -- "$phrase" "$path"; then
      fail "$path is missing: $phrase"
    fi
  done
done

if ! grep -F -q 'project-config.md' "$plugin/skills/pm51-mode/playbooks/ship.md"; then
  fail "ship playbook does not follow project-config.md"
fi
if ! grep -F -q 'gitlab' "$plugin/skills/pm51-mode/playbooks/ship.md"; then
  fail "ship playbook does not name gitlab"
fi

printf '%s\n' "ok"
