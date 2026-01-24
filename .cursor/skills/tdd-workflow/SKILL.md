---
name: tdd-workflow
description: Detailed TDD workflow with examples, rationales, and anti-patterns. Use when following Red-Green-Refactor cycle.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# TDD Workflow

Detailed workflow for Test-Driven Development. For core principles, see `.cursor/rules/09-test-driven-development.mdc`.

---

## The Cycle

```
RED (failing test) → GREEN (minimal code) → REFACTOR (clean up) → Repeat
```

---

## RED Phase - Write Failing Test

Write one minimal test showing what should happen.

### Good Example

```go
func TestRetryOperation_WithFailingOperation_RetriesThreeTimes(t *testing.T) {
    t.Run("retries until success", func(t *testing.T) {
        attempts := 0
        operation := func() (string, error) {
            attempts++
            if attempts < 3 {
                return "", errors.New("fail")
            }
            return "success", nil
        }

        result, err := RetryOperation(operation)

        assert.NoError(t, err)
        assert.Equal(t, "success", result)
        assert.Equal(t, 3, attempts)
    })
}
```
Clear name, tests real behavior, one thing.

### Bad Example

```go
func TestRetry(t *testing.T) {
    t.Run("works", func(t *testing.T) {
        mockFn := new(mocks.MockOperation)
        mockFn.On("Execute").Return("", errors.New("fail")).Twice()
        mockFn.On("Execute").Return("success", nil).Once()

        RetryOperation(mockFn.Execute)

        mockFn.AssertNumberOfCalls(t, "Execute", 3)
    })
}
```
Vague name, tests mock not code.

### RED Phase Requirements

- One behavior per test
- Clear, descriptive name
- Real code (no mocks unless unavoidable)

---

## Verify RED - Watch It Fail

**MANDATORY. Never skip.**

```bash
go test -v ./path/to/package -run TestRetryOperation
```

Confirm:
- Test fails (not errors)
- Failure message is expected
- Fails because feature missing (not typos)

**Test passes?** You're testing existing behavior. Fix test.

**Test errors?** Fix error, re-run until it fails correctly.

---

## GREEN Phase - Minimal Code

Write simplest code to pass the test.

### Good Example

```go
func RetryOperation(fn func() (string, error)) (string, error) {
    for i := 0; i < 3; i++ {
        result, err := fn()
        if err == nil {
            return result, nil
        }
        if i == 2 {
            return "", err
        }
    }
    return "", errors.New("unreachable")
}
```
Just enough to pass.

### Bad Example

```go
func RetryOperation(
    fn func() (string, error),
    opts ...RetryOption,
) (string, error) {
    config := &RetryConfig{
        MaxRetries: 3,
        Backoff:    ExponentialBackoff,
        OnRetry:    func(attempt int) {},
    }
    for _, opt := range opts {
        opt(config)
    }
    // YAGNI - over-engineered
}
```

### GREEN Phase Rules

- Don't add features beyond the test
- Don't refactor other code
- Don't "improve" beyond what's needed

---

## Verify GREEN - Watch It Pass

**MANDATORY.**

```bash
go test -v ./path/to/package -run TestRetryOperation
```

Confirm:
- Test passes
- Other tests still pass
- Output pristine (no errors, warnings)

**Test fails?** Fix code, not test.

**Other tests fail?** Fix now.

---

## REFACTOR Phase - Clean Up

After green only:
- Remove duplication
- Improve names
- Extract helpers

Keep tests green. Don't add behavior.

---

## Bug Fix Example

**Bug:** Empty email accepted

### RED

```go
func TestSubmitForm_WithEmptyEmail_ReturnsError(t *testing.T) {
    t.Run("rejects empty email", func(t *testing.T) {
        result, err := SubmitForm(FormData{Email: ""})

        assert.Error(t, err)
        assert.Equal(t, ErrEmailRequired, err)
        assert.Nil(t, result)
    })
}
```

### Verify RED

```bash
$ go test -v ./...
--- FAIL: TestSubmitForm_WithEmptyEmail_ReturnsError (0.00s)
    --- FAIL: TestSubmitForm_WithEmptyEmail_ReturnsError/rejects_empty_email (0.00s)
        form_test.go:15: Expected error but got nil
```

### GREEN

```go
var ErrEmailRequired = errors.New("email required")

func SubmitForm(data FormData) (*FormResult, error) {
    if strings.TrimSpace(data.Email) == "" {
        return nil, ErrEmailRequired
    }
    // ...
}
```

### Verify GREEN

```bash
$ go test -v ./...
--- PASS: TestSubmitForm_WithEmptyEmail_ReturnsError (0.00s)
    --- PASS: TestSubmitForm_WithEmptyEmail_ReturnsError/rejects_empty_email (0.00s)
PASS
```

### REFACTOR

Extract validation for multiple fields if needed.

---

## Why Order Matters

### "I'll write tests after to verify it works"

Tests written after code pass immediately. Passing immediately proves nothing:
- Might test wrong thing
- Might test implementation, not behavior
- Might miss edge cases you forgot
- You never saw it catch the bug

Test-first forces you to see the test fail, proving it actually tests something.

### "I already manually tested all the edge cases"

Manual testing is ad-hoc. You think you tested everything but:
- No record of what you tested
- Can't re-run when code changes
- Easy to forget cases under pressure
- "It worked when I tried it" is not comprehensive

Automated tests are systematic. They run the same way every time.

### "Deleting X hours of work is wasteful"

Sunk cost fallacy. The time is already gone. Your choice now:
- Delete and rewrite with TDD (X more hours, high confidence)
- Keep it and add tests after (30 min, low confidence, likely bugs)

The "waste" is keeping code you can't trust.

### "TDD is dogmatic, being pragmatic means adapting"

TDD IS pragmatic:
- Finds bugs before commit (faster than debugging after)
- Prevents regressions (tests catch breaks immediately)
- Documents behavior (tests show how to use code)
- Enables refactoring (change freely, tests catch breaks)

"Pragmatic" shortcuts = debugging in production = slower.

### "Tests after achieve the same goals"

No. Tests-after answer "What does this do?" Tests-first answer "What should this do?"

Tests-after are biased by your implementation. You test what you built, not what's required.

Tests-first force edge case discovery before implementing. Tests-after verify you remembered everything (you didn't).

---

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing. |
| "Already manually tested" | Ad-hoc is not systematic. No record, can't re-run. |
| "Deleting X hours is wasteful" | Sunk cost fallacy. Unverified code is technical debt. |
| "Keep as reference" | You'll adapt it. That's testing after. Delete means delete. |
| "Need to explore first" | Fine. Throw away exploration, start with TDD. |
| "Test hard = design unclear" | Listen to test. Hard to test = hard to use. |
| "TDD will slow me down" | TDD faster than debugging. |
| "Existing code has no tests" | You're improving it. Add tests for existing code. |

---

## Testing Anti-Patterns

When adding mocks or test utilities, avoid:
- Testing mock behavior instead of real behavior
- Adding test-only methods to production code
- Mocking without understanding dependencies

---

## Given-When-Then Pattern

Every test follows:

| Step | Purpose |
|------|---------|
| **Given** | Set up preconditions and context |
| **When** | Execute the action under test |
| **Then** | Verify the expected outcome |

---

## Test Prioritization

| Priority | Test Type |
|----------|-----------|
| 1 | Happy path |
| 2 | Error cases |
| 3 | Edge cases |
| 4 | Performance |

---

> **Remember:** The test is the specification. If you can't write a test, you don't understand the requirement.
