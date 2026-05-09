# AI Project Configuration

> Cross-editor baseline for AI coding assistants. This repository also ships **`agents/`**, **`rules/`**, and **`skills/`** at the clone root for Cursor; copy those folders into a project’s **`.cursor/`** directory when you want rules, skills, and `@` agents there (see [CONFIGURATION_GUIDE.md](CONFIGURATION_GUIDE.md)).

## Project Overview

<!-- Customize: Replace with your project name and description. -->

This is a **[brief description]** built with **[key methodology/pattern]**. The system [primary functionality and domain].

## Setup & Commands

<!-- Customize: Update with your project's actual commands. -->

- **Install**: `go mod download` / `npm install` (or `pnpm install`)
- **Build**: `make build` / `go build ./...` / `npm run build`
- **Test**: `make test` / `go test ./...` / `npm test`
- **Lint**: `golangci-lint run` / `npm run lint`
- **Run**: `make run` / (document your primary run command here)

## Code Style & Architecture

- **DDD and layered architecture**: Handler → Service → Domain → Repository
- **TDD**: Write tests first, watch them fail, then implement
- **Go**: Idiomatic naming, `context` propagation, explicit errors, clear package boundaries
- **Frontend** (if applicable): React function components, TypeScript strict mode, consistent UI primitives
- **Database**: Versioned migrations; parameterized queries; transactions where appropriate

For full Cursor conventions after install, use the other **`.mdc` files in `rules/`** together with this **`AGENTS.md`** for project-specific facts (ports, layout, commands).

## Testing

- Unit tests: colocated `*_test.go` (or your stack’s convention); mocks where boundaries require them
- Integration tests: isolated environments (e.g. containers) when touching external systems
- E2E: dedicated suite folder and stable Given–When–Then style scenarios where you use BDD
- Coverage: Agree a target with the team (e.g. >80% on critical packages) and enforce in CI

## Using this file elsewhere

Copy or symlink `AGENTS.md` into another repository’s root so assistants pick up the same baseline. For Cursor-only depth (rules, skills, agents), copy **`agents/`**, **`rules/`**, and **`skills/`** from this pack into that repo’s `.cursor/` folder.
