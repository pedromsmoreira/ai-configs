# Routing

Match the first row that fits. The playbook file is `playbooks/<id>.md` next to this file. The first skill is the one you read before editing. Later steps in the playbook name the rest.

`security-and-hardening` is an extra pass on whichever row you land on when the change crosses a trust boundary.

| Situation | Playbook | First skill |
| --- | --- | --- |
| Read-only question about how something works | [question](playbooks/question.md) | `how` when pstack is installed. Otherwise answer from files you open. |
| Read-only question about why something was built this way | [question](playbooks/question.md) | `why` when pstack is installed. Otherwise answer from commits and the forge's change requests. |
| The ask is still a decision a person has to make | [frame](playbooks/frame.md) | `grilling` |
| The fight is a term, the glossary, or an ADR | [frame](playbooks/frame.md) | `domain-modeling` |
| The missing piece is a fact outside this working tree | [frame](playbooks/frame.md) | `research` |
| A throwaway sketch would settle the design or the UI | [frame](playbooks/frame.md) | `prototype` |
| The conversation is settled and should be published as a spec | [specify](playbooks/specify.md) | `to-spec` |
| A spec or plan should become buildable slices | [specify](playbooks/specify.md) | `to-tickets` |
| The work is bigger than one session and the destination is still foggy | [specify](playbooks/specify.md) | `wayfinder` |
| You are about to publish, and `docs/agents/issue-tracker.md` is missing | [specify](playbooks/specify.md) | `setup-matt-pocock-skills` |
| Something is broken, throwing, failing, or slow right now | [bug](playbooks/bug.md) | `diagnosing-bugs` |
| Add or repair logs, metrics, traces, or alerts | [signal](playbooks/signal.md) | `observability-and-instrumentation` |
| New behavior, and nothing is currently broken or waiting on a signal | [feature](playbooks/feature.md) | `poteto-mode` when pstack is installed. `tdd-workflow` when pstack is absent. |
| Behavior-preserving structure change | [refactor](playbooks/refactor.md) | `poteto-mode` when pstack is installed. `tdd-workflow` when pstack is absent. |
| Judge the diff since a commit, branch, tag, or merge-base | [review](playbooks/review.md) | `code-review` |
| Write the change request, commit, or prepare a deploy, rollout, or rollback. A pull request when `forge` is `github`, a merge request when `forge` is `gitlab` | [ship](playbooks/ship.md) | `pr` when `forge` is `github`. The forge section of [project-config.md](project-config.md) when `forge` is `gitlab` |
| A person must click a dashboard, paste a secret, or run a cutover | [ship](playbooks/ship.md) | `wizard` |
| This conversation has to continue in a fresh agent | [handoff](playbooks/handoff.md) | `handoff` |

## Build handoff

On `feature`, `refactor`, and `bug`, the build is `poteto-mode` when pstack is installed, and `tdd-workflow` when pstack is absent. Feature and refactor follow pstack's feature or refactoring playbook. Bug follows pstack's bug-fix playbook. The observable check from this mode is the proof the playbook produces.

`/setup-pstack` is the model choice. Run it once before the first rigorous build. This router does not assign models.

When pstack is absent, stay on `tdd-workflow`. Read a skill from the pack table below when that skill is installed.

## Pack skills inside a slice

| Slice | Pack skill |
| --- | --- |
| Go service, handler, domain, repository, gRPC | `go-backend` |
| HTTP URL, method, status, error, version | `rest-api-design` |
| React UI | `frontend-react` |
| PostgreSQL schema | `database-migrations` |
| Test shape, integration, regression | `testing` |
| Red, green, refactor | `tdd-workflow` |
| Commit message or change-request title | `conventional-commits` |
| Creating the commit | `git-commit` |

## Ship skills

`ship` also reads `shipping-and-launch` for a deploy, staged rollout, or rollback, and `conventional-commits` plus `git-commit` when the user asked for a commit.
