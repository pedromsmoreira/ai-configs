# Refactor

A behavior-preserving change to structure or shape. The existing observable behavior is the check.

1. Restate the structure you are changing and the behavior that must stay the same. Name the tests or the user-visible path that already prove that behavior.
2. When the desired end state is actually new behavior, stop and open the feature playbook.
3. Read the pack skill for the code you are moving: `go-backend`, `rest-api-design`, `frontend-react`, or `database-migrations`.
4. Read `tdd-workflow`. Run the existing check and confirm it passes before you edit. Keep it passing after each move.
5. When the change is non-trivial and pstack is installed, read `poteto-mode` and follow its refactoring playbook. The passing check from step 1 is the proof.
6. Run the same check again and record the result.
7. Open the review playbook. Open the ship playbook when the user asked for a commit or a change request.

Reply with what moved, what stayed observable, and the check you re-ran.
