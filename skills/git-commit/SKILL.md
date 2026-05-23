---
name: git-commit
description: >-
  Creates git commits safely with Conventional Commits messages. Use when the
  user explicitly asks to commit, stage and commit changes, or save work to git.
  Drafts messages from git diff/log; does not commit unless requested.
allowed-tools: Read, Bash
version: 1.0
---

# Git Commit

Create commits only when the user **explicitly** asks (e.g. "commit this", "create a commit"). If intent is unclear, ask first.

For message format, follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) using the rules in [../conventional-commits/SKILL.md](../conventional-commits/SKILL.md). Read that skill when drafting the subject and body.

---

## Safety rules (mandatory)

- **Never** update git config
- **Never** run destructive commands (`push --force`, `reset --hard`, etc.) unless the user explicitly requests them
- **Never** skip hooks (`--no-verify`, `--no-gpg-sign`, etc.) unless the user explicitly requests it
- **Never** force-push to `main` or `master`; warn the user if they ask
- **Never** commit secrets (`.env`, credentials, API keys, tokens). Warn if the user asks to commit those files
- **Never** use `git commit --trailer` or inject `Co-authored-by:` / `Made-with:` footers unless the user explicitly asks
- **Do not push** unless the user explicitly asks

### Amend policy

Use `git commit --amend` **only** when **all** are true:

1. User explicitly requested amend, **or** a commit succeeded but a pre-commit hook auto-modified files that must be included
2. HEAD was created by you in this conversation (`git log -1 --format='%an %ae'`)
3. Commit has **not** been pushed (`git status` shows branch ahead, not synced with remote)

If a commit **failed** or was **rejected** by a hook, fix the issue and create a **new** commit — never amend.

---

## Workflow

### 1. Gather context (parallel)

Run these in parallel before staging or committing:

```bash
git status
git diff
git diff --staged
git log -5 --oneline
```

Use `git diff [base]...HEAD` only when the user wants a commit spanning branch divergence.

Do **not** explore the codebase beyond git commands for this skill.

### 2. Analyze changes

- Identify what will be committed (staged + files to add)
- Match the repo's recent commit style from `git log`
- Split unrelated changes into **separate commits** when logical (one conventional header per concern)
- Omit files that look like secrets unless the user confirms

### 3. Draft the message

Apply [conventional-commits](../conventional-commits/SKILL.md):

```text
<type>[optional scope][optional !]: <imperative description>
```

Optional blank line, then body explaining **why** (not a file list). No trailing period on the subject.

### 4. Stage and commit (sequential)

```bash
git add <paths>
git commit -m "$(cat <<'EOF'
<type>(scope): imperative subject

Body explaining why, if needed.
EOF
)"
git status
```

- Stage only relevant paths; do not add unrelated untracked files
- Pass the message via HEREDOC for correct formatting
- If there is nothing to commit, stop — do not create an empty commit

### 5. Hook failures

If pre-commit fails:

1. Read the hook output
2. Fix the reported issues
3. Create a **new** commit (do not amend a failed attempt)

---

## Quick reference

| Situation | Action |
|-----------|--------|
| User asks for message only | Use `conventional-commits` skill; do not commit |
| Mixed feat + fix in one diff | Suggest two commits |
| Hook auto-formatted files after success | Amend only if amend policy allows |
| `.env` or credentials in diff | Warn; do not commit without explicit confirmation |

---

## Examples

**Single feature commit:**

```bash
git add internal/auth/refresh.go internal/auth/refresh_test.go
git commit -m "$(cat <<'EOF'
feat(auth): add refresh token rotation

Revoke reused refresh tokens to limit session hijacking.
EOF
)"
```

**Docs-only:**

```bash
git add README.md
git commit -m "$(cat <<'EOF'
docs: correct install steps for Go 1.22
EOF
)"
```

**Breaking change:**

```bash
git commit -m "$(cat <<'EOF'
feat(api)!: remove deprecated users export endpoint

BREAKING CHANGE: /v1/users/export removed; use /v2/users/export.
EOF
)"
```

---

## Related

- Message grammar and validation: [conventional-commits](../conventional-commits/SKILL.md)
- Agent git behavior: [../../rules/agent-behavior.mdc](../../rules/agent-behavior.mdc)
- Strip Cursor attribution trailers: `git config core.hooksPath .githooks` (`.githooks/prepare-commit-msg`)
