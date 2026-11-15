---
name: conventional-commits
description: >-
  Formats and validates commit messages per Conventional Commits (header grammar,
  optional body and footers, breaking changes). Use when drafting or reviewing
  git commit messages, preparing squash or merge titles, or checking messages
  for spec compliance. Evidence must come from Git only; MCP servers are not
  used with this skill.
allowed-tools: Read, Bash
version: 1.0
---

# Conventional Commits

Follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/). Do not return or approve a message that does not satisfy the rules below.

---

## Tooling constraints (mandatory)

- **Git only** — Inspect the repository with Git when you need evidence for the message (e.g. `git status`, `git diff`, `git diff --staged`, `git log`, `git show`). Do not rely on issue trackers, browsers, APIs, or other integrations for commit wording unless the user pasted that text into the chat.
- **No MCP** — Do not call MCP tools, MCP resources, or any MCP server while applying this skill (including for diffs, tickets, or CI). If something cannot be inferred from Git plus the conversation, ask the user or omit it.
- **Bash** — When using the shell for this skill, run **only Git** (and a shell that invokes `git`). Do not use Bash for unrelated network calls or tooling.
- **No `--trailer`** — Do not invoke `git commit` with `--trailer`, and do not suggest that workflow. Footers belong in the message text (or `commit -F`) if the user wants them; avoid Git’s trailer-injection flags unless the user explicitly requests a named trailer.

---

## When to use

- The user asks for a commit message, subject line, or full message.
- Reviewing or correcting a proposed commit or PR/squash title for Conventional Commits compliance.
- Suggesting how to split work into multiple commits with separate headers.

---

## Required header

Single first line (the “subject” or “header”):

```text
<type>[optional scope][optional !]: <description>
```

- **type** — Required, noun describing the change (see Types).
- **scope** — Optional; parenthesized, describes the section of the codebase (often a package or area). Prefer lowercase for scope.
- **!** — Optional; present if the commit introduces a breaking API change (see Breaking changes).
- **description** — Required; short summary. Use **imperative mood** (*add*, *fix*, not *added* or *fixes*). Do **not** end the description with a period.

Whitespace: one space after the colon. No extra leading/trailing spaces on the header line.

---

## Types

Common types (use the best fit):

| type | Typical use |
|------|-------------|
| `feat` | New user-facing capability |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, whitespace; no code meaning change |
| `refactor` | Refactor without feature or fix |
| `perf` | Performance improvement |
| `test` | Tests only |
| `build` | Build system or dependencies |
| `ci` | CI configuration |
| `chore` | Maintenance tasks that do not fit above |
| `revert` | Reverts a prior commit (see Reverts) |

The Conventional Commits spec allows **other types** if they match the same grammar; prefer the table when it fits.

---

## Breaking changes

Either:

- Append **`!`** immediately before the colon in the header (e.g. `feat(api)!: remove legacy endpoint`), and/or
- Add a footer line **`BREAKING CHANGE:`** (all caps, per spec) in the footer section with an explanation.

You may use both. The body may elaborate; the footer token makes the break explicit for tooling.

---

## Body and footers

- After the header, optionally add a **blank line**, then a **body** with more detail (wrap long lines at a reasonable width, e.g. 72 characters, for readability).
- **Footers** go after another blank line following the body. Each footer is a token, optional space, separator, value. Common patterns: `BREAKING CHANGE: description`, `Reviewed-by: Name`, issue refs as `Refs: #123` if your project uses that form.

### Reverts

For a revert commit, the header is often:

```text
revert: <header of the reverted commit>
```

Body should include `This reverts commit <full hash>.` per the spec.

---

## Enforcement checklist (agent)

Before finalizing output, confirm:

1. Header matches `type(scope)!: description` grammar (scope and `!` optional).
2. Description is imperative and has no trailing period.
3. Type and scope casing are consistent (type lowercase; scope usually lowercase).
4. Breaking changes use `!` and/or `BREAKING CHANGE:` footer as appropriate.
5. If a body or footers are present, blank lines separate header, body, and footers.
6. Evidence for *what* changed came from **Git** (and user chat), not from MCP or external tools.
7. For multiple logical changes, prefer suggesting **multiple commits** with one concern each rather than one vague header.
8. Do not suggest or append `Co-authored-by: Cursor`, `Made-with: Cursor`, `cursoragent@cursor.com`, or similar vendor attribution footers unless the user explicitly requests a real co-author line.
9. Do not suggest shell commands that pass `--trailer` to `git commit` (or otherwise use Git trailer injection) unless the user explicitly asked for that mechanism.

If a proposed message fails any check, **fix it** or **reject** it and explain briefly.

---

## Examples

### Good

```text
feat(auth): add refresh token rotation

Validate refresh tokens once per session and revoke on reuse.
```

```text
fix(reports): handle empty CSV column headers

Previously crashed when the first row was blank.
```

```text
docs: correct install steps for Go 1.22
```

```text
feat(api)!: remove deprecated /v1/users export endpoint
```

### Bad

```text
Fixed the bug.
```
Not conventional: missing type and scope pattern; not imperative as a full sentence style.

```text
feat: Added login.
```
Past tense / trailing period on description; weak description.

```text
FEAT(UI): new button
```
Inconsistent casing; description should stay imperative and lowercase start is conventional.

```text
chore: misc updates
```
Too vague; split or specify what changed (use Git to name the real change).

---

## Spec reference

Full rules, edge cases, and the revert template: [conventionalcommits.org](https://www.conventionalcommits.org/en/v1.0.0/).
