---
name: go-backend
description: Implements and modifies Go backend services for this project—gRPC handlers, services, domain logic, repositories, and Protocol Buffers—following idiomatic Go (context propagation, explicit errors, small interfaces, clear package boundaries). Use when building or changing backend APIs, business logic, domain entities, or repository layer.
version: 1.1
---

# Go Backend Skill

## When to use

- Building or changing backend APIs, gRPC endpoints, or REST Gateway surface
- Implementing or updating domain entities, value objects, or business logic
- Adding or changing handlers, services, or repository implementations
- Editing Protocol Buffers or generated gRPC/gateway code workflow
- Fixing backend bugs (follow TDD: failing test first, then fix)

For **migrations** (schema, up/down), use the `database-migrations` skill. For **testing** focus (TDD, mocks, integration), use the `testing` skill.

## Idiomatic Go baseline

Apply Go community best practices **inside** this project's DDD layers (Handler → Service → Domain → Repository). Do not replace encapsulated domain entities or layered architecture with anemic structs.

| Principle | Rule |
|-----------|------|
| **Context** | `ctx context.Context` as first parameter on service, repo, and handler methods; propagate from the request; never use `context.Background()` in handlers |
| **Errors** | Return errors explicitly; wrap with `fmt.Errorf("...: %w", err)`; compare domain/sentinel errors with `errors.Is` / `errors.As` |
| **Packages** | One package per directory; lowercase single-word names; no circular imports; domain imports nothing from infra (no SQL, protobuf, HTTP) |
| **Interfaces** | Small, consumer-defined; **accept interfaces, return structs**; generate mocks against those interfaces |
| **Constructors** | `NewXxx(...) (T, error)` for non-trivial types; validate in constructor or factory |
| **Receivers** | Consistent pointer vs value receivers on a type; prefer value receivers when the method does not mutate state |
| **Naming** | Idiomatic Go: short package names, no stutter (`user.ID` not `user.UserID`), exported API documented with doc comments |
| **Concurrency** | Tie goroutines to `ctx`; use `errgroup` for parallel work; no fire-and-forget goroutines in request paths |
| **Safety** | No `panic` in production request paths; use `defer` for cleanup (`Close`, `Rollback`) |
| **Stdlib first** | Prefer standard library; reach for third-party packages only when stdlib is insufficient |
| **Generated code** | Never edit generated proto/gateway output; change `.proto` and run `make generate` |

## Implementation workflows

### New domain entity

1. Create domain model in `internal/domain/`
2. Add repository interface
3. Implement repository in `internal/repository/`
4. Create service in `internal/service/`
5. Create handler in `internal/handler/`
6. Add proto definition
7. Write tests for each layer
8. Update migrations if needed (see `database-migrations` skill)

### New API endpoint

1. Add proto definition
2. Run `make generate`
3. Implement handler
4. Implement service method
5. Add repository methods if needed
6. Write integration test
7. Test via gRPC and REST Gateway

### Business logic change

1. Move the rule to a domain method when possible
2. Add or update methods on domain entities
3. Update services to orchestrate domain methods (no duplicated rules)
4. Write tests at the domain layer first
5. Update documentation if behavior changed

## Layer-specific patterns

### Domain

Behavior on entities, value objects via constructors, sentinel errors in the domain package.

```go
var ErrInvalidEmail = errors.New("invalid email")

type Email struct {
    value string
}

func NewEmail(value string) (Email, error) {
    if !isValidEmail(value) {
        return Email{}, ErrInvalidEmail
    }
    return Email{value: strings.ToLower(value)}, nil
}

func (u *User) ChangeEmail(newEmail Email) error {
    if u.email == newEmail {
        return ErrEmailUnchanged
    }
    u.email = newEmail
    u.updatedAt = time.Now()
    return nil
}
```

### Service

Authorization via `auth.GetPrincipal(ctx)`; orchestration only—no SQL, no proto types, no business rules that belong in domain.

```go
func (s *EntityService) CreateResource(ctx context.Context, req *CreateResourceRequest) (*domain.Entity, error) {
    principal := auth.GetPrincipal(ctx)
    if principal == nil {
        return nil, errors.ErrUnauthorized
    }
    if principal.UserType != domain.RoleX {
        return nil, errors.ErrForbidden
    }

    entity, err := domain.NewEntity(req.Name, req.OwnerID)
    if err != nil {
        return nil, err
    }
    if err := s.repo.Save(ctx, entity); err != nil {
        return nil, fmt.Errorf("save entity: %w", err)
    }
    return entity, nil
}
```

### Repository

Parameterized queries, map rows to domain entities, pass `ctx` through, map `sql.ErrNoRows` to domain errors.

```go
func (r *userRepository) GetByID(ctx context.Context, id string) (*domain.User, error) {
    query := `SELECT id, username, email, user_type, created_at, updated_at FROM users WHERE id = $1`

    row := r.db.QueryRowContext(ctx, query, id)
    user, err := scanUser(row)
    if errors.Is(err, sql.ErrNoRows) {
        return nil, errors.ErrNotFound
    }
    if err != nil {
        return nil, fmt.Errorf("get user by id: %w", err)
    }
    return user, nil
}
```

### Handler

Proto ↔ domain mapping, call service, map errors to gRPC status—no business rules.

```go
func (h *EntityHandler) CreateResource(ctx context.Context, req *pb.CreateResourceRequest) (*pb.CreateResourceResponse, error) {
    resourceReq := &CreateResourceRequest{
        Name:    req.GetName(),
        OwnerID: req.GetOwnerId(),
    }

    entity, err := h.service.CreateResource(ctx, resourceReq)
    if err != nil {
        return nil, h.mapError(err)
    }

    return &pb.CreateResourceResponse{Entity: h.toProto(entity)}, nil
}
```

## Idiomatic Go anti-patterns

| Don't | Do instead |
|-------|------------|
| Ignore `_` errors | Handle or wrap every error |
| String-compare errors | `errors.Is` / `errors.As` |
| Define huge repository interfaces | Split by aggregate or use case |
| Put business logic in handler or service | Domain methods with invariants |
| Import protobuf or SQL in domain | Keep domain framework-agnostic |
| Use `context.Background()` in handlers | Use the request `ctx` |
| Edit generated proto output | Change `.proto`, run `make generate` |
| `panic` in request handling | Return typed or sentinel errors |
| Fire-and-forget goroutines | Tie work to `ctx` or use `errgroup` |

## Before completing

| Check | Command / action |
|-------|------------------|
| Tests pass | `go test ./...` or project `make test` |
| No linter issues | `go vet ./...` and `golangci-lint run` |
| Proto changes regenerated | `make generate` if `.proto` files changed |
| Tests per layer | Domain, service, repository, handler (see `testing` skill for structure) |
| Architecture respected | Business rules in domain; handler stays thin |

## References

| File | Purpose |
|------|---------|
| [../../rules/architecture.mdc](../../rules/architecture.mdc) | Layered architecture (Handler→Service→Domain→Repository), DDD, aggregates, repository pattern, error handling |
| [../../rules/go-style-guide.mdc](../../rules/go-style-guide.mdc) | Naming, context, structs, interfaces, domain/service/handler guidelines |
| [../../rules/authentication-security.mdc](../../rules/authentication-security.mdc) | JWT, Principal, `auth.GetPrincipal(ctx)`, password hashing, authorization patterns |
| [../../rules/database-migrations.mdc](../../rules/database-migrations.mdc) | Repository and SQL patterns, connection pooling; for migration files see `database-migrations` skill |
| [../../rules/go-testing-practices.mdc](../../rules/go-testing-practices.mdc) | Go unit and integration tests (testify, t.Run, gomock, testcontainers) |
| [../../rules/agent-behavior.mdc](../../rules/agent-behavior.mdc) | TDD, proto workflow, docs, code review, common patterns |
| [../testing/SKILL.md](../testing/SKILL.md) | TDD workflow when writing or fixing tests |
