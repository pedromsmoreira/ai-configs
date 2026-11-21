# Bug

Something is broken, throwing, failing, or slow. Start from a check that fails on this bug.

1. Restate the symptom, who hits it, and the check that fails today and should pass when the bug is gone.
2. Read `diagnosing-bugs` and follow it. Reproduce, narrow, then fix. A guess without a failing check waits.
3. Read `tdd-workflow` and `testing`. Write the failing check first, then the fix.
4. When the failure crossed a trust boundary, read `security-and-hardening` and follow it.
5. When logs, metrics, or traces would have shown the failure and did not, open the signal playbook after the fix.
6. Re-run the check and record the result. Open the review playbook, then the ship playbook when the user asked to land it.

Reply with the cause, the failing check, and the result after the fix.
