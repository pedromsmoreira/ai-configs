# pm51stack

A Cursor plugin that runs one development workflow. `/pm51-mode` picks a phase. The skill that owns that phase does the work.

The workflow is a controller, not a fourth copy of someone else's skills.

| Source | Job in this workflow |
| --- | --- |
| [Matt Pocock's skills](https://github.com/mattpocock/skills) | Frame the decision, write the spec, split tracer-bullet slices, diagnose, review, hand off |
| [Addy Osmani's agent skills](https://github.com/addyosmani/agent-skills) | Hold the bar on security, observability, and launch |
| [pstack](https://github.com/cursor/plugins/tree/main/pstack) | Build a slice rigorously once it has an observable check, and choose models |
| This pack | Go, React, HTTP, migrations, tests, and git |

`/setup-pm51stack` installs the Matt Pocock and Addy Osmani skills this router knows how to call. Their text stays in those repositories. pstack stays a separate plugin. `/setup-pstack` chooses models. This plugin does not.

## Use it

1. Load this plugin (below).
2. Run `/setup-pm51stack` and choose **user profile** or **current project**. Then answer where this project's rules live, and whether the forge is **GitHub** or **GitLab**. The skill writes those answers to `.cursor/rules/pm51stack.mdc`. It asks you. The git remote is not an answer.
3. Run `/add-plugin pstack`, then `/setup-pstack` once.
4. Start the task with `/pm51-mode` and the outcome you want, including how you will know it worked.

```text
/pm51-mode the export writes duplicate rows when a retry lands mid-run. repro first, then fix and verify.
```

`/pm51-help` names the playbook and the first skill, and gives you the prompt to send. It does not start the work.

`@workflow-lead` is the same controller as a persona.

## What `/pm51-mode` does

It reads [skills/pm51-mode/routing.md](skills/pm51-mode/routing.md), opens one playbook, and copies that playbook's steps into the todo list before any edit. The shape comes from pstack: one controller, a playbook, and a check on the real surface. The phase order comes from Addy Osmani's define, plan, build, verify, review, and ship. The installed Addy Osmani skills are security, observability, and launch. Define and plan call the Matt Pocock skills. Build and verify call this pack, and pstack when the slice is non-trivial.

| Playbook | When |
| --- | --- |
| `question` | You want an answer from the code or the history, and no edit |
| `frame` | A person still has to decide, or a sketch or a cited fact would decide it |
| `specify` | The decisions are made and should become a spec and slices |
| `feature` | New or changed behavior |
| `refactor` | The behavior stays; the structure changes |
| `bug` | Something is broken, throwing, failing, or slow |
| `signal` | Logs, metrics, traces, or alerts |
| `review` | Judge the diff |
| `ship` | Commit, pull request or merge request, deploy, rollout, or a step only a person can click |
| `handoff` | Continue in a fresh agent |

A current failure takes `bug`. An open product decision takes `frame`. Work that crosses more than one module without a spec takes `specify` before `feature`.

On a non-trivial slice, `feature`, `refactor`, and `bug` hand the build to pstack's `/poteto-mode` when that plugin is installed. The check named in this mode is the proof pstack has to produce. Without pstack, the build is this pack's `tdd-workflow`.

## Load the plugin locally

From a checkout of this repository, link the plugin into Cursor's local plugin directory. Restart Cursor after the link, or reload the window.

```bash
mkdir -p ~/.cursor/plugins/local
ln -sfn "$(pwd)/plugins/pm51stack" ~/.cursor/plugins/local/pm51stack
```

The pack's `skills/setup-pm51stack` is the same installer. If you copied `skills/` into a project's `.cursor/`, either `/setup-pm51stack` runs that script.

## Publish it as a marketplace

This repository's [`.cursor-plugin/marketplace.json`](../../.cursor-plugin/marketplace.json) lists `pm51stack`. To submit, push the repository and open [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish). The manifest format is the [Cursor plugins reference](https://cursor.com/docs/reference/plugins).

## Make another workflow the same way

1. Add `.cursor-plugin/plugin.json` with a lowercase kebab-case `name`. Point `skills`, `agents`, and `rules` at directories inside the plugin.
2. Add one user-invoked skill as the controller (`disable-model-invocation: true`). It matches the task to a playbook and copies the numbered steps into the todo list before any edit.
3. Give each upstream source one job, and name the skill to read at each step. Install those skills. Leave their text in their repositories.
4. Add a help skill that returns the playbook and a prompt, and stops.
5. Add a marketplace entry when the plugin should be installable from the repository.
6. Run `bash plugins/pm51stack/scripts/plugin_test.sh` (or the equivalent check in your plugin) so the playbook files, the manifest, and the installed skill names stay in agreement.

## Layout

```text
plugins/pm51stack/
├── .cursor-plugin/plugin.json
├── agents/workflow-lead.md
├── rules/pm51-workflow.mdc
├── skills/pm51-mode/          # controller, routing, playbooks
├── skills/pm51-help/
└── skills/setup-pm51stack/
```

## Check

```bash
bash plugins/pm51stack/scripts/plugin_test.sh
bash skills/setup-pm51stack/scripts/shipped_test.sh
bash skills/setup-pm51stack/scripts/install_test.sh
```
