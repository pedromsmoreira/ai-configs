# Configuration Checklist for New Projects

Use this checklist when applying the `.cursor/` configuration to a new project.

## Required Setup

### 1. Copy Configuration Directory

- [ ] Copy `.cursor/` directory to your project root
- [ ] Verify all subdirectories copied (agents, rules, skills)
- [ ] Verify this CHECKLIST.md is present

### 2. Customize Project Context

Edit `.cursor/rules/project-context.mdc`:

- [ ] Replace `[PROJECT_NAME]` with your actual project name
- [ ] Fill in project overview/description
- [ ] Update **Tech Stack** section:
  - [ ] Backend language, framework, database
  - [ ] Frontend framework, UI library (or remove if backend-only)
  - [ ] Authentication method
  - [ ] Migration tool
  - [ ] Testing frameworks
- [ ] Update **Project Structure** with your actual directories
- [ ] Define **Key Design Principles** (3-5 principles)
- [ ] Document **Domain Concepts** (key terms in your domain)
- [ ] Update **Current Status** with completed and planned features
- [ ] Fill in **Quick Reference** (ports, commands, database info)
- [ ] **Remove the example section** at the bottom (URL Shortener example)
- [ ] Verify no `[PLACEHOLDER]` text remains

### 3. Update Agent Documentation References

Review these agent files and update `docs/` path references to match your project:

- [ ] `.cursor/agents/be-engineer.md`:
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
- [ ] Verify no placeholders remain:
  ```bash
  grep -r "\[PLACEHOLDER\]" .cursor/rules/project-context.mdc
  # Should return no results
  ```
- [ ] Check for template instructions:
  ```bash
  grep -A5 "EXAMPLE:" .cursor/rules/project-context.mdc
  # Should return no results after removing example
  ```

### Manual Verification

- [ ] All file paths in rules match your actual project structure
- [ ] Skills validate correctly (if skills-ref available)
- [ ] Agent personas align with your team structure
- [ ] Project context accurately describes your system

### Testing Agent References

Try these simple prompts to verify agents work:

- [ ] `@be-engineer What backend patterns should I follow?`
- [ ] `@fe-engineer What frontend standards do we use?`
- [ ] `@product-owner How do I write user stories?`
- [ ] `@devops-engineer What's our deployment process?`

If agents give generic or incorrect answers, review `project-context.mdc`.

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

- [ ] Add `.cursor/` directory to git:
  ```bash
  git add .cursor/
  git commit -m "Add Cursor AI configuration"
  ```
- [ ] Consider adding to README.md:
  ```markdown
  ## AI Assistance
  
  This project uses Cursor AI with custom configurations.
  See `.cursor/README.md` for details.
  ```

### Team Onboarding

- [ ] Share `.cursor/README.md` with team
- [ ] Add AI configuration to onboarding docs
- [ ] Document expected AI usage patterns
- [ ] Set up validation in pre-commit hooks (optional)

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
- [ ] Per sprint: Update project context with new features
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

**Solution**: Ensure `project-context.mdc` has accurate directory structure and descriptions.

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

**Solution**: Search for remaining `[PLACEHOLDER]` text in all `.cursor/` files and replace.

## Resources

- **Quick Start**: [.cursor/README.md](.cursor/README.md)
- **Agent Documentation**: [.cursor/agents/README.md](.cursor/agents/README.md)
- **Skills Documentation**: [.cursor/skills/README.md](.cursor/skills/README.md)
- **Agent Skills Spec**: https://agentskills.io/specification
- **Project Context Template**: [.cursor/rules/project-context.mdc](.cursor/rules/project-context.mdc)

## Next Steps

After completing this checklist:

1. ✅ Start using agents in your development workflow
2. ✅ Provide feedback on agent effectiveness
3. ✅ Iterate on rules and skills based on team needs
4. ✅ Share learnings with the team

---

**Ready to build with AI! 🎯**
