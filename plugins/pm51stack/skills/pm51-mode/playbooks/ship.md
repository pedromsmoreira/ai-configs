# Ship

Commit, change request, deploy, rollout, or rollback. Land only what the check covered. The forge in `.cursor/rules/pm51stack.mdc` decides the words: a pull request on GitHub, a merge request on GitLab.

1. Restate what is going out and the check that already passed for it. Read the `forge` line in `.cursor/rules/pm51stack.mdc`.
2. When the user asked for a commit, read `conventional-commits` and `git-commit` and follow them.
3. When `forge` is `github` and the user asked for a pull request, read `pr` and follow it. When `forge` is `gitlab` and the user asked for a merge request, follow the forge section of [../project-config.md](../project-config.md). The body states the goal, the check, and the result.
4. When the change deploys, rolls out in stages, or needs a rollback, read `shipping-and-launch` and follow it.
5. When a person must click a dashboard, paste a secret, or run a cutover, read `wizard` and follow it. Stop on that step and hand it to them.
6. When pstack is installed and the user asked to land a stack, read `poteto-mode` and follow its shipping playbook. This playbook still owns the decision to land.
7. Report the link, the check, and any step still waiting on a person.

Reply with the link, the check result, and the human step if one remains.
