# Models

Each skill named in [routing.md](routing.md) belongs to one role. `/pm51-mode` reads this file, then reads `~/.cursor/rules/pm51-models.mdc` for that role's slug. `/setup-pm51stack` writes the rule. This file does not name slugs.

A missing rule, a missing line, `inherit-parent`, or `auto` means follow the skill in the parent chat.

`how` and `why` stay on the question playbook. When this controller runs them, use the `question` line. When that line is `inherit-parent` or `auto`, leave pstack's own model rule alone. When `how` or `why` already spawns its own workers, leave that spawn alone.

| Role | Skills |
| --- | --- |
| question | `how`, `why` |
| frame | `grilling`, `domain-modeling`, `research`, `prototype` |
| specify | `to-spec`, `to-tickets`, `wayfinder`, `setup-matt-pocock-skills` |
| build | `implement-spec`, `tdd`, `tdd-workflow`, `go-backend`, `rest-api-design`, `frontend-react`, `database-migrations`, `testing` |
| bug | `diagnosing-bugs` |
| signal | `observability-and-instrumentation` |
| review | `code-review` |
| security | `security-and-hardening` |
| ship | `pr`, `conventional-commits`, `git-commit`, `shipping-and-launch`, `wizard` |
| handoff | `handoff` |

Feature and refactor share `build`. The fix after `diagnosing-bugs` uses `build`. `security-and-hardening` is the sidecar pass.
