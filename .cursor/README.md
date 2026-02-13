# Cursor AI Configuration Guide

Welcome to the Cursor AI configuration system! This directory contains specialized AI agents, coding rules, and task-focused skills to help you build high-quality software efficiently.

## Cross-Editor Support (AGENTS.md)

For **any AI editor** (Zed, Windsurf, Copilot, etc.), a project-root `AGENTS.md` provides baseline context. Cursor gets the **full experience** via `.cursor/` (rules, skills, agents); other editors use AGENTS.md.

- **Cursor**: Full experience via `.cursor/`; AGENTS.md supplements
- **Zed, Windsurf, Copilot**: AGENTS.md at project root (auto-discovered)
- **Setup**: `setup-cursor.sh` copies AGENTS.md; `setup-ai.sh` for AGENTS.md-only setup

## What's Inside

```
.cursor/
├── agents/          # Specialized AI personas (BE, FE, Product Owner, DevOps)
├── rules/           # Coding standards and architectural patterns
├── skills/          # Task-focused, Agent Skills-compliant instructions
├── README.md        # This file - your quick start guide
└── CHECKLIST.md     # Setup checklist for new projects
```

## Quick Setup (4 Steps)

### 1. Copy Configuration Directory

Copy this `.cursor/` directory to your project root:

```bash
cp -r /path/to/ai-configs/.cursor /path/to/your-project/
```

### 2. Customize Project Context

Edit `.cursor/rules/project-context.mdc` and replace ALL `[PLACEHOLDER]` values:

- Project name and description
- Tech stack (backend, frontend, database)
- Project structure and key directories
- Design principles
- Domain concepts
- Ports and commands

**Important**: Remove the example section at the bottom after customizing.

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
skills-ref validate .cursor/skills
```

See [CHECKLIST.md](CHECKLIST.md) for the complete setup checklist.

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

- `project-context.mdc` - Project overview (customize this!)
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

Project root may also include `AGENTS.md` for cross-editor baseline (see above).

```
.cursor/
├── agents/
│   ├── README.md              # Agent documentation
│   ├── be-engineer.md         # Backend Engineer agent
│   ├── fe-engineer.md         # Frontend Engineer agent
│   ├── product-owner.md       # Product Owner agent
│   └── devops-engineer.md     # DevOps Engineer agent
│
├── rules/
│   ├── project-context.mdc    # ⚠️ CUSTOMIZE THIS FIRST
│   ├── architecture.mdc       # DDD patterns
│   ├── go-style-guide.mdc     # Go conventions
│   ├── frontend-patterns.mdc  # React/TS guidelines
│   ├── test-driven-development.mdc  # TDD principles
│   ├── api-versioning.mdc     # API versioning patterns
│   ├── skills-index.mdc       # Skills quick reference
│   └── ...                    # Additional rules
│
└── skills/
    ├── README.md              # Skills documentation
    ├── go-backend/            # Go backend development
    ├── frontend-react/        # React development
    ├── database-migrations/   # Schema migrations
    ├── testing/               # TDD and testing
    ├── rest-api-design/       # REST API design
    ├── http-rest-endpoints/   # HTTP handlers
    ├── tdd-workflow/          # Red-Green-Refactor
    ├── user-stories/          # Requirements and stories
    └── clean-code/            # Clean code principles
```

## Validation

### Pre-Commit Validation

Before committing changes, verify your configuration:

```bash
# Validate skills (if skills-ref installed)
make validate-skills

# Check project context is customized
grep -r "\[PLACEHOLDER\]" .cursor/rules/project-context.mdc
# Should return no results

# Verify all tests pass
make test  # or your project's test command
```

### Checklist

Use [CHECKLIST.md](CHECKLIST.md) to track your setup progress.

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

→ Ensure `project-context.mdc` is fully customized with your project details.

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
- **Setup Checklist**: See [CHECKLIST.md](CHECKLIST.md)
- **Project Context Template**: See [rules/project-context.mdc](rules/project-context.mdc)

## Next Steps

1. ✅ Read this guide
2. ⬜ Complete [CHECKLIST.md](CHECKLIST.md)
3. ⬜ Customize `project-context.mdc`
4. ⬜ Try referencing an agent: `@be-engineer Hello!`
5. ⬜ Start building with AI assistance

---

**Happy coding with AI! 🚀**
