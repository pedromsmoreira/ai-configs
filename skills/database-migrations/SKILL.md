---
name: database-migrations
description: Creates and manages PostgreSQL schema migrations with golang-migrate for this project. Use when adding or changing tables, columns, indexes, or constraints, or when running or rolling back migrations.
disable-model-invocation: true
version: 1.0
---

# Database Migrations Skill

## When to use

- Adding or changing tables, columns, indexes, or constraints
- Creating new `NNNNNN_description.up.sql` and `.down.sql` pairs
- Running or rolling back migrations (`make migrate-up`, `make migrate-down`)
- Checking migration version or troubleshooting migrate state

For **repository code** (queries, transactions, domain↔DB mapping), see `../../rules/database-migrations.mdc` and the `go-backend` skill.

## Renaming or dropping a column in production (expand/contract)

During a rollout, old and new code run at once. Never rename or drop a column in the same release that changes the code that reads it. Ship additive phases instead, each its own migration and deploy. Example, renaming `name` to `full_name`:

1. **Expand.** Migration adds `full_name` as nullable. Deploy. Old code ignores it.
2. **Dual-write.** The repository writes both `name` and `full_name`. Deploy.
3. **Backfill.** Copy `name` to `full_name` in throttled batches, never one table-wide `UPDATE`.
4. **Switch reads.** The repository reads `full_name` and still writes both. Deploy and watch.
5. **Contract.** Stop writing `name`. In a later, separate migration, drop the column.

- Adds (nullable column, table, index) are safe in any deploy. Drops and renames go last, alone.
- Run every `.down.sql` before merging.
- Build large Postgres indexes with `CREATE INDEX CONCURRENTLY`, alone in its own migration file, because it cannot run inside a transaction.

## References

| File | Purpose |
|------|---------|
| [../../rules/database-migrations.mdc](../../rules/database-migrations.mdc) | Migration naming, immutability, up/down, schema conventions (tables, columns, indexes, FKs), column types, SQL practices; repository pattern, parameterized queries, transactions, error mapping, connection pooling, testcontainers |
| `migrations/README.md` at the project root | Project migrate setup, `make migrate-*`, `migrate` CLI, troubleshooting, `schema_migrations` |
