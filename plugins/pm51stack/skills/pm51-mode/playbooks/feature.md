# Feature

New or changed behavior, proven with an observable check.

1. Restate the goal, who will notice, and the observable check. Name the data shape the work will read and write.
2. When a product decision is still open, stop and open the frame playbook.
3. When the work is bigger than one session, or the behavior crosses more than one module and is not written down, stop and open the specify playbook. Return here with the spec and its tickets.
4. When routing lists a skill for this slice and that skill is installed, read it and follow it. When a persona for this slice is installed, follow that persona together with that skill. When neither is installed, continue. The rules directory from project config still applies.
5. When the change crosses a trust boundary, read `security-and-hardening` and follow it before you edit.
6. When a spec and its tickets already exist, and `implement-spec` is installed, read `implement-spec` and follow it once for that ticket graph. It owns the tests. When it tells an implementer to call `tdd`, read `tdd` and follow it. Do not also run `tdd-workflow`. The check from step 1 is the proof. Note a problem outside the spec and leave it untouched. Do not add a file the spec did not ask for.
7. When `implement-spec` is absent, or there is no spec and ticket graph, read `tdd-workflow` and follow red, green, refactor. Read `testing` when the check is an integration or regression test. When a spec and tickets exist and `implement-spec` is absent, say `/setup-pm51stack` in the same reply.
8. Run the check on the real surface. A UI change gets a browser pass. Record the command and the result.
9. Open the review playbook for the diff. Open the ship playbook when the user asked for a commit or a change request.

Reply with what landed, the check you ran, and the result.
