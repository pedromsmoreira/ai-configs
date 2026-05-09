---
name: go-backend
description: Implements and modifies Go backend services for this project—gRPC handlers, services, domain logic, repositories, and Protocol Buffers. Use when building or changing backend APIs, business logic, domain entities, or repository layer.
version: 1.0
---

# Go Backend Skill

## When to use

- Building or changing backend APIs, gRPC endpoints, or REST Gateway surface
- Implementing or updating domain entities, value objects, or business logic
- Adding or changing handlers, services, or repository implementations
- Editing Protocol Buffers or generated gRPC/gateway code workflow
- Fixing backend bugs (follow TDD: failing test first, then fix)

For **migrations** (schema, up/down), use the `database-migrations` skill. For **testing** focus (TDD, mocks, integration), use the `testing` skill.

## References

| File | Purpose |
|------|---------|
| [../../rules/architecture.mdc](../../rules/architecture.mdc) | Layered architecture (Handler→Service→Domain→Repository), DDD, aggregates, repository pattern, error handling |
| [../../rules/go-style-guide.mdc](../../rules/go-style-guide.mdc) | Naming, context, structs, interfaces, domain/service/handler guidelines |
| [../../rules/authentication-security.mdc](../../rules/authentication-security.mdc) | JWT, Principal, `auth.GetPrincipal(ctx)`, password hashing, authorization patterns |
| [../../rules/database-migrations.mdc](../../rules/database-migrations.mdc) | Repository and SQL patterns, connection pooling; for migration files see `database-migrations` skill |
| [../../rules/agent-behavior.mdc](../../rules/agent-behavior.mdc) | TDD, docs, code review, common patterns (new entity, new endpoint) |
