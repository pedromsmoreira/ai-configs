---
name: testing
description: Implements Test-Driven Development for this project—unit tests, integration tests with testcontainers, mocks, and regression tests. Use when writing or fixing tests, reproducing bugs with tests, or improving coverage.
version: 1.0
---

# Testing Skill

## When to use

- Writing unit or integration tests (Go or frontend)
- Applying TDD: failing test first, then implementation, then refactor
- Reproducing a bug with a test before fixing it
- Creating or updating bug reports when not fixing immediately
- Improving or verifying test coverage

## References

| File | Purpose |
|------|---------|
| [.cursor/rules/04a-go-testing-practices.mdc](.cursor/rules/04a-go-testing-practices.mdc) | Go testing (testify, t.Run, unit tests with mocks, integration tests with testcontainers), test naming, coverage, test data factories |
| [.cursor/rules/04b-frontend-testing-practices.mdc](.cursor/rules/04b-frontend-testing-practices.mdc) | Frontend testing (React Testing Library, MSW), build verification, TypeScript compilation checks |
| [.cursor/rules/09-test-driven-development.mdc](.cursor/rules/09-test-driven-development.mdc) | TDD core principles, Iron Law, verification checklist, red flags |
| [.cursor/skills/tdd-workflow/SKILL.md](.cursor/skills/tdd-workflow/SKILL.md) | Detailed TDD workflow with examples, common rationalizations, bug fix walkthrough |
| [.cursor/rules/08-testing-agent.mdc](.cursor/rules/08-testing-agent.mdc) | Bug handling and prioritization (critical vs low), bug report template, BUG_NNN naming, systematic testing checklist, when to fix vs when to backlog |
