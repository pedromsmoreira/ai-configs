---
name: database-migrations
description: Creates and manages PostgreSQL schema migrations with golang-migrate for this project. Use when adding or changing tables, columns, indexes, or constraints, or when running or rolling back migrations.
version: 1.0
---

# Database Migrations Skill

## When to use

- Adding or changing tables, columns, indexes, or constraints
- Creating new `NNNNNN_description.up.sql` and `.down.sql` pairs
- Running or rolling back migrations (`make migrate-up`, `make migrate-down`)
- Checking migration version or troubleshooting migrate state

For **repository code** (queries, transactions, domain↔DB mapping), see `.cursor/rules/06-database-migrations.mdc` and the `go-backend` skill.

## References

| File | Purpose |
|------|---------|
| [.cursor/rules/06-database-migrations.mdc](.cursor/rules/06-database-migrations.mdc) | Migration naming, immutability, up/down, schema conventions (tables, columns, indexes, FKs), column types, SQL practices; repository pattern, parameterized queries, transactions, error mapping, connection pooling, testcontainers |
| [migrations/README.md](migrations/README.md) | Project migrate setup, `make migrate-*`, `migrate` CLI, troubleshooting, `schema_migrations` |
