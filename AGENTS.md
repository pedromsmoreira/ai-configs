# AI Project Configuration

> Cross-editor baseline for AI coding assistants. For full rules, skills, and agents (Cursor), see `.cursor/`.

## Project Overview

<!-- Customize: Replace with your project name and description. See .cursor/rules/project-context.mdc for single source of truth. -->

This is a **[brief description]** built with **[key methodology/pattern]**. The system [primary functionality and domain].

## Setup & Commands

<!-- Customize: Update with your project's actual commands. -->

- **Install**: `go mod download` / `npm install` (or `pnpm install`)
- **Build**: `make build` / `go build ./...` / `npm run build`
- **Test**: `make test` / `go test ./...` / `npm test`
- **Lint**: `golangci-lint run` / `npm run lint`
- **Run**: `make run` / (see project-context.mdc for run command)

## Code Style & Architecture

- **DDD and layered architecture**: Handler → Service → Domain → Repository
- **TDD required**: Write tests first, watch them fail, then implement
- **Go**: Follow go-style-guide (naming, context, error handling, domain patterns)
- **Frontend**: React functional components, TypeScript strict, Material-UI
- **Database**: Migrations with golang-migrate; parameterized queries; transactions

See `.cursor/rules/` for full conventions (architecture.mdc, go-style-guide.mdc, frontend-patterns.mdc, etc.).

## Testing

- Unit tests: `*_test.go` next to source; use testify, gomock for mocks
- Integration tests: testcontainers in `internal/`
- E2E tests: `test/` folder (NOT `test/integration/`), BDD Given-When-Then patterns
- Coverage: Maintain >80%

## Full Configuration

- **Rules**: `.cursor/rules/` — Architecture, style guides, testing, auth, migrations
- **Skills**: `.cursor/skills/` — Agent Skills spec (go-backend, testing, frontend-react, etc.)
- **Agents**: `.cursor/agents/` — Personas: Backend Engineer, Frontend Engineer, Product Owner, DevOps

For Cursor: Full experience via `.cursor/`. For other editors (Zed, Windsurf, Copilot): This file provides baseline context.
