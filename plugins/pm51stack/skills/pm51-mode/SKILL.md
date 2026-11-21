---
name: pm51-mode
description: Route a development task through one playbook. Matt Pocock skills own framing, specs, tickets, and building a spec that already has tickets. Addy Osmani skills own security, observability, and launch. This pack owns Go, React, tests, and git. The rules path and GitHub or GitLab come from .cursor/rules/pm51stack.mdc, and are asked when that file is missing. Use when the user runs /pm51-mode or asks to follow the pm51stack workflow.
disable-model-invocation: true
---

# pm51-mode

This is the controller. Three installed sources plus this pack each have one job. You pick the playbook, then you follow the skill that owns the step.

| Source | Owns | Hands onward |
| --- | --- | --- |
| Matt Pocock skills, installed by `/setup-pm51stack` | Framing a decision, domain terms, specs, tracer-bullet tickets, building that ticket graph, cited research, throwaway prototypes, bug diagnosis, two-axis review, the change-request body, human-only steps, handoff | A spec with tickets goes to `implement-spec`, which calls `tdd`. A slice with no ticket graph, a refactor, and a bug go to `tdd-workflow`. Go and React conventions go to this pack. |
| Addy Osmani skills, same installer | Security on a trust boundary, observability, deploy and rollback | The spec and the tickets go to the Matt Pocock skills. Red, green, refactor goes to `tdd-workflow`. |
| pstack, installed with `/add-plugin pstack` | Optional `how` and `why` answers on the question playbook | Product decisions, the spec, and the build stay with the Matt Pocock skills and this pack. |
| This pack | `go-backend`, `rest-api-design`, `frontend-react`, `database-migrations`, `tdd-workflow`, `testing`, `conventional-commits`, `git-commit` | The phase sequence stays with this mode. |

Upstream skill text stays in those installs. When a step names a skill, resolve its model in [Models](#models), then follow that `SKILL.md`. Write the step from the skill that ran.

## Start

1. Read `.cursor/rules/pm51stack.mdc` in the project root. It needs a `rules` path and a `forge` of `github` or `gitlab`, as [project-config.md](project-config.md) describes. When the file is missing or a line is invalid, follow project-config.md and write that file in this project, then continue. A user-profile skill install does not supply this file.
2. Read [models.md](models.md) and `~/.cursor/rules/pm51-models.mdc`. A missing or unreadable rule means every skill step stays in this chat.
3. Read [routing.md](routing.md) and match one playbook. Open its file under `playbooks/`.
4. Restate the user's goal, the problem, and the check that would prove the work. Use their words. Continue without waiting.
5. Copy the playbook's numbered steps into the todo list before any edit and before any task-specific todo. Copy the step text. A step you skip stays in the list with `skip:` and the reason.
6. Work the steps in order. When a step sends you to a different playbook, replace the todo list with that playbook's steps and say why in one sentence.

## While you work

- One playbook owns the task. A current failure takes the bug playbook. An open product decision takes the frame playbook. A missing spec for work that crosses more than one module takes the specify playbook before feature.
- When a step names a skill, resolve its model in [Models](#models), then follow the skill. When the step names a fallback because that skill is absent, use the fallback. When the step has no fallback and the skill is absent, stop. Say which command installs it: `/setup-pm51stack` for a Matt Pocock or Addy Osmani skill, `/add-plugin pstack` for a pstack skill, and this pack's `skills/` for a pack skill.
- `security-and-hardening` runs beside the active playbook when the change crosses a trust boundary: untrusted input, auth, sessions, secrets, a new package, or personal data. Its role is `security`.
- When a spec and its tickets already exist, read `implement-spec` and follow it once. When it names `tdd`, read that skill. The check from this mode is the proof. When `implement-spec` is absent, or the work is a refactor, a bug, or a slice with no ticket graph, `tdd-workflow` is the build. Say `/setup-pm51stack` when the spec exists and `implement-spec` is absent.
- The check is behavior on the real surface: a command the user could run, or a pass through the UI. Record the command and the result.
- Project conventions are the `.mdc` files in the `rules` directory from `.cursor/rules/pm51stack.mdc`. A pack skill that names `architecture.mdc` means that directory plus `/architecture.mdc`.
- Publish, review, and ship follow the forge section of [project-config.md](project-config.md). `github` is a pull request. `gitlab` is a merge request.

## Models

The parent chat keeps the model the user picked. It owns routing, the todo list, the reply, and the check.

Whenever a step says to read a skill and follow it:

1. Find the skill in [models.md](models.md) and read that role's line in `~/.cursor/rules/pm51-models.mdc`.
2. A missing rule, a missing line, `inherit-parent`, or `auto`: follow the skill in this chat. For `how` and `why`, leave pstack's own model rule alone.
3. A real slug: spawn one local Task subagent with `subagent_type: generalPurpose`, `environment: local`, and `model` set to that slug. The brief carries the user's goal, the check, the absolute path of that `SKILL.md`, and the instruction to follow that skill for this step only. Wait for it. Record the command it ran and the result. When `how` or `why` already spawns its own workers, leave that spawn alone and follow the skill in this chat.
4. When the Task tool rejects the slug, do not pass it again. Use the closest valid slug of the same family from the tool's message. When no same-family slug is listed, omit `model`. Say which you did.

A persona for the slice stays beside the skill. The role slug applies to the skill step. A persona keeps the model in its own file.

## Reply

Name the goal, the playbook, what a user or the next maintainer will notice, the evidence you ran, and what is still open. When a skill step ran on a subagent, name the role and the slug. Label a claim you did not run as an inference.
