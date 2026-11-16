# Feature

New or changed behavior, built as a vertical slice and proven with an observable check.

1. Restate the goal, who will notice, and the observable check. Name the data shape the slice will read and write.
2. When a product decision is still open, stop and open the frame playbook.
3. When the work is bigger than one session, or the behavior crosses more than one module and is not written down, stop and open the specify playbook. Return here with one slice.
4. Read the pack skill for the slice: `go-backend`, `rest-api-design`, `frontend-react`, or `database-migrations`. When the project has `be-engineer` or `fe-engineer`, follow that persona together with the pack skill.
5. When the change crosses a trust boundary, read `security-and-hardening` and follow it before you edit.
6. Build test-first. Read `tdd-workflow` and follow red, green, refactor. Read `testing` when the check is an integration or regression test.
7. When the slice is non-trivial and pstack is installed, read `poteto-mode` and follow its feature playbook for this slice. The check from step 1 is the proof. When pstack is absent, `tdd-workflow` remains the build.
8. Run the check on the real surface. A UI change gets a browser pass. Record the command and the result.
9. Open the review playbook for the diff. Open the ship playbook when the user asked for a commit or a change request.

Reply with the slice, the check you ran, and the result.
