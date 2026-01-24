# AI Configs

Reusable configurations for AI-first IDEs like **Cursor** and **Claude Code**, with a focus on **Go/Golang development**.

## Purpose

This repository stores and shares AI IDE configurations optimized for **Go backend development** with Domain-Driven Design (DDD), Test-Driven Development (TDD), and clean architecture patterns. While it includes frontend configurations for React/TypeScript, the primary emphasis is on building robust, well-tested Go services.

Copy these configurations to your projects to give AI assistants context about your architecture, coding standards, and workflows.

## What's Included

### Rules (`.cursor/rules/`)

Project conventions and coding standards in `.mdc` format:

| Rule | Description |
|------|-------------|
| `00-project-context.mdc` | Project overview, tech stack, structure (customize per project) |
| `01-architecture.mdc` | DDD and layered architecture patterns |
| `02-go-style-guide.mdc` | Go coding conventions |
| `03-frontend-patterns.mdc` | React/TypeScript guidelines |
| `04a-go-testing-practices.mdc` | Go testing standards |
| `04b-frontend-testing-practices.mdc` | Frontend testing standards |
| `05-authentication-security.mdc` | JWT and security patterns |
| `06-database-migrations.mdc` | Database and migration patterns |
| `07-agent-behavior.mdc` | General agent guidelines |
| `08-testing-agent.mdc` | Bug handling instructions |
| `09-test-driven-development.mdc` | TDD principles |
| `10-skills-index.mdc` | Quick reference for skills |
| `11-go-e2e-testing-standards.mdc` | E2E testing with BDD patterns |

### Agents (`.cursor/agents/`)

Specialized AI personas with domain expertise:

- **`be-engineer.md`** - Backend Engineer: Go services, gRPC, database, DDD
- **`fe-engineer.md`** - Frontend Engineer: React, TypeScript, Material-UI
- **`product-owner.md`** - Product Owner: User stories, requirements, acceptance criteria

### Skills (`.cursor/skills/`)

Task-focused instructions following the [Agent Skills](https://agentskills.io) specification:

- `go-backend/` - Backend API development
- `frontend-react/` - React component development
- `database-migrations/` - Schema migrations
- `testing/` - Test-driven development
- `tdd-workflow/` - Red-Green-Refactor cycle
- `user-stories/` - Requirements and acceptance criteria
- `clean-code/` - Pragmatic coding standards

## Directory Structure

```
ai-configs/
├── .cursor/
│   ├── agents/           # AI agent personas
│   │   ├── be-engineer.md
│   │   ├── fe-engineer.md
│   │   ├── product-owner.md
│   │   └── README.md
│   ├── rules/            # Project rules (.mdc)
│   │   ├── 00-project-context.mdc
│   │   └── ...
│   └── skills/           # Reusable skills
│       ├── go-backend/SKILL.md
│       └── ...
├── LICENSE
└── README.md
```

## How to Use

### 1. Copy to Your Project

Copy the `.cursor/` folder to your project root:

```bash
cp -r .cursor/ /path/to/your/project/
```

### 2. Customize Project Context

Edit `.cursor/rules/00-project-context.mdc` for your specific project:

- Project name and overview
- Tech stack details
- Directory structure
- Ports and commands
- Domain concepts

### 3. Reference Agents in Cursor

Use agents in your prompts:

```
@be-engineer Implement a new user service
@fe-engineer Create a dashboard component
@product-owner Write a user story for notifications
```

## IDE Compatibility

### Cursor

Native support via the `.cursor/` folder:
- Rules are automatically loaded from `.cursor/rules/`
- Agents are available via `@agent-name` references
- Skills are discoverable and usable by the AI

### Claude Code

Compatible patterns:
- Agent files can be adapted to `AGENTS.md` format
- Rules can be consolidated into `CLAUDE.md`
- Skills follow the Agent Skills specification

## Customization Guide

### Files to Customize (Per Project)

- `00-project-context.mdc` - Always customize for your project
- Agent files - Add project-specific context if needed

### Files That Are Generic (Reusable As-Is)

- Architecture patterns (`01-architecture.mdc`)
- Style guides (`02-go-style-guide.mdc`, `03-frontend-patterns.mdc`)
- Testing practices (`04a-*`, `04b-*`, `09-*`)
- Security patterns (`05-authentication-security.mdc`)
- TDD workflow (`09-test-driven-development.mdc`)
- Skills (all `SKILL.md` files)

## License

MIT License - See [LICENSE](LICENSE) for details.
