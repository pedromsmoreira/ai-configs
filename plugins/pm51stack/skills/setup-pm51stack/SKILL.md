---
name: setup-pm51stack
description: Install Matt Pocock skills and Addy Osmani agent skills with npx skills, then ask where project rules live and whether the forge is GitHub or GitLab. Point at pstack and /pm51-mode. Use when the user runs /setup-pm51stack or asks to install pstack, mattpocock/skills, or addyosmani/agent-skills.
disable-model-invocation: true
---

# Setup pm51stack

Install the Matt Pocock skills and the Addy Osmani agent skills for Cursor. Then tell the user how to load pstack and start `/pm51-mode`.

The `--skill` flags below are the same list as `skills/setup-pm51stack/scripts/install.sh` in the ai-configs checkout. Add no others.

## Ask where to install

Ask before you run anything. Offer only these two options.

- user profile
- current project

Use AskQuestion when it is available. Do not pick for the user. Do not add a third option.

## Install

The script needs Node.js 22.20 or later, `npx`, and a network path to npm and GitHub.

When this workspace is the ai-configs checkout, run the script and skip the `npx` lines. From the checkout root:

User profile:

```bash
bash skills/setup-pm51stack/scripts/install.sh user
```

Current project:

```bash
bash skills/setup-pm51stack/scripts/install.sh project
```

When that script is not in the workspace, run `npx` yourself. User profile adds `-g`. Current project omits `-g`. `-y` skips the skills picker. `-a cursor` selects Cursor.

User profile:

```bash
npx --yes skills@latest add mattpocock/skills --skill grilling --skill domain-modeling --skill diagnosing-bugs --skill code-review --skill pr --skill wizard --skill handoff --skill to-spec --skill to-tickets --skill wayfinder --skill research --skill prototype --skill setup-matt-pocock-skills -a cursor -g -y
npx --yes skills@latest add addyosmani/agent-skills --skill security-and-hardening --skill observability-and-instrumentation --skill shipping-and-launch -a cursor -g -y
```

Current project:

```bash
npx --yes skills@latest add mattpocock/skills --skill grilling --skill domain-modeling --skill diagnosing-bugs --skill code-review --skill pr --skill wizard --skill handoff --skill to-spec --skill to-tickets --skill wayfinder --skill research --skill prototype --skill setup-matt-pocock-skills -a cursor -y
npx --yes skills@latest add addyosmani/agent-skills --skill security-and-hardening --skill observability-and-instrumentation --skill shipping-and-launch -a cursor -y
```

Matt Pocock is first. Addy Osmani is second. The skills CLI overwrites a skill when the second repository uses the same name.

A later refresh is `npx skills update -g -y` after a user-profile install, and `npx skills update -p -y` after a current-project install.

`database-migrations` ships in the ai-configs pack. This install does not replace it.

## Ask for this project

Read [../pm51-mode/project-config.md](../pm51-mode/project-config.md) and follow it in the current project. Ask where the rules live, and whether the forge is GitHub or GitLab. Write `.cursor/pm51stack.md`. The git remote is not an answer. `.cursor/rules` is an answer only when the user chooses it.

Rules. Offer only `.cursor/rules`, `rules`, or `A path I will type`. Forge. Offer only GitHub or GitLab.

A user-profile skill install still writes this file in the current project.

## After the install exits 0

Tell the user to do the rest in Cursor:

1. `/add-plugin pstack`
2. `/setup-pstack` once, to choose models
3. `/pm51-mode` plus the task

pstack is installed only when Cursor reports that the plugin installed. `/pm51-mode` comes from this plugin.
