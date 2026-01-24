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
├── setup-cursor.sh       # Setup script (Linux/macOS)
├── setup-cursor.ps1      # Setup script (Windows)
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

## Reusing Across Projects

Instead of copying files to each project, use **symlinks** to share configurations from a central location. This keeps your configs in sync and makes updates easy.

### One-Time Setup

Clone this repo to a central location:

```bash
# Linux/macOS
git clone https://github.com/your-org/ai-configs.git ~/ai-configs

# Windows (PowerShell)
git clone https://github.com/your-org/ai-configs.git C:\ai-configs
```

### Per-Project Setup

#### Linux/macOS

```bash
cd /path/to/your-project

# Create .cursor/rules directory
mkdir -p .cursor/rules

# Symlink shared rules (01-11), skills, and agents
for rule in ~/ai-configs/.cursor/rules/0[1-9]*.mdc ~/ai-configs/.cursor/rules/1*.mdc; do
  ln -s "$rule" .cursor/rules/
done
ln -s ~/ai-configs/.cursor/skills .cursor/skills
ln -s ~/ai-configs/.cursor/agents .cursor/agents

# Copy project-specific context (customize this file)
cp ~/ai-configs/.cursor/rules/00-project-context.mdc .cursor/rules/
```

#### Windows (PowerShell as Administrator)

```powershell
cd C:\path\to\your-project

# Create .cursor\rules directory
New-Item -ItemType Directory -Path ".cursor\rules" -Force

# Symlink shared rules (01-11)
Get-ChildItem "C:\ai-configs\.cursor\rules\*.mdc" | Where-Object { $_.Name -notmatch "^00-" } | ForEach-Object {
    New-Item -ItemType SymbolicLink -Path ".cursor\rules\$($_.Name)" -Target $_.FullName
}

# Symlink skills and agents
New-Item -ItemType SymbolicLink -Path ".cursor\skills" -Target "C:\ai-configs\.cursor\skills"
New-Item -ItemType SymbolicLink -Path ".cursor\agents" -Target "C:\ai-configs\.cursor\agents"

# Copy project-specific context (customize this file)
Copy-Item "C:\ai-configs\.cursor\rules\00-project-context.mdc" ".cursor\rules\"
```

> **Note**: Windows symlinks require either Administrator privileges or [Developer Mode](https://docs.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development) enabled.

### What Gets Linked vs. Copied

| Type | Files | Reason |
|------|-------|--------|
| **Symlinked** (shared) | `rules/01-11*.mdc`, `skills/`, `agents/` | Generic, reusable across all projects |
| **Copied** (per-project) | `rules/00-project-context.mdc` | Must be customized for each project |

### Updating Shared Configs

When you want to update all linked projects with the latest configs:

```bash
cd ~/ai-configs  # or C:\ai-configs on Windows
git pull
```

All symlinked projects automatically get the updates.

### Setup Scripts

Use the included setup scripts for quick project configuration:

#### Linux/macOS

```bash
cd /path/to/your-project
~/ai-configs/setup-cursor.sh
```

Or specify a project path:
```bash
~/ai-configs/setup-cursor.sh /path/to/your-project
```

#### Windows (PowerShell as Administrator)

```powershell
cd C:\path\to\your-project
C:\ai-configs\setup-cursor.ps1
```

Or specify a project path:
```powershell
C:\ai-configs\setup-cursor.ps1 -ProjectPath "C:\path\to\your-project"
```

#### Environment Variable

Override the default source location:

```bash
# Linux/macOS
AI_CONFIGS_PATH=/opt/ai-configs ./setup-cursor.sh

# Windows
$env:AI_CONFIGS_PATH = "D:\ai-configs"
.\setup-cursor.ps1
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
