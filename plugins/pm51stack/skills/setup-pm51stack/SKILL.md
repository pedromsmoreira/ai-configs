---
name: setup-pm51stack
description: Install Matt Pocock skills and Addy Osmani agent skills with npx skills, then ask where project rules live and whether the forge is GitHub or GitLab. Point at pstack and /pm51-mode. Use when the user runs /setup-pm51stack or asks to install pstack, mattpocock/skills, or addyosmani/agent-skills.
disable-model-invocation: true
---

# Setup pm51stack

Install the Matt Pocock skills and the Addy Osmani agent skills for Cursor. Then tell the user how to load pstack and start `/pm51-mode`.

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

## After the install exits 0

Tell the user to do the rest in Cursor:

1. `/add-plugin pstack`
2. `/setup-pstack` once, to choose models
3. `/pm51-mode` plus the task

pstack is installed only when Cursor reports that the plugin installed. `/pm51-mode` comes from this plugin.
