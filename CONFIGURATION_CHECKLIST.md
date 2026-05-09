# Configuration Checklist for New Projects

Use this checklist when applying this pack to a project. **This repository** keeps `agents/`, `rules/`, and `skills/` at the **repo root**. For **Cursor**, copy or symlink those three folders into your application repo under `.cursor/` (so you get `.cursor/agents`, `.cursor/rules`, `.cursor/skills`).

## Required setup

### 1. Install configuration into the target project

- [ ] Copy `agents/`, `rules/`, and `skills/` from this pack into the target project’s `.cursor/` directory (or symlink them there)
- [ ] Verify all three directories are present under `.cursor/`
- [ ] Optionally copy [CONFIGURATION_CHECKLIST.md](CONFIGURATION_CHECKLIST.md) into project docs for the team

### 2. Customize project baseline (`AGENTS.md`)

Edit **`AGENTS.md`** at the application repository root:

- [ ] Replace project name and description placeholders
- [ ] Update **Setup & Commands** (install, build, test, lint, run)
- [ ] Document **ports**, **URLs**, and how to run integration/E2E tests
- [ ] Capture **domain** terms and roles the team uses
- [ ] Verify no `[PLACEHOLDER]` or template-only text remains

### 3. Update Agent Documentation References

Review these agent files and update `docs/` path references to match your project:

- [ ] `.cursor/agents/be-engineer.md` (in the **target** project, after install):
  - [ ] Line 157-159: Update knowledge base paths
  - [ ] Check documentation references match your structure
- [ ] `.cursor/agents/fe-engineer.md`:
  - [ ] Line 155-160: Update knowledge base paths
  - [ ] Check frontend docs paths
- [ ] `.cursor/agents/product-owner.md`:
  - [ ] Line 94-105: Update docs paths
  - [ ] Check backlog paths match your structure
- [ ] `.cursor/agents/devops-engineer.md`:
  - [ ] Check deployment docs paths

Common paths to verify:
- [ ] `docs/backlog/` - User stories and backlog items
- [ ] `docs/frontend/` - Frontend architecture and guides
- [ ] `docs/architecture/` - System architecture
- [ ] `docs/authentication/` - Auth flow documentation
- [ ] `docs/` - General documentation

### 4. Review Project-Specific Rules

Check if these rules need customization:

- [ ] `.cursor/rules/http-rest-standards.mdc` - Update if using specific router
- [ ] `.cursor/rules/api-versioning.mdc` - Verify versioning strategy matches
- [ ] Other rules in `.cursor/rules/` - Scan for project-specific examples

## Validation

### Automated Checks

- [ ] Run `make validate-skills` (if [skills-ref](https://agentskills.io/specification) installed)
- [ ] Verify no placeholders remain in **AGENTS.md**:
  ```bash
  grep "\[PLACEHOLDER\]" AGENTS.md
  # Should return no results
  ```

### Manual Verification

- [ ] All file paths in rules match your actual project structure
- [ ] Skills validate correctly (if skills-ref available)
- [ ] Agent personas align with your team structure
- [ ] **AGENTS.md** accurately describes your system

### Testing Agent References

Try these simple prompts to verify agents work:

- [ ] `@be-engineer What backend patterns should I follow?`
- [ ] `@fe-engineer What frontend standards do we use?`
- [ ] `@product-owner How do I write user stories?`
- [ ] `@devops-engineer What's our deployment process?`

If agents give generic or incorrect answers, review **`AGENTS.md`** and the relevant files under `.cursor/rules/`.

## Optional Customizations

### Additional Rules

Consider adding project-specific rules:

- [ ] Create `.cursor/rules/domain-specific.mdc` for your domain patterns
- [ ] Add `.cursor/rules/api-contracts.mdc` for API specifications
- [ ] Create `.cursor/rules/security-requirements.mdc` for security policies
- [ ] Add `.cursor/rules/performance-standards.mdc` for performance requirements

### Custom Agents

Consider creating specialized agents:

- [ ] Data Engineer (if heavy data processing)
- [ ] Security Engineer (if security-critical application)
- [ ] QA Engineer (if dedicated testing focus)
- [ ] Technical Writer (if extensive documentation needs)

Template for custom agent:

```markdown
---
name: my-agent
model: default
---

# My Custom Agent

## Role
[Your agent's role and expertise]

## Primary Responsibilities
1. [Responsibility 1]
2. [Responsibility 2]
...
```

### Additional Skills

Consider adding project-specific skills in `.cursor/skills/`:

- [ ] Domain-specific operations (e.g., `payment-processing/`)
- [ ] Project-specific integrations (e.g., `third-party-api/`)
- [ ] Specialized workflows (e.g., `data-pipeline/`)

Skills must follow the [Agent Skills specification](https://agentskills.io/specification).

## Integration with Development Workflow

### Git Integration

- [ ] Add the installed `.cursor/` directory (or this pack’s `agents/`, `rules/`, `skills/` if you track them at repo root) to git:
  ```bash
  git add .cursor/
  git commit -m "Add Cursor AI configuration"
  ```
- [ ] Consider adding to README.md:
  ```markdown
  ## AI Assistance
  
  This project uses Cursor AI with custom configurations.
  See `CONFIGURATION_GUIDE.md` in the ai-configs pack (or your project’s AI docs) for details.
  ```

### Team Onboarding

- [ ] Share [CONFIGURATION_GUIDE.md](CONFIGURATION_GUIDE.md) with the team
- [ ] Add AI configuration to onboarding docs
- [ ] Document expected AI usage patterns
- [ ] Set up validation in pre-commit hooks (optional)
- [ ] To strip automatic Cursor co-author lines from commits, run `git config core.hooksPath .githooks` in this repository (uses `.githooks/prepare-commit-msg`)

### CI/CD Integration

- [ ] Add skills validation to CI pipeline (if skills-ref available):
  ```yaml
  - name: Validate Agent Skills
    run: make validate-skills
  ```
- [ ] Consider linting rules for consistency

## Maintenance

### Regular Reviews

Schedule periodic reviews:

- [ ] Quarterly: Review agent effectiveness
- [ ] Per sprint: Update **AGENTS.md** with new features and commands
- [ ] On major changes: Update relevant rules
- [ ] When onboarding: Gather feedback on AI assistance

### Version Control

- [ ] Track changes to `.cursor/` configurations
- [ ] Document why rules were added or modified
- [ ] Keep configurations in sync across branches

## Completion Checklist

Before considering setup complete:

- [ ] All required setup items checked above
- [ ] At least one validation method completed
- [ ] Agents respond correctly to test prompts
- [ ] Team members briefed on AI configuration
- [ ] Documentation updated with AI assistance notes

## Common Issues and Solutions

### Issue: Agent doesn't understand project structure

**Solution**: Ensure **`AGENTS.md`** and your `docs/` layout match the real repository structure.

### Issue: Skills aren't activating

**Solution**: 
1. Check skill names in frontmatter match directory names exactly
2. Verify `SKILL.md` files exist in each skill directory
3. Run `make validate-skills` if available

### Issue: Agents suggest wrong patterns

**Solution**: Review and customize relevant rules in `.cursor/rules/`. Agents follow these standards.

### Issue: Too many or too few agents

**Solution**: Customize agent personas or create new ones. Remove agents not relevant to your project.

### Issue: Placeholders still in responses

**Solution**: Search for remaining `[PLACEHOLDER]` text under your project’s `.cursor/` tree (or in `rules/` if you edit this pack in place) and replace.

## Resources

- **Quick start**: [CONFIGURATION_GUIDE.md](CONFIGURATION_GUIDE.md)
- **Agent documentation**: [agents/README.md](agents/README.md)
- **Skills documentation**: [skills/README.md](skills/README.md)
- **Agent Skills spec**: https://agentskills.io/specification
- **Project baseline**: [AGENTS.md](AGENTS.md)

## Next Steps

After completing this checklist:

1. ✅ Start using agents in your development workflow
2. ✅ Provide feedback on agent effectiveness
3. ✅ Iterate on rules and skills based on team needs
4. ✅ Share learnings with the team

---

**Ready to build with AI! 🎯**
