---
name: testing
description: Implements Test-Driven Development for this project—unit tests, integration tests with testcontainers, mocks, and regression tests. Use when writing or fixing tests, reproducing bugs with tests, or improving coverage.
version: 1.0
---

# Testing Skill

## When to use

- Writing unit or integration tests (Go or frontend)
- Writing E2E/API integration tests in `test/` folder with BDD stage patterns
- Applying TDD: failing test first, then implementation, then refactor
- Reproducing a bug with a test before fixing it
- Creating or updating bug reports when not fixing immediately
- Improving or verifying test coverage

## Test Structure Pattern

**Critical Rule**: Main test functions must contain subtests.

### Go Tests
- **Main test functions** (`TestXxx`) **MUST** contain one or more subtests using `t.Run`
- Each test case should be a subtest within the main test function
- Group related scenarios as subtests within the same main test function
- Use separate main test functions for different behaviors or distinct test groups

```go
// ✅ GOOD: Main function contains subtests
func TestNewEmail_WithInvalidInput_ReturnsError(t *testing.T) {
    t.Run("returns error for invalid email format", func(t *testing.T) {
        // test case
    })
    t.Run("returns error for empty string", func(t *testing.T) {
        // test case
    })
}
```

### Frontend Tests
- **Main test suites** should use `describe` blocks to organize related test cases
- Each `test` or `it` block should test one specific behavior
- Group related test cases within the same `describe` block

```typescript
// ✅ GOOD: Main describe block contains multiple test cases
describe('LoginPage', () => {
  test('user can submit login form', async () => { /* ... */ });
  test('displays error when email is invalid', async () => { /* ... */ });
});
```

## References

| File | Purpose |
|------|---------|
| [.cursor/rules/go-testing-practices.mdc](.cursor/rules/go-testing-practices.mdc) | Go testing (testify, t.Run subtests pattern, unit tests with mocks, integration tests with testcontainers), test naming, coverage, test data factories |
| [.cursor/rules/frontend-testing-practices.mdc](.cursor/rules/frontend-testing-practices.mdc) | Frontend testing (React Testing Library, describe/test blocks, MSW), build verification, TypeScript compilation checks |
| [.cursor/rules/test-driven-development.mdc](.cursor/rules/test-driven-development.mdc) | TDD core principles, Iron Law, verification checklist, red flags |
| [.cursor/skills/tdd-workflow/SKILL.md](.cursor/skills/tdd-workflow/SKILL.md) | Detailed TDD workflow with examples, common rationalizations, bug fix walkthrough |
| [.cursor/rules/e2e-testing-standards.mdc](.cursor/rules/e2e-testing-standards.mdc) | E2E tests in test/ folder: Given-When-Then architecture, stage files (*_test_stage.go), functional options, file organization |
| [.cursor/rules/e2e-test-overview.mdc](.cursor/rules/e2e-test-overview.mdc) | Quick reference for E2E BDD pattern, when to use, method naming |
| [.cursor/rules/e2e-test-examples.mdc](.cursor/rules/e2e-test-examples.mdc) | 7 complete examples (POST, GET, PATCH, DELETE, auth, event-driven) |
| [.cursor/rules/testing-agent.mdc](.cursor/rules/testing-agent.mdc) | Bug handling and prioritization (critical vs low), bug report template, BUG_NNN naming, systematic testing checklist, when to fix vs when to backlog |
