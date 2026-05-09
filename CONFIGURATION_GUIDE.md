# Cursor AI configuration guide

This pack provides **agents**, **rules**, and **skills** at the **repository root** (`agents/`, `rules/`, `skills/`). Cursor expects them under a project’s **`.cursor/`** directory, so install by copying or symlinking those three folders into `your-project/.cursor/`.

## Cross-editor support (`AGENTS.md`)

For **any AI editor** (Zed, Windsurf, Copilot, etc.), a project-root `AGENTS.md` provides baseline context. **Cursor** loads rules, skills, and agents from `.cursor/rules`, `.cursor/skills`, and `.cursor/agents` inside the workspace; keep **`AGENTS.md`** at the project root when you want the same baseline as other tools.

- **Cursor**: Install `agents/`, `rules/`, and `skills/` under `.cursor/` in the app repo; `AGENTS.md` at project root supplements
- **Zed, Windsurf, Copilot**: `AGENTS.md` at project root (auto-discovered)

## What’s in this repository

```
ai-configs/                 # clone root
├── agents/                 # AI personas (BE, FE, Product Owner, DevOps)
├── rules/                  # Coding standards (.mdc)
├── skills/                 # Agent Skills–compliant task guides
├── AGENTS.md               # Cross-editor baseline (optional in each app repo)
├── CONFIGURATION_GUIDE.md  # This file
└── CONFIGURATION_CHECKLIST.md
```

## Quick setup (four steps)

### 1. Install into a Cursor project

From this repository’s root (`<clone>/ai-configs`):

```bash
mkdir -p /path/to/your-project/.cursor
cp -r agents rules skills /path/to/your-project/.cursor/
```

On Windows, use `Copy-Item -Recurse` or directory junctions instead of `cp -r` if you prefer.

### 2. Customize `AGENTS.md`

In the **target** project root, edit **`AGENTS.md`** and replace placeholders with real values:

- Project name and description
- Install, build, test, lint, and run commands
- Ports, URLs, and how to run integration or E2E tests
- Domain concepts and stack notes

**Optional**: Adjust individual `.mdc` files under `.cursor/rules/` only where a rule still mentions example paths or placeholders that do not match your repo.

### 3. Update Documentation References

Review agent files and update any `docs/` path references to match your project:

- `docs/backlog/` - User stories and backlog
- `docs/frontend/` - Frontend architecture
- `docs/architecture/` - System architecture
- `docs/authentication/` - Auth flow documentation

### 4. Validate Configuration

If you have [skills-ref](https://agentskills.io/specification) installed:

```bash
make validate-skills
# or
skills-ref validate skills
```

See [CONFIGURATION_CHECKLIST.md](CONFIGURATION_CHECKLIST.md) for the complete setup checklist.

## Using Agents

Agents are specialized AI personas with domain expertise. Reference them in your prompts:

### Available Agents

- **`@be-engineer`** - Backend development (Go, gRPC, databases, DDD)
- **`@fe-engineer`** - Frontend development (React, TypeScript, Material-UI)
- **`@product-owner`** - Requirements, user stories, acceptance criteria
- **`@devops-engineer`** - CI/CD, Docker, deployment, infrastructure

### Example Usage

```
@be-engineer Implement a new user service with repository pattern

@fe-engineer Create a user profile page with Material-UI

@product-owner Write a user story for the checkout flow

@devops-engineer Set up GitHub Actions CI/CD pipeline
```

### When to Use Which Agent

| Task | Agent | Why |
|------|-------|-----|
| API endpoints, services, domain logic | `@be-engineer` | Backend expertise |
| React components, UI/UX | `@fe-engineer` | Frontend expertise |
| Requirements, user stories | `@product-owner` | Product focus |
| Dockerfiles, CI/CD, deployment | `@devops-engineer` | DevOps expertise |

See [agents/README.md](agents/README.md) for detailed agent documentation.

## Using Skills

Skills are task-focused instructions following the [Agent Skills specification](https://agentskills.io/specification). They tell AI assistants **what to do** and **when to use them**.

### Available Skills

| Skill | Use For |
|-------|---------|
| `go-backend` | Go services, gRPC, handlers, domain logic |
| `rest-api-design` | REST endpoint design, HTTP patterns |
| `http-rest-endpoints` | HTTP handlers and routing |
| `database-migrations` | PostgreSQL schema migrations |
| `testing` | TDD, unit tests, integration tests |
| `tdd-workflow` | Red-Green-Refactor cycle details |
| `frontend-react` | React components, TypeScript, Material-UI |
| `user-stories` | User stories, acceptance criteria |
| `clean-code` | Pragmatic coding standards |

### Quick Reference

See [rules/skills-index.mdc](rules/skills-index.mdc) for a task-to-skill mapping table.

Skills **complement** agents - they provide detailed "how-to" instructions while agents understand the context and architecture.

## Using Rules

Rules are coding standards and architectural patterns that AI assistants follow automatically.

### Always-Applied Rules

These rules are **always active** for all conversations:

- **`AGENTS.md`** — project overview, commands, ports (customize this first)
- `architecture.mdc` - DDD and layered architecture
- `go-style-guide.mdc` - Go coding conventions
- `frontend-patterns.mdc` - React/TypeScript guidelines
- `test-driven-development.mdc` - TDD principles
- `go-testing-practices.mdc` - Go testing standards
- `frontend-testing-practices.mdc` - Frontend testing
- `authentication-security.mdc` - JWT and security
- `database-migrations.mdc` - Database patterns
- `agent-behavior.mdc` - General agent guidelines
- `skills-index.mdc` - Skills quick reference
- And more...

### Agent-Requestable Rules

These rules are loaded on-demand when needed:

- `testing-agent.mdc` - Bug handling and testing focus

### Adding Custom Rules

Create new `.mdc` files in `.cursor/rules/` with YAML frontmatter:

```markdown
---
description: "Your rule description"
alwaysApply: true  # or false
globs:
  - "path/to/**/*.go"  # Optional file patterns
---

# Your Rule Content
...
```

## File Structure Overview

The **application** project root should include `AGENTS.md` when you want a cross-editor baseline (see above). After install, Cursor sees:

```
your-project/
├── AGENTS.md              # optional; copy from this pack’s AGENTS.md
└── .cursor/
    ├── agents/
    │   ├── README.md
    │   ├── be-engineer.md
    │   ├── fe-engineer.md
    │   ├── product-owner.md
    │   └── devops-engineer.md
    ├── rules/
    │   ├── architecture.mdc
    │   ├── go-style-guide.mdc
    │   └── ...
    └── skills/
        ├── README.md
        ├── go-backend/
        └── ...
```

## Validation

### Pre-Commit Validation

Before committing changes, verify your configuration:

```bash
# Validate skills (if skills-ref installed)
make validate-skills

# Check AGENTS.md is customized
grep "\[PLACEHOLDER\]" AGENTS.md
# Should return no results

# Verify all tests pass
make test  # or your project's test command
```

### Checklist

Use [CONFIGURATION_CHECKLIST.md](CONFIGURATION_CHECKLIST.md) to track your setup progress.

## Common Workflows

### Feature Development

```
1. @product-owner Create a user story for [feature]
2. @be-engineer Implement the [feature] backend API
3. @fe-engineer Build the [feature] UI component
4. @devops-engineer Add [feature] to deployment pipeline
5. @product-owner Review the [feature] implementation
```

### Bug Fix

```
1. @product-owner Document the [bug] and acceptance criteria
2. @be-engineer Fix the [bug] with TDD approach
3. @fe-engineer Fix the UI [bug] with tests
4. @product-owner Verify the [bug] is fixed
```

### Infrastructure Setup

```
1. @devops-engineer Create Dockerfile for backend service
2. @devops-engineer Set up GitHub Actions CI/CD
3. @devops-engineer Configure Docker Compose for local dev
4. @be-engineer Update database migration workflow for CI
```

## Tips for Success

### 1. Be Specific

```
❌ "Help me with the user page"
✅ "@fe-engineer Create a user profile page with Material-UI that displays user info"
```

### 2. Use the Right Agent

```
❌ "@fe-engineer Write a database migration"
✅ "@be-engineer Create a migration to add the notifications table"
```

### 3. Chain Agents

```
1. "@product-owner Define requirements for user notifications"
2. "@be-engineer Implement notification backend service"
3. "@fe-engineer Create notification UI components"
4. "@devops-engineer Add notification service to Docker Compose"
```

### 4. Reference Context

```
"@be-engineer Looking at USER_STORY_005.md, implement the API"
```

### 5. Trust Agent Expertise

Let agents determine **how** to implement. Focus on **what** and **why**:

```
✅ "@be-engineer Create an endpoint to update user profiles"
❌ "@be-engineer Update line 42 in user_handler.go to add..."
```

## Troubleshooting

### "Agent doesn't understand my project"

→ Ensure **`AGENTS.md`** fully describes your project (commands, ports, structure).

### "Skills aren't activating"

→ Check that skill names in frontmatter match directory names exactly.

### "Agents suggest wrong file paths"

→ Update documentation references in agent files to match your project structure.

### "Tests failing after AI changes"

→ All agents follow TDD. Review test output and ask agent to fix issues.

## Advanced Usage

### Custom Skills

Create project-specific skills in `.cursor/skills/`:

```
.cursor/skills/
└── my-custom-skill/
    └── SKILL.md
```

Follow the [Agent Skills specification](https://agentskills.io/specification).

### Custom Agents

Create specialized agents in `.cursor/agents/`:

```markdown
---
name: my-agent
model: default
---

# My Custom Agent

## Role
...
```

### Rule Priorities

Rules in `.cursor/rules/` are loaded alphabetically. Use prefixes if order matters.

## Getting Help

- **Agent Documentation**: See [agents/README.md](agents/README.md)
- **Skills Documentation**: See [skills/README.md](skills/README.md)
- **Setup checklist**: See [CONFIGURATION_CHECKLIST.md](CONFIGURATION_CHECKLIST.md)
- **Project baseline**: See [AGENTS.md](AGENTS.md) in this pack (copy into the app repo root)

## Next Steps

1. ✅ Read this guide
2. ⬜ Complete [CONFIGURATION_CHECKLIST.md](CONFIGURATION_CHECKLIST.md)
3. ⬜ Customize `AGENTS.md` in the target project
4. ⬜ Try referencing an agent: `@be-engineer Hello!`
5. ⬜ Start building with AI assistance

---

**Happy coding with AI! 🚀**
