# Project configuration

`.cursor/rules/pm51stack.mdc` is an always-applied Cursor rule. It records two answers: where that project's standards live, and whether the forge is GitHub or GitLab. Cursor loads it on every session in the project, the same way pstack loads `~/.cursor/rules/pstack-models.mdc` for model choices. pstack's file is per user. This file is per project.

The `rules` line is the standards directory. This rule is the record of the answers. It is not a coding standard. When the standards directory is `.cursor/rules`, skip `pm51stack.mdc` while reading standards.

The workflow asks the user. The git remote is not an answer. A CI file is not an answer. A directory that happens to exist is not an answer. `.cursor/rules` is an answer only when the user chooses it.

A user-profile install writes `rules/pm51stack.mdc` in the user profile's existing `rules` directory. That directory is already inside the Cursor user directory. Do not create `.cursor/rules` inside the user profile. A current-project install writes `.cursor/rules/pm51stack.mdc` from the project root. When `.cursor/pm51stack.md` exists and the rule does not, copy its `rules` and `forge` lines into the rule and delete `.cursor/pm51stack.md`. Tell the user. When both the project file and the user-profile file exist, the project file wins.

`docs/agents/issue-tracker.md` is the Matt Pocock tracker file. It stays a separate file. The `forge` line is what you tell `setup-matt-pocock-skills` when that skill asks.

## When to ask

`/setup-pm51stack` asks every time. When `.cursor/rules/pm51stack.mdc` already exists, show the two lines, then ask with AskQuestion. Offer only:

- Keep these answers
- Answer again

Keep leaves the file as it is. Answer again asks the two questions below.

`/pm51-mode` reads `.cursor/rules/pm51stack.mdc` in the project root. When that file is missing, it reads `rules/pm51stack.mdc` in the Cursor user profile, the directory that already contains `rules`. A `.cursor` directory inside that profile is not the profile. A valid file is used as written. When both files are missing, or a line fails the checks below, ask the two questions, write `.cursor/rules/pm51stack.mdc` in the project root, then continue the task.

When the user has already named the rules path and the forge in this conversation, confirm the two lines and write them. Ask only for the one they have not named.

Use AskQuestion when it is available. Wait for the answer before you write the file.

## Rules question

Offer only these options.

- `.cursor/rules`
- `rules`
- A path I will type

The third option asks for the path in the next message. The path is relative to the project root. It has no `..` and no leading slash. A path that fails that check is asked again.

## Forge question

Offer only these options.

- GitHub
- GitLab

Record `github` or `gitlab`.

## File

The file has exactly this shape. `<path>` is the standards directory. `<forge>` is `github` or `gitlab`. `alwaysApply` stays true.

`/setup-pm51stack` writes it by running `scripts/project_config.sh` in the setup skill. Pass `user` or `project`, the rules path, and `github` or `gitlab`. Do not write the file by hand.

`user` writes `<profile>/rules/pm51stack.mdc`. `<profile>` is the Cursor user directory, the one that already contains `rules`. `project` writes `<project>/.cursor/rules/pm51stack.mdc`. `/pm51-mode` creates the project file when it has to write one.

```markdown
---
description: pm51stack project choices for the standards directory and the forge
alwaysApply: true
---
# pm51stack project

rules: <path>
forge: <forge>

Standards are the other .mdc files in the rules directory. This file records the choices.
forge github: open a pull request on GitHub.
forge gitlab: open a merge request on GitLab.
```

Show the user the `rules` and `forge` lines after you write them.

A valid file has `alwaysApply: true`, a `rules` line, and a `forge` line. `rules` matches a relative path with no `..`. The forge line is `forge: github` or `forge: gitlab`. Anything else is asked again.

## How a playbook uses it

Rules. Project conventions are the `.mdc` files in the `rules` directory. A pack skill that names `architecture.mdc` means `<rules>/architecture.mdc`. Read those files from the configured directory. When that directory is missing, say so and ask the rules question again. Leave the `forge` line as the user set it.

Forge `github`. A reviewable change request is a pull request. History and review threads come from GitHub. The `pr` skill writes the pull request body. When `setup-matt-pocock-skills` asks for a tracker, the answer is GitHub.

Forge `gitlab`. A reviewable change request is a merge request. History and review threads come from GitLab, through `glab` when it is installed. The `pr` skill describes a GitHub pull request, so on GitLab write the merge request body with the goal, the check, and the result, and open it with `glab` when the user asked to open it. When `setup-matt-pocock-skills` offers GitLab, choose it. When it offers only GitHub or local files, publish the spec and tickets as local files and still open merge requests on GitLab. Say which you did.
