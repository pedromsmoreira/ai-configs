#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../../.." && pwd)
cd "$root"

plugin="plugins/pm51stack"
fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

# Top-level string values are indented two spaces. Nested keys are indented further.
manifest_string() {
  awk -v key="$2" '
    { sub(/\r$/, "") }
    $0 ~ "^  \"" key "\": \"" {
      line = $0
      sub("^  \"" key "\": \"", "", line)
      sub("\"[[:space:]]*,?[[:space:]]*$", "", line)
      print line
      found = 1
      exit
    }
    END { exit !found }
  ' "$1"
}

check_marketplace() {
  awk '
    function field(line, key,    s) {
      s = line
      sub(".*\"" key "\"[[:space:]]*:[[:space:]]*\"", "", s)
      sub("\".*", "", s)
      return s
    }
    {
      sub(/\r$/, "")
      if ($0 ~ /"plugins"[[:space:]]*:[[:space:]]*\[/) in_plugins = 1
      if (!in_plugins) next
      if ($0 ~ /\{/) {
        if (depth == 0) { name = ""; source = "" }
        depth++
      }
      if (depth == 1 && $0 ~ /"name"[[:space:]]*:/) name = field($0, "name")
      if (depth == 1 && $0 ~ /"source"[[:space:]]*:/) source = field($0, "source")
      if ($0 ~ /\}/) {
        depth--
        if (depth == 0 && name == "pm51stack") {
          count++
          found_source = source
        }
      }
    }
    END {
      if (count != 1) {
        print "marketplace.json must list pm51stack once" > "/dev/stderr"
        exit 1
      }
      if (found_source != "plugins/pm51stack") {
        print "marketplace source is not plugins/pm51stack" > "/dev/stderr"
        exit 1
      }
    }
  ' "$1"
}

plugin_json="$plugin/.cursor-plugin/plugin.json"
name=$(manifest_string "$plugin_json" name) || fail "plugin name is not pm51stack"
[[ "$name" == pm51stack ]] || fail "plugin name is not pm51stack"

for key in description version license logo; do
  value=$(manifest_string "$plugin_json" "$key") || fail "plugin.json missing $key"
  [[ -n "$value" ]] || fail "plugin.json missing $key"
done

logo=$(manifest_string "$plugin_json" logo) || fail "plugin.json missing logo"
[[ "$logo" == assets/logo.svg ]] || fail "plugin logo path is not assets/logo.svg"

for field in skills agents rules; do
  value=$(manifest_string "$plugin_json" "$field") || fail "plugin.json $field must be a relative path"
  if [[ "$value" == /* || "$value" == *..* ]]; then
    fail "plugin.json $field must be a relative path"
  fi
done

check_marketplace ".cursor-plugin/marketplace.json"

if [[ ! -f "$plugin/assets/logo.svg" ]]; then
  fail "missing $plugin/assets/logo.svg"
fi

if [[ -e rules/pm51stack.mdc ]]; then
  fail "the pack ships a filled-in rules/pm51stack.mdc"
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

bug_line=$(grep -n 'playbooks/bug.md' "$plugin/skills/pm51-mode/routing.md" | head -1 | cut -d: -f1)
feature_line=$(grep -n 'playbooks/feature.md' "$plugin/skills/pm51-mode/routing.md" | head -1 | cut -d: -f1)
signal_line=$(grep -n 'playbooks/signal.md' "$plugin/skills/pm51-mode/routing.md" | head -1 | cut -d: -f1)
if [[ -z "$bug_line" || -z "$feature_line" || -z "$signal_line" ]]; then
  fail "routing.md is missing bug, feature, or signal"
fi
if (( bug_line > feature_line || signal_line > feature_line )); then
  fail "bug and signal must be matched before feature"
fi

feature_row=$(grep 'playbooks/feature.md' "$plugin/skills/pm51-mode/routing.md" | head -1)
if ! grep -F -q -- '`implement-spec` when a spec and its tickets already exist. `tdd-workflow` otherwise.' <<<"$feature_row"; then
  fail "feature row must name implement-spec when a spec and tickets exist, and tdd-workflow otherwise"
fi
feature_play="$plugin/skills/pm51-mode/playbooks/feature.md"
if ! grep -F -q 'read `implement-spec`' "$feature_play"; then
  fail "feature playbook does not build with implement-spec"
fi
if ! grep -F -q 'read `tdd-workflow`' "$feature_play"; then
  fail "feature playbook does not fall back to tdd-workflow"
fi
refactor_row=$(grep 'playbooks/refactor.md' "$plugin/skills/pm51-mode/routing.md" | head -1)
if ! grep -F -q -- '`tdd-workflow`' <<<"$refactor_row"; then
  fail "refactor row must name tdd-workflow"
fi
if grep -F -q 'poteto-mode' <<<"$refactor_row"; then
  fail "refactor row names poteto-mode"
fi
refactor_play="$plugin/skills/pm51-mode/playbooks/refactor.md"
if ! grep -F -q 'Read `tdd-workflow`' "$refactor_play"; then
  fail "refactor playbook does not build with tdd-workflow"
fi
if grep -F -q 'poteto-mode' "$refactor_play"; then
  fail "refactor playbook names poteto-mode"
fi

install="$plugin/skills/setup-pm51stack/scripts/install.sh"
graph="$plugin/skills/setup-pm51stack/decision-graph.md"

grep -E -- '--skill ' "$install" \
  | sed -E 's/.*--skill ([a-z0-9-]+).*/\1/' \
  | sort -u >"$tmp/installed"

if [[ ! -s "$tmp/installed" ]]; then
  fail "install.sh has no --skill flags"
fi

find skills -mindepth 2 -maxdepth 2 -name SKILL.md -printf '%h\n' \
  | xargs -n1 basename \
  | sort >"$tmp/shipped"

while IFS= read -r name; do
  if ! grep -F -q -- "\`$name\`" "$plugin/skills/pm51-mode/routing.md"; then
    fail "routing.md does not name installed skill $name"
  fi
  if [[ -e "$plugin/skills/$name/SKILL.md" ]]; then
    fail "plugin vendors installed skill $name"
  fi
  if ! grep -F -q -- "\`$name\`" "$graph"; then
    fail "decision-graph.md does not list installed skill $name"
  fi
  if grep -F -x -q -- "$name" "$tmp/shipped"; then
    fail "$name is both shipped and installed by setup-pm51stack"
  fi
done <"$tmp/installed"

if grep -F -q 'skills/setup-pm51stack' "$plugin/skills/setup-pm51stack/SKILL.md"; then
  fail "setup skill mentions skills/setup-pm51stack"
fi

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
    printf '%s\n' "installed skill $name is named in the pack" >&2
    cat "$tmp/leak" >&2
    exit 1
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
  '.cursor/rules/pm51stack.mdc' \
  '.cursor/rules' \
  'A path I will type' \
  'GitHub' \
  'GitLab' \
  'forge: github' \
  'forge: gitlab' \
  'The git remote is not an answer' \
  'alwaysApply: true'
do
  if ! grep -F -q -- "$phrase" "$config"; then
    fail "project-config.md is missing: $phrase"
  fi
done

for phrase in '.cursor/rules/pm51stack.mdc' 'GitHub' 'GitLab' 'project-config.md'; do
  if ! grep -F -q -- "$phrase" "$plugin/skills/pm51-mode/SKILL.md"; then
    fail "pm51-mode is missing: $phrase"
  fi
done

setup_skill="$plugin/skills/setup-pm51stack/SKILL.md"
for phrase in '.cursor/rules/pm51stack.mdc' 'GitHub' 'GitLab' '.cursor/rules' 'A path I will type'; do
  if ! grep -F -q -- "$phrase" "$setup_skill"; then
    fail "setup skill is missing: $phrase"
  fi
done

if ! grep -F -q 'project-config.md' "$plugin/skills/pm51-mode/playbooks/ship.md"; then
  fail "ship playbook does not follow project-config.md"
fi
if ! grep -F -q 'gitlab' "$plugin/skills/pm51-mode/playbooks/ship.md"; then
  fail "ship playbook does not name gitlab"
fi

models="$plugin/skills/pm51-mode/models.md"
routing="$plugin/skills/pm51-mode/routing.md"
mode="$plugin/skills/pm51-mode/SKILL.md"
setup="$plugin/skills/setup-pm51stack/SKILL.md"
lead="$plugin/agents/workflow-lead.md"
[[ -f "$models" ]] || fail "missing $models"

: >"$tmp/roles"
: >"$tmp/model-skills"
while IFS= read -r line || [[ -n "$line" ]]; do
  line=${line%$'\r'}
  [[ "$line" == \|* ]] || continue
  rest=${line#|}
  rest=${rest%|}
  role=${rest%%|*}
  role="${role#"${role%%[![:space:]]*}"}"
  role="${role%"${role##*[![:space:]]}"}"
  [[ "$role" =~ ^[abcdefghijklmnopqrstuvwxyz]+$ ]] || continue
  printf '%s\n' "$role" >>"$tmp/roles"
  skills_cell=${rest#*|}
  grep -oE '`[a-z0-9]+(-[a-z0-9]+)*`' <<<"$skills_cell" | tr -d '`' >>"$tmp/model-skills" || true
done <"$models"

if [[ -n "$(sort "$tmp/roles" | uniq -d)" ]]; then
  fail "models.md repeats a role"
fi
if [[ -n "$(sort "$tmp/model-skills" | uniq -d)" ]]; then
  fail "models.md repeats a skill"
fi

# Playbook ids named in prose, plus the forge words, are not skills.
# handoff is both a playbook and a skill, so it stays.
grep -oE '`[a-z0-9]+(-[a-z0-9]+)*`' "$routing" \
  | tr -d '`' \
  | grep -v -x -E 'forge|github|gitlab|feature|refactor|bug|ship' \
  | sort -u >"$tmp/routed" || true
sort -u "$tmp/model-skills" >"$tmp/mapped"
if ! diff -u "$tmp/routed" "$tmp/mapped" >"$tmp/skill-map-diff"; then
  printf '%s\n' "models.md skills and routing.md skills disagree" >&2
  cat "$tmp/skill-map-diff" >&2
  exit 1
fi

awk '
  /^```text$/ { capture = 1; next }
  capture && /^```$/ { exit }
  capture { sub(/\r$/, ""); print }
' "$setup" >"$tmp/defaults-block"
[[ -s "$tmp/defaults-block" ]] || fail "setup skill is missing the role default block"

: >"$tmp/defaults"
while IFS= read -r line || [[ -n "$line" ]]; do
  line=${line%$'\r'}
  if [[ ! "$line" =~ ^([a-z]+):\ [^[:space:]]+$ ]]; then
    fail "setup role default is not role: value: $line"
  fi
  printf '%s\n' "${BASH_REMATCH[1]}" >>"$tmp/defaults"
done <"$tmp/defaults-block"
if ! diff -u "$tmp/roles" "$tmp/defaults" >"$tmp/role-diff"; then
  printf '%s\n' "setup role defaults and models.md roles disagree" >&2
  cat "$tmp/role-diff" >&2
  exit 1
fi

rule='~/.cursor/rules/pm51-models.mdc'
if ! grep -F -q -- "$rule" "$mode"; then
  fail "pm51-mode is missing: $rule"
fi
if ! grep -F -q -- "$rule" "$setup"; then
  fail "setup skill is missing: $rule"
fi

if ! awk '
  /^---$/ { f++; next }
  f == 1 && /^model:/ { found = 1 }
  END { exit (f < 2 || found) }
' "$lead"; then
  fail "workflow-lead must leave model unset"
fi

printf '%s\n' "ok"
