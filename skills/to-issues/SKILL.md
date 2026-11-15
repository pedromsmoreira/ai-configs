---
name: to-issues
description: Break a plan, spec, or PRD into tracer-bullet GitHub issues, each declaring the issues that block it. Use when the user wants to convert a plan into issues, create implementation tickets, or break down work into issues.
disable-model-invocation: true
---

# To Issues

Break a plan, spec, or conversation into **issues**: tracer-bullet vertical slices, each declaring the issues that **block** it. Issues live in GitHub Issues and are published with `gh`.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (a spec path, an issue number or URL) as an argument, read it in full, with `gh issue view <number> --comments` for issues.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Issue titles and descriptions should use the vocabulary in `GLOSSARY.md` and respect ADRs in `docs/adr/` for the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the work into **tracer bullet** issues.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests): vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

Give each issue its **blocking edges**: the other issues that must complete before it can start. An issue with no blockers can start immediately.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change (rename a column, retype a shared symbol) whose **blast radius** fans across the whole codebase, so a single edit breaks every call site at once and no vertical slice can land green. Sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites in batches sized by blast radius (per package, per directory), each batch its own issue blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in an issue blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify issue; green is promised only there.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each issue, show:

- **Title**: short descriptive name
- **Blocked by**: which other issues (if any) must complete first
- **What it delivers**: the end-to-end behaviour this issue makes work

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct: does each issue only depend on issues that genuinely gate it?
- Should any issues be merged or split further?

Iterate until the user approves the breakdown.

### 5. Publish the issues

Publish one issue per approved slice with `gh issue create --title <title> --body-file <file>`, in dependency order (blockers first), so each "Blocked by" can reference real issue numbers. Add `--label ready-for-agent` when the repo has that label (`gh label list`).

Work the **frontier**: any issue whose blockers are all done. For a purely linear chain that means top to bottom.

Do NOT close or modify any parent issue.

<issue-template>

## Parent

A reference to the parent issue (if the source was an existing issue, otherwise omit this section).

## What to build

The end-to-end behaviour this issue makes work, from the user's perspective, not layer-by-layer implementation.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- A reference to each blocking issue, or "None (can start immediately)".

</issue-template>

Avoid specific file paths or code snippets: they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype. Trim to the decision-rich parts, not a working demo, just the important bits.
