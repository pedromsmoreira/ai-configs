---
name: setup-pm51stack
description: Install Matt Pocock skills and Addy Osmani agent skills with npx skills, then ask where project rules live and whether the forge is GitHub or GitLab. Write ~/.cursor/rules/pm51-models.mdc for per-role model choices. Point at pstack and /pm51-mode. Use when the user runs /setup-pm51stack, asks to install pstack, mattpocock/skills, or addyosmani/agent-skills, or asks to set pm51stack models.
disable-model-invocation: true
---

# Setup pm51stack

Install the Matt Pocock skills and the Addy Osmani agent skills for Cursor. Then write the model rule and tell the user to start `/pm51-mode`. pstack is optional, for a read-only question.

When the user asks to change models, set a budget, or write `~/.cursor/rules/pm51-models.mdc`, skip the installer and the project questions. Go to [Models](#models).

The installer is `scripts/install.sh` in this skill's directory. The flags in that script are the list. Add no others. Do not retype the `npx` lines. Do not call an installer outside this skill.

## Ask where to install

Ask before you run anything. Offer only these two options.

- user profile
- current project

Use AskQuestion when it is available. Do not pick for the user. Do not add a third option.

## Install

The script needs Node.js 22.20 or later, `npx`, and a network path to npm and GitHub.

Run `scripts/install.sh` with the answer. Passing `user` or `project` skips the script's own prompt. A project install also takes the workspace root, so the skills land in that project and not in this skill's directory.

User profile:

```bash
bash scripts/install.sh user
```

Current project:

```bash
bash scripts/install.sh project /absolute/path/to/the/workspace
```

User profile adds `-g`, so the skills load in every project. Current project omits `-g` and runs in the workspace root you pass. `-y` skips the skills picker. `-a cursor` selects Cursor.

A later refresh is `npx skills update -g -y` after a user-profile install, and `npx skills update -p -y` after a current-project install.

The skills CLI overwrites a skill when the second repository uses the same name. This script installs Matt Pocock first and Addy Osmani second.

`database-migrations` ships in the ai-configs pack. This install does not replace it.

## Ask for this project

Read [../pm51-mode/project-config.md](../pm51-mode/project-config.md) and follow it. Ask where the rules live, and whether the forge is GitHub or GitLab. The git remote is not an answer. `.cursor/rules` is an answer only when the user chooses it.

Rules. Offer only `.cursor/rules`, `rules`, or `A path I will type`. Forge. Offer only GitHub or GitLab.

Write the answers with `scripts/project_config.sh`. Pass the rules path, `github` or `gitlab`, and the workspace root of the open project. Do not write the file by hand. The file is `.cursor/rules/pm51stack.mdc` in that project, including after a user-profile skill install.

```bash
bash scripts/project_config.sh .cursor/rules github /absolute/path/to/the/workspace
```

## Models

Write `~/.cursor/rules/pm51-models.mdc`, an always-applied rule. One line per role. `/pm51-mode` reads it. The roles and the skills they cover are [../pm51-mode/models.md](../pm51-mode/models.md).

### 1. Detect available models

Enumerate the model slugs you can pass to a Task subagent in this session. That is the dependable source. If you cannot detect any, ask the user to paste the slugs they have access to. Never write a real slug you have not confirmed is available. `inherit-parent` and `auto` are always valid.

### 2. Load current state

The default role lines are the block below. If `~/.cursor/rules/pm51-models.mdc` already exists, read it. Treat its `# budget` line and its role values as the current choices. Drop a line whose role is not in the block. On a re-run, keep a role whose value is `inherit-parent` or `auto`, and keep a role whose slug family differs from the pick below. A family is the slug with its effort token and a trailing `fast` removed. Still apply the budget to a kept family's effort.

```text
question: inherit-parent
frame: judgment
specify: judgment
build: code
bug: code
signal: inherit-parent
review: judgment
security: judgment
ship: inherit-parent
handoff: inherit-parent
```

`code` and `judgment` name a pick. The rule stores the detected slug for that pick.

The effort token is the last token when it is `xhigh`, `high`, `medium`, or `low`, or the token before a trailing `fast` when that token is one of those four. Any other slug has no effort and sits below `low`. A trailing `fast` marks the fast variant. The ladder is `xhigh` > `high` > `medium` > `low`.

Code pick: among detected slugs, take the highest effort. When any detected slug is fast, the code pick is fast.

Judgment pick: among detected slugs, take the highest effort. At the same effort, a slug that is not fast wins over a fast slug. When that pick is the code pick and another family is detected, take the other family's highest effort instead. At that family's top, a slug that is not fast wins over a fast slug.

When no detected slug has an effort token, the code pick is a fast slug when one exists, and otherwise any detected slug. The judgment pick is a slug that is not fast when one exists, and otherwise the code pick.

### 3. Budget, map, and confirm

Ask for a budget with AskQuestion. Offer these three labels. Name the current budget when the rule records one. With no rule, say that `large` matches the picks above.

- `large — xhigh reasoning`
- `medium — high reasoning`
- `small — medium reasoning`

Apply the budget to every real slug. `large` keeps the pick's effort. `medium` lowers it one step. `small` lowers it two steps. A target at the bottom of the ladder stays there. A slug with no effort token stays as detected. `inherit-parent` and `auto` stay as written. When the lowered slug is not detected, use the same family's detected slug with the highest effort at or below the target. When none exists, mark the role as needing a choice.

Show every role with its model. Ask whether to accept or to change specific roles. Offer the detected models plus `inherit-parent` and `auto`. Use AskQuestion. One role is one slug.

### 4. Validate

Every real slug written is in the detected set. `inherit-parent` and `auto` always pass. When a chosen real slug is not available, stop and ask again.

### 5. Write the rule

Overwrite `~/.cursor/rules/pm51-models.mdc` so a re-run stays idempotent. `alwaysApply` stays true. The angle-bracket lines are the picks after the budget. Write real slugs there.

```markdown
---
description: pm51stack per-role model choices
alwaysApply: true
---
# pm51stack model configuration. One line per role. Delete a line to follow that skill in the parent chat.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (omit Task `model`).
# budget: large (xhigh)
question: inherit-parent
frame: <judgment slug>
specify: <judgment slug>
build: <code slug>
bug: <code slug>
signal: inherit-parent
review: <judgment slug>
security: <judgment slug>
ship: inherit-parent
handoff: inherit-parent
```

### 6. Confirm

Tell the user the rule was written and that it applies to new sessions.

## After the install exits 0

Skip this section when you did not run the installer.

Tell the user to do the rest in Cursor:

1. `/pm51-mode` plus the task

The model rule is `~/.cursor/rules/pm51-models.mdc`. `/add-plugin pstack` is optional. It supplies `how` and `why` for a read-only question. `/pm51-mode` comes from this plugin. pstack is installed only when Cursor reports that the plugin installed.
