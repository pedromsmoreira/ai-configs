---
name: pm51-mode
description: Route a development task through one playbook. Matt Pocock skills own framing, specs, and tickets. Addy Osmani skills own security, observability, and launch. pstack builds a non-trivial slice once it has a check. This pack owns Go, React, tests, and git. The rules path and GitHub or GitLab come from .cursor/rules/pm51stack.mdc, and are asked when that file is missing. Use when the user runs /pm51-mode or asks to follow the pm51stack workflow.
disable-model-invocation: true
---

# pm51-mode

This is the controller. Three installed sources plus this pack each have one job. You pick the playbook, then you follow the skill that owns the step.

| Source | Owns | Hands onward |
| --- | --- | --- |
| Matt Pocock skills, installed by `/setup-pm51stack` | Framing a decision, domain terms, specs, tracer-bullet tickets, cited research, throwaway prototypes, bug diagnosis, two-axis review, the change-request body, human-only steps, handoff | The build goes to pstack or `tdd-workflow`. Model choice goes to `/setup-pstack`. Go and React conventions go to this pack. |
| Addy Osmani skills, same installer | Security on a trust boundary, observability, deploy and rollback | The spec and the tickets go to the Matt Pocock skills. Red, green, refactor goes to `tdd-workflow`. |
| pstack, installed with `/add-plugin pstack` | A rigorous build or diagnosis once the slice and its check are named. Model choice via `/setup-pstack` | Product decisions and the spec stay with the Matt Pocock skills. |
| This pack | `go-backend`, `rest-api-design`, `frontend-react`, `database-migrations`, `tdd-workflow`, `testing`, `conventional-commits`, `git-commit` | The phase sequence stays with this mode. |

Upstream skill text stays in those installs. When a step names a skill, read that `SKILL.md` and follow it. Write the step from the skill you just read.

## Start

1. Read `.cursor/rules/pm51stack.mdc` in the project root. It needs a `rules` path and a `forge` of `github` or `gitlab`, as [project-config.md](project-config.md) describes. When the file is missing or a line is invalid, follow project-config.md and write that file in this project, then continue. A user-profile skill install does not supply this file.
2. Read [routing.md](routing.md) and match one playbook. Open its file under `playbooks/`.
3. Restate the user's goal, the problem, and the check that would prove the work. Use their words. Continue without waiting.
4. Copy the playbook's numbered steps into the todo list before any edit and before any task-specific todo. Copy the step text. A step you skip stays in the list with `skip:` and the reason.
5. Work the steps in order. When a step sends you to a different playbook, replace the todo list with that playbook's steps and say why in one sentence.

## While you work

- One playbook owns the task. A current failure takes the bug playbook. An open product decision takes the frame playbook. A missing spec for work that crosses more than one module takes the specify playbook before feature.
- Read the named skill in full before acting on that step. When the step names a fallback because that skill is absent, use the fallback. When the step has no fallback and the skill is absent, stop. Say which command installs it: `/setup-pm51stack` for a Matt Pocock or Addy Osmani skill, `/add-plugin pstack` for a pstack skill, and this pack's `skills/` for a pack skill.
- `security-and-hardening` runs beside the active playbook when the change crosses a trust boundary: untrusted input, auth, sessions, secrets, a new package, or personal data.
- This mode does not pick models. After pstack is installed, `/setup-pstack` does that once.
- When pstack is installed, the feature, refactor, and bug builds read `poteto-mode` and follow the pstack playbook the step names. The check from this mode is the proof the playbook produces. When pstack is absent, that build is `tdd-workflow`. One of those two runs.
- The check is behavior on the real surface: a command the user could run, or a pass through the UI. Record the command and the result.
- Project conventions are the `.mdc` files in the `rules` directory from `.cursor/rules/pm51stack.mdc`. A pack skill that names `architecture.mdc` means that directory plus `/architecture.mdc`.
- Publish, review, and ship follow the forge section of [project-config.md](project-config.md). `github` is a pull request. `gitlab` is a merge request.

## Reply

Name the goal, the playbook, what a user or the next maintainer will notice, the evidence you ran, and what is still open. Label a claim you did not run as an inference.
