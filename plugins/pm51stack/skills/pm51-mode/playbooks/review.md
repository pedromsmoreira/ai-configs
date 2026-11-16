# Review

Judge the diff. Standards and fidelity to the spec are separate passes.

1. Name the fixed point: commit, branch, tag, or merge-base. On GitHub that fixed point may be a pull request. On GitLab it may be a merge request. Use the `forge` line in `.cursor/pm51stack.md`. Name the spec or ticket the diff claims to implement, or say there is none.
2. Read `code-review` and follow it. Keep the standards pass and the spec pass separate so one does not soften the other.
3. When the diff crosses a trust boundary, read `security-and-hardening` and add that pass.
4. Report each finding with the file and the broken behavior. A preference about style is a note. A broken check is a blocker.
5. When a blocker is real, open the bug or feature playbook for that finding. When the user asked to land a clean diff, open the ship playbook.

Reply with the blockers, the notes, and the checks you ran.
