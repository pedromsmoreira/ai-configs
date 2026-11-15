# Agent Skills

Agent Skills are task-focused instruction sets that follow the [Agent Skills specification](https://agentskills.io/specification). Each skill defines **what it does** and **when to use it**, so agents can activate the right skill for a given task.

Skills in this project **complement** the existing Cursor agents (`../agents/`) and **reference** `../rules/` for full guidance. `../rules/skills-index.mdc` maps tasks to skills and lists the greenfield and brownfield workflows.

Most skills set `disable-model-invocation: true` and load when you name them, for example `/go-backend`. `diagnosing-bugs`, `conventional-commits`, `to-prd`, and `to-issues` omit the flag, so Cursor can invoke them from the task.

## Skills

### Stack

| Skill | Purpose |
|-------|---------|
| **go-backend** | Go services, gRPC, domain logic, handlers, services, repositories, Protocol Buffers |
| **rest-api-design** | REST and HTTP endpoints design: URL structure, HTTP methods, status codes, request/response patterns, error handling, versioning |
| **database-migrations** | PostgreSQL schema migrations with golang-migrate (tables, columns, indexes, up/down, expand/contract renames) |
| **frontend-react** | React 18+, TypeScript, Material-UI, Zustand, React Query, REST API integration |
| **testing** | Unit tests, integration tests with testcontainers, mocks, regression tests |
| **tdd-workflow** | Red-green-refactor walkthrough with examples, behind the `test-driven-development` rule |
| **clean-code** | Pragmatic coding standards |

### Planning and design

| Skill | Purpose |
|-------|---------|
| **grilling** | Interview that walks every open design decision, one recommended answer each |
| **domain-modeling** | Sharpen domain terms in `GLOSSARY.md` and record hard-to-reverse decisions in `docs/adr/` |
| **user-stories** | User stories, acceptance criteria, backlog items, requirements, and review |
| **to-prd** | Turn the conversation into a PRD and publish it as a GitHub issue |
| **to-issues** | Break a PRD or plan into tracer-bullet GitHub issues with blocking edges |

### Debugging, review, and delivery

| Skill | Purpose |
|-------|---------|
| **diagnosing-bugs** | Build a red feedback loop, minimise, test ranked hypotheses, fix test-first |
| **code-review** | Review a diff against documented standards and against its spec, as two separate reports |
| **conventional-commits** | Commit messages and PR/squash titles per Conventional Commits |
| **git-commit** | Stage and create commits safely |
| **pr** | PR body template: diagram, before/after evidence, reversibility, blast radius |
| **wizard** | Generate a bash script that walks a human through steps the agent cannot do |
| **handoff** | Compact the conversation into a handoff document for a fresh agent |

### Machine setup

| Skill | Purpose |
|-------|---------|
| **setup-pm51stack** | Install Matt Pocock and Addy Osmani skills with `npx skills`, then install pstack in Cursor. When to use each installed skill: [decision-graph.md](setup-pm51stack/decision-graph.md) |

### Production readiness

| Skill | Purpose |
|-------|---------|
| **security-and-hardening** | Threat model, OWASP checks, secrets, supply chain |
| **observability-and-instrumentation** | Structured logs, correlation ids, RED metrics, alerts, runbooks |
| **shipping-and-launch** | Pre-launch gate, feature flags, staged rollout, rollback plan |

Third-party skills and their licenses are listed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Validation

If you have the [skills-ref](https://agentskills.io/specification) tool:

```bash
skills-ref validate .
```

### Manual checks

- **`name`** in each `SKILL.md` frontmatter must **exactly match** the parent directory name.
- **`description`** must be 1–1024 characters and describe both what the skill does and when to use it.
- **`name`** must use only lowercase letters, numbers, and hyphens; no leading/trailing hyphens; no consecutive hyphens (`--`).
- Every skill directory appears in this README and in `../rules/skills-index.mdc`.

## Structure

Each skill is a directory with at least `SKILL.md`. Optional `references/`, `scripts/`, or supporting `.md` files sit beside it and are linked from `SKILL.md` by relative path.
