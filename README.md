# AI Configs

Reusable configurations for AI-first IDEs like **Cursor** and **Claude Code**, with a focus on **Go/Golang development**.

## Purpose

This repository stores and shares AI IDE configurations optimized for **Go backend development** with Domain-Driven Design (DDD), Test-Driven Development (TDD), and clean architecture patterns. While it includes frontend configurations for React/TypeScript, the primary emphasis is on building robust, well-tested Go services.

Copy these configurations to your projects to give AI assistants context about your architecture, coding standards, and workflows.

## What's Included

### AGENTS.md (Cross-Editor Baseline)

Project-root file for **any AI editor** (Zed, Windsurf, Copilot, Cursor, Aider, etc.). Provides condensed project context: setup commands, code style, architecture summary. Supported by 60k+ projects. See [agents.md](https://agents.md/).

- **Cursor**: Full experience via `.cursor/`; AGENTS.md supplements
- **Other editors**: AGENTS.md provides baseline; no `.cursor/` required for minimal setup

### Rules (`.cursor/rules/`)

Project conventions and coding standards in `.mdc` format:

| Rule | Description |
|------|-------------|
| `project-context.mdc` | Project overview, tech stack, structure (customize per project) |
| `architecture.mdc` | DDD and layered architecture patterns |
| `go-style-guide.mdc` | Go coding conventions |
| `frontend-patterns.mdc` | React/TypeScript guidelines |
| `go-testing-practices.mdc` | Go testing standards |
| `frontend-testing-practices.mdc` | Frontend testing standards |
| `authentication-security.mdc` | JWT and security patterns |
| `database-migrations.mdc` | Database and migration patterns |
| `agent-behavior.mdc` | General agent guidelines |
| `testing-agent.mdc` | Bug handling instructions |
| `test-driven-development.mdc` | TDD principles |
| `skills-index.mdc` | Quick reference for skills |
| `go-e2e-testing-standards.mdc` | E2E testing with BDD patterns |
| `http-rest-standards.mdc` | HTTP/REST standards |

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
├── AGENTS.md             # Cross-editor baseline (Zed, Windsurf, Copilot, etc.)
├── .cursor/
│   ├── agents/           # AI agent personas
│   │   ├── be-engineer.md
│   │   ├── fe-engineer.md
│   │   ├── product-owner.md
│   │   └── README.md
│   ├── rules/            # Project rules (.mdc)
│   │   ├── project-context.mdc
│   │   └── ...
│   └── skills/           # Reusable skills
│       ├── go-backend/SKILL.md
│       └── ...
├── setup-cursor.sh       # Full Cursor setup (Linux/macOS)
├── setup-cursor.ps1      # Full Cursor setup (Windows)
├── setup-ai.sh           # Editor-agnostic setup (Linux/macOS)
├── setup-ai.ps1          # Editor-agnostic setup (Windows)
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

Edit `.cursor/rules/project-context.mdc` for your specific project:

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

Instead of copying files to each project, use **git submodules** to include this repository in your projects. This keeps your configs version-controlled, makes updates easy, and works consistently across all platforms.

### Per-Project Setup

Add this repository as a git submodule in your project:

#### Linux/macOS/Windows (Git Bash)

```bash
cd /path/to/your-project

# Initialize git repository if not already initialized
git init

# Add ai-configs as a submodule
git submodule add https://github.com/your-org/ai-configs.git .cursor/ai-configs

# Create .cursor/rules directory
mkdir -p .cursor/rules

# Symlink shared rules (all except project-context), skills, and agents from submodule
cd .cursor/rules
for rule in ../ai-configs/.cursor/rules/*.mdc; do
  filename=$(basename "$rule")
  if [ "$filename" != "project-context.mdc" ]; then
    ln -s "$rule" .
  fi
done
cd ../..

# Symlink skills and agents directories
ln -s .cursor/ai-configs/.cursor/skills .cursor/skills
ln -s .cursor/ai-configs/.cursor/agents .cursor/agents

# Copy project-specific context (customize this file)
cp .cursor/ai-configs/.cursor/rules/project-context.mdc .cursor/rules/
```

#### Windows (PowerShell)

```powershell
cd C:\path\to\your-project

# Initialize git repository if not already initialized
git init

# Add ai-configs as a submodule
git submodule add https://github.com/your-org/ai-configs.git .cursor\ai-configs

# Create .cursor\rules directory
New-Item -ItemType Directory -Path ".cursor\rules" -Force

# Symlink shared rules (all except project-context)
Get-ChildItem ".cursor\ai-configs\.cursor\rules\*.mdc" | Where-Object { $_.Name -ne "project-context.mdc" } | ForEach-Object {
    New-Item -ItemType SymbolicLink -Path ".cursor\rules\$($_.Name)" -Target $_.FullName
}

# Symlink skills and agents
New-Item -ItemType SymbolicLink -Path ".cursor\skills" -Target ".cursor\ai-configs\.cursor\skills"
New-Item -ItemType SymbolicLink -Path ".cursor\agents" -Target ".cursor\ai-configs\.cursor\agents"

# Copy project-specific context (customize this file)
Copy-Item ".cursor\ai-configs\.cursor\rules\project-context.mdc" ".cursor\rules\"
```

> **Note**: Windows symlinks require either Administrator privileges or [Developer Mode](https://docs.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development) enabled.

### Cloning Projects with Submodules

When cloning a project that uses this submodule:

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/your-org/your-project.git

# Or if already cloned, initialize submodules
git submodule update --init --recursive
```

### What Gets Linked vs. Copied

| Type | Files | Reason |
|------|-------|--------|
| **Symlinked** (shared) | `rules/*.mdc` (except project-context), `skills/`, `agents/` | Generic, reusable across all projects |
| **Copied** (per-project) | `rules/project-context.mdc`, `AGENTS.md` | Must be customized for each project |
| **Submodule** | `.cursor/ai-configs/` | Version-controlled reference to this repository |

### Updating Shared Configs

When you want to update the submodule to the latest version:

```bash
cd /path/to/your-project

# Update submodule to latest commit
cd .cursor/ai-configs
git pull origin main
cd ../..

# Commit the submodule update
git add .cursor/ai-configs
git commit -m "Update ai-configs submodule"
```

Or update all submodules in your project:

```bash
git submodule update --remote --merge
```

### Setup Scripts

Use the included setup scripts for quick project configuration with git submodules:

| Script | Purpose |
|--------|---------|
| `setup-cursor.sh` / `setup-cursor.ps1` | Full Cursor setup: rules, skills, agents, AGENTS.md |
| `setup-ai.sh` / `setup-ai.ps1` | Editor-agnostic: AGENTS.md only (Zed, Windsurf, etc.) |

#### Linux/macOS (Full Cursor Setup)

```bash
cd /path/to/your-project

# Clone this repo first (if not already cloned)
git clone https://github.com/your-org/ai-configs.git /tmp/ai-configs

# Run Cursor setup (rules, skills, agents, AGENTS.md)
/tmp/ai-configs/setup-cursor.sh
```

#### Linux/macOS (Editor-Agnostic / Minimal)

```bash
/tmp/ai-configs/setup-ai.sh /path/to/your-project
# Optional: CREATE_RULES_LINK=1 for .rules symlink (Zed)
```

#### Windows (PowerShell as Administrator)

```powershell
# Full Cursor setup
C:\temp\ai-configs\setup-cursor.ps1 -ProjectPath "C:\path\to\your-project"

# Editor-agnostic (AGENTS.md only)
C:\temp\ai-configs\setup-ai.ps1 -ProjectPath "C:\path\to\your-project" -CreateRulesLink
```

#### Using Submodule URL

Override the submodule URL:

```bash
# Linux/macOS
AI_CONFIGS_REPO=https://github.com/your-org/ai-configs.git ./setup-cursor.sh

# Windows
$env:AI_CONFIGS_REPO = "https://github.com/your-org/ai-configs.git"
.\setup-cursor.ps1
```

## IDE Compatibility

### Cursor

Full experience via the `.cursor/` folder:
- Rules are automatically loaded from `.cursor/rules/`
- Agents are available via `@agent-name` references
- Skills are discoverable and usable by the AI
- AGENTS.md is also read for cross-editor baseline

### Other AI Editors (Zed, Windsurf, Copilot, Aider, etc.)

Baseline via **AGENTS.md** at project root:
- Auto-discovered by Zed, Windsurf, Copilot, and others
- Provides project overview, commands, code style, architecture summary
- For full rules and skills, run `setup-cursor.sh` (adds `.cursor/` structure)
- For minimal setup (AGENTS.md only): run `setup-ai.sh`

### Claude Code

Compatible patterns:
- AGENTS.md provides baseline context
- Rules can be consolidated into `CLAUDE.md`
- Skills follow the Agent Skills specification

## Customization Guide

### Files to Customize (Per Project)

- `project-context.mdc` - Always customize for your project
- `AGENTS.md` - Customize project overview and commands (cross-editor baseline)
- Agent files - Add project-specific context if needed

### Files That Are Generic (Reusable As-Is)

- Architecture patterns (`architecture.mdc`)
- Style guides (`go-style-guide.mdc`, `frontend-patterns.mdc`)
- Testing practices (`go-testing-practices.mdc`, `frontend-testing-practices.mdc`, `test-driven-development.mdc`)
- Security patterns (`authentication-security.mdc`)
- TDD workflow (`test-driven-development.mdc`)
- Skills (all `SKILL.md` files)

## License

MIT License - See [LICENSE](LICENSE) for details.
