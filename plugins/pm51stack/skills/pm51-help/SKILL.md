---
name: pm51-help
description: Say which pm51stack playbook fits a task, which skill it opens first, and the /pm51-mode prompt to send. Use when the user runs /pm51-help or asks which phase to use. Does not start the work.
disable-model-invocation: true
---

# pm51-help

Answer the routing question and stop. Do not edit the project, do not run the playbook, and do not read the target skill in order to do the task.

## Steps

1. Read [../pm51-mode/routing.md](../pm51-mode/routing.md).
2. Match the user's situation to one row.
3. Reply with the playbook name, the first skill that row names, and a prompt they can send:

```text
/pm51-mode <their task, in their words, plus the check they named>
```

4. When pstack or `/setup-pm51stack` is required for that row and you can see it is missing, say the install command in the same reply. The install commands are `/setup-pm51stack`, `/add-plugin pstack`, and `/setup-pstack`.
5. Stop.
