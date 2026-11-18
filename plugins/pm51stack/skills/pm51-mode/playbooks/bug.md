# Bug

Something is broken, throwing, failing, or slow. Start from a check that fails on this bug.

1. Restate the symptom, who hits it, and the check that fails today and should pass when the bug is gone.
2. Read `diagnosing-bugs` and follow it. Reproduce, narrow, then fix. A guess without a failing check waits.
3. When pstack is installed, read `poteto-mode` and follow its bug-fix playbook once the failing check exists. That check is the proof.
4. When pstack is absent, read `tdd-workflow` and `testing`. Write the failing check first, then the fix.
5. When the failure crossed a trust boundary, read `security-and-hardening` and follow it.
6. When logs, metrics, or traces would have shown the failure and did not, open the signal playbook after the fix.
7. Re-run the check and record the result. Open the review playbook, then the ship playbook when the user asked to land it.

Reply with the cause, the failing check, and the result after the fix.
