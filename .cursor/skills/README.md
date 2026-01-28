# Agent Skills

Agent Skills are task-focused instruction sets that follow the [Agent Skills specification](https://agentskills.io/specification). Each skill defines **what it does** and **when to use it**, so agents can activate the right skill for a given task.

Skills in this project **complement** the existing Cursor agents (`.cursor/agents/`) and **reference** `.cursor/rules/` for full guidance. Each skill is thin: "when to use" plus pointers to rules and agents; rules and agents remain the single source of truth.

## Skills

| Skill | Purpose |
|-------|---------|
| **go-backend** | Go services, gRPC, domain logic, handlers, services, repositories, Protocol Buffers |
| **rest-api-design** | REST and HTTP endpoints design—URL structure, HTTP methods, status codes, request/response patterns, error handling, versioning |
| **database-migrations** | PostgreSQL schema migrations with golang-migrate (tables, columns, indexes, up/down) |
| **testing** | TDD, unit tests, integration tests with testcontainers, mocks, regression tests |
| **frontend-react** | React 18+, TypeScript, Material-UI, Zustand, React Query, REST API integration |
| **user-stories** | User stories, acceptance criteria, backlog items, requirements, and review |

## Validation

### With skills-ref (when installed)

If you have the [skills-ref](https://agentskills.io/specification) tool (or run `make validate-skills` when it is installed):

```bash
skills-ref validate .cursor/skills/go-backend
skills-ref validate .cursor/skills/rest-api-design
skills-ref validate .cursor/skills/database-migrations
skills-ref validate .cursor/skills/testing
skills-ref validate .cursor/skills/frontend-react
skills-ref validate .cursor/skills/user-stories
```

Or validate all at once (if your skills-ref supports a directory):

```bash
skills-ref validate .cursor/skills
```

### Manual checks

- **`name`** in each `SKILL.md` frontmatter must **exactly match** the parent directory name.
- **`description`** must be 1–1024 characters and describe both what the skill does and when to use it.
- **`name`** must use only lowercase letters, numbers, and hyphens; no leading/trailing hyphens; no consecutive hyphens (`--`).

## Structure

Each skill is a directory with at least `SKILL.md`:

```
.cursor/skills/
├── README.md           # This file
├── go-backend/
│   └── SKILL.md
├── rest-api-design/
│   └── SKILL.md
├── database-migrations/
│   └── SKILL.md
├── testing/
│   └── SKILL.md
├── frontend-react/
│   └── SKILL.md
└── user-stories/
    └── SKILL.md
```

Optional `references/`, `scripts/`, or `assets/` may be added per skill when needed.
