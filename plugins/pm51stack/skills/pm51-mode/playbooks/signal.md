# Signal

Logs, metrics, traces, or alerts. The point is that the next failure is visible.

1. Restate the event that must be visible, who will look at it, and how you will prove the signal fires.
2. Read `observability-and-instrumentation` and follow it.
3. When the signal is part of a new behavior, open the feature playbook and keep this signal as the check for that slice.
4. When the signal exists because a bug was invisible, confirm the bug playbook's fix still has its failing-then-passing check.
5. Trigger the signal on purpose and record the output you saw.
6. Open the review playbook. Open the ship playbook when the user asked for a commit or a pull request.

Reply with the signal, the path that emits it, and the output you captured.
