# Feature

New or changed behavior, built as a vertical slice and proven with an observable check.

1. Restate the goal, who will notice, and the observable check. Name the data shape the slice will read and write.
2. When a product decision is still open, stop and open the frame playbook.
3. When the work is bigger than one session, or the behavior crosses more than one module and is not written down, stop and open the specify playbook. Return here with one slice.
4. When routing lists a skill for this slice and that skill is installed, read it and follow it. When a persona for this slice is installed, follow that persona together with that skill. When neither is installed, continue. The rules directory from project config still applies.
5. When the change crosses a trust boundary, read `security-and-hardening` and follow it before you edit.
6. When pstack is installed, read `poteto-mode` and follow its feature playbook for this slice. The check from step 1 is the proof.
7. When pstack is absent, read `tdd-workflow` and follow red, green, refactor. Read `testing` when the check is an integration or regression test.
8. Run the check on the real surface. A UI change gets a browser pass. Record the command and the result.
9. Open the review playbook for the diff. Open the ship playbook when the user asked for a commit or a change request.

Reply with the slice, the check you ran, and the result.
