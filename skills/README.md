# Agent skills

These skills follow the [Agent Skills specification](https://agentskills.io/specification). Each skill says what it does and when to use it.

Skills in this pack complement the agents in `../agents/` and point at `../rules/`. [`../rules/skills-index.mdc`](../rules/skills-index.mdc) maps tasks to the skills that ship here.

Matt Pocock skills and Addy Osmani skills are not in this pack. [`setup-pm51stack`](setup-pm51stack/SKILL.md) installs them. When to use each installed skill is [decision-graph.md](setup-pm51stack/decision-graph.md).

`disable-model-invocation: true` means the skill loads when you name it, for example `/go-backend`. `conventional-commits` omits that flag, so Cursor can invoke it from the task.

## Go

| Skill | Purpose |
|-------|---------|
| `go-backend` | Go services, gRPC, domain logic, handlers, services, repositories, and Protocol Buffers |
| `rest-api-design` | REST and HTTP endpoint design. URLs, methods, status codes, request and response shapes, errors, and versioning |
| `database-migrations` | PostgreSQL schema migrations with golang-migrate. The expand and contract steps are adapted from addyosmani/agent-skills. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). |

## React

| Skill | Purpose |
|-------|---------|
| `frontend-react` | React 18 or later, TypeScript, Material UI, Zustand, React Query, and REST calls |

## Testing

| Skill | Purpose |
|-------|---------|
| `testing` | Unit tests, integration tests with testcontainers, mocks, and regression tests |
| `tdd-workflow` | Red, green, refactor, with examples. The rule behind it is `test-driven-development`. |

## Git

| Skill | Purpose |
|-------|---------|
| `conventional-commits` | Commit messages and pull-request titles per Conventional Commits |
| `git-commit` | Stage files and create commits |

## Setup

| Skill | Purpose |
|-------|---------|
| `setup-pm51stack` | Install Matt Pocock skills and Addy Osmani skills with `npx skills`, then tell you how to add the pstack plugin |

## Validation

If you have the [skills-ref](https://agentskills.io/specification) tool, from this directory run:

```bash
skills-ref validate .
```

From the repository root, run:

```bash
bash skills/setup-pm51stack/scripts/shipped_test.sh
bash skills/setup-pm51stack/scripts/install_test.sh
```

### Manual checks

- `name` in each `SKILL.md` frontmatter matches the parent directory name.
- `description` is 1 to 1024 characters and says what the skill does and when to use it.
- `name` uses only lowercase letters, numbers, and hyphens. It has no leading hyphen, no trailing hyphen, and no doubled hyphen.
- Every skill directory is listed in this README and in `../rules/skills-index.mdc`.

## Structure

Each skill is a directory with at least `SKILL.md`. Optional `references/`, `scripts/`, or supporting `.md` files sit beside it and are linked from `SKILL.md` by relative path.
