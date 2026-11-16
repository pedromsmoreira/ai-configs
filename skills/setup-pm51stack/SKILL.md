---
name: setup-pm51stack
description: Install Matt Pocock skills and Addy Osmani agent skills with npx skills, then point at the pstack plugin. Use when the user runs /setup-pm51stack or asks to install pstack, mattpocock/skills, or addyosmani/agent-skills on a Mac.
disable-model-invocation: true
---

# Setup pm51stack

Install the Matt Pocock skills and the Addy Osmani agent skills for Cursor. Then tell the user how to install pstack.

## Ask where to install

Ask before you run anything. Offer only these two options.

- user profile
- current project

Use AskQuestion when it is available. Do not pick for the user. Do not add a third option.

## Install the two packs

From this clone, execute the script with the answer. Do not retype the `npx` lines.

User profile:

```bash
bash skills/setup-pm51stack/scripts/install.sh user
```

Current project:

```bash
bash skills/setup-pm51stack/scripts/install.sh project
```

Passing `user` or `project` skips the script's own prompt. A person who runs the script with no argument in a terminal gets the same two options.

The script needs Node.js 22.20 or later, `npx`, and a network path to npm and GitHub. It installs Matt Pocock skills and Addy Osmani skills. None of those installed skills live in this clone. The `--skill` flags in `scripts/install.sh` are the list. `wayfinder` calls `research` and `prototype`. `wayfinder`, `to-spec`, `to-tickets`, and `code-review` tell the user to run `setup-matt-pocock-skills` when no issue tracker is configured.

`database-migrations` ships in this repo. The script does not install it.

User profile adds `-g`, so the skills load in every project. Current project omits `-g`, so they land in the directory where the script is run. `-y` skips the skills picker.

A later refresh is `npx skills update -g -y` after a user-profile install, and `npx skills update -p -y` after a current-project install.

The skills CLI overwrites a skill when the second repository uses the same name. This script installs Matt Pocock first and Addy Osmani second.

## pstack

pstack is not in either repository. After the script exits 0, tell the user to run `/add-plugin pstack` in Cursor. Do not say pstack is installed unless Cursor reports that the plugin installed.

The workflow controller is the pm51stack plugin in `plugins/pm51stack`. When `/pm51-mode` is missing, load that plugin (see its README). After pstack is installed, run `/setup-pstack` once so pstack can choose models. Start the task with `/pm51-mode`.
