
# AI Agent Configurations

This directory contains specialized AI agent configurations for this project's development team. Each agent has specific expertise and responsibilities to help build the application efficiently.

## Agent Skills

Task-focused, [Agent Skills](https://agentskills.io/specification)-compliant instructions live in **`.cursor/skills/`**. They **complement** (do not replace) the agents here. Skills: `go-backend`, `database-migrations`, `testing`, `frontend-react`, `user-stories`. See `.cursor/skills/README.md`. Validate with `make validate-skills` when [skills-ref](https://agentskills.io/specification) is installed.

## Available Agents

### 🔧 Backend Engineer (`be-engineer.md`)

**Best for:**
- Implementing Go services and APIs
- Database design and migrations
- gRPC and Protocol Buffer work
- Domain-Driven Design implementation
- Backend testing and optimization
- JWT authentication and security
- Repository pattern implementation

**Use when:**
- Building or modifying backend services
- Creating database migrations
- Implementing business logic
- Working on gRPC APIs
- Writing backend tests
- Debugging backend issues

### 🎨 Frontend Engineer (`fe-engineer.md`)

**Best for:**
- Building React components
- TypeScript development
- Material-UI implementation
- State management (Zustand, React Query)
- API integration
- Frontend testing
- UI/UX implementation
- Accessibility

**Use when:**
- Creating UI components
- Implementing user interfaces
- Integrating with REST API
- Writing frontend tests
- Fixing UI bugs
- Optimizing frontend performance

### 📋 Product Owner (`product-owner.md`)

**Best for:**
- Writing user stories
- Defining requirements
- Creating acceptance criteria
- Backlog prioritization
- Feature planning
- Reviewing implementations
- Stakeholder communication
- Release planning

**Use when:**
- Planning new features
- Writing user stories
- Defining acceptance criteria
- Prioritizing backlog
- Reviewing completed work
- Planning sprints or releases
- Clarifying requirements

## How to Use

### In Cursor IDE

1. **Reference an agent** in your prompt:
   ```
   @be-engineer Help me implement a new [feature area] service
   ```

2. **Switch context** based on task:
   ```
   @fe-engineer Create a new [feature] listing page
   @product-owner Write a user story for [domain feature] (see project context)
   ```

3. **Collaborate** between agents:
   ```
   @product-owner Define requirements for [feature area]
   @be-engineer Implement the backend for [feature area]
   @fe-engineer Build the UI to display [feature area]
   ```

## Agent Selection Guide

### Choose Backend Engineer when:
- ✅ Working with Go code
- ✅ Modifying database schema
- ✅ Implementing API endpoints
- ✅ Writing backend tests
- ✅ Debugging backend issues
- ✅ Optimizing database queries

### Choose Frontend Engineer when:
- ✅ Creating React components
- ✅ Styling with Material-UI
- ✅ Managing frontend state
- ✅ Integrating APIs
- ✅ Writing frontend tests
- ✅ Fixing UI/UX issues

### Choose Product Owner when:
- ✅ Planning new features
- ✅ Writing requirements
- ✅ Prioritizing work
- ✅ Reviewing implementations
- ✅ Defining acceptance criteria
- ✅ Creating roadmaps

## Typical Workflows

### Feature Development Flow

1. **Product Owner** - Define feature requirements
   ```
   @product-owner Create a user story for [feature area] (see project context)
   ```

2. **Backend Engineer** - Implement backend
   ```
   @be-engineer Implement the [feature] API endpoint
   ```

3. **Frontend Engineer** - Build UI
   ```
   @fe-engineer Create the [feature] UI component
   ```

4. **Product Owner** - Review and accept
   ```
   @product-owner Review the [feature] implementation
   ```

### Bug Fix Flow

1. **Product Owner** - Define bug and acceptance criteria
   ```
   @product-owner Document the [domain feature] bug
   ```

2. **Backend/Frontend Engineer** - Fix bug
   ```
   @be-engineer Fix the [feature] logic
   ```

3. **Product Owner** - Verify fix
   ```
   @product-owner Verify the [feature] bug is fixed
   ```

### Architecture Decision Flow

1. **Product Owner** - Define business requirements
   ```
   @product-owner What are the requirements for the notification system?
   ```

2. **Backend Engineer** - Propose technical approach
   ```
   @be-engineer Design the notification system architecture
   ```

3. **Frontend Engineer** - Propose UI approach
   ```
   @fe-engineer Design the notification UI components
   ```

## Agent Expertise Matrix

| Task Type | BE Engineer | FE Engineer | Product Owner |
|-----------|-------------|-------------|---------------|
| User Stories | ❌ | ❌ | ✅ |
| API Design | ✅ | 🟡 | 🟡 |
| Database Schema | ✅ | ❌ | 🟡 |
| React Components | ❌ | ✅ | ❌ |
| Business Logic | ✅ | ❌ | 🟡 |
| UI/UX Design | ❌ | ✅ | 🟡 |
| Testing | ✅ | ✅ | ❌ |
| Requirements | 🟡 | 🟡 | ✅ |
| Prioritization | ❌ | ❌ | ✅ |
| Code Review | ✅ | ✅ | ❌ |
| Acceptance Review | 🟡 | 🟡 | ✅ |

Legend:
- ✅ Primary expertise
- 🟡 Supporting knowledge
- ❌ Not their focus

## Tips for Effective Use

### 1. Be Specific
```
❌ "Help me with the user page"
✅ "@fe-engineer Create a user profile page with Material-UI that displays user information and allows editing"
```

### 2. Use the Right Agent
```
❌ "@fe-engineer Write a database migration"
✅ "@be-engineer Create a migration to add the notifications table"
```

### 3. Chain Agents for Complex Tasks
```
1. "@product-owner Define requirements for [feature area] (see project context)"
2. "@be-engineer Implement the [feature] backend service"
3. "@fe-engineer Create the UI to configure [feature]"
```

### 4. Reference Context
```
"@be-engineer Looking at USER_STORY_005.md, implement the [feature] API"
```

### 5. Ask for Reviews
```
"@product-owner Review the implementation of USER_STORY_010 against acceptance criteria"
```

## Common Questions

### Can I mix agents in one prompt?
Yes! For complex tasks, you can reference multiple agents:
```
"@product-owner and @be-engineer: Plan and implement a new [feature area] (see project context)"
```

### Which agent should I use for testing?
- Backend tests: `@be-engineer`
- Frontend tests: `@fe-engineer`
- Test planning and acceptance: `@product-owner`

### What if I'm not sure which agent to use?
Start with the **Product Owner** to clarify requirements, then they can guide you to the appropriate technical agent.

### Can agents work together?
Absolutely! Agents are designed to collaborate. The Product Owner can hand off to technical agents, and BE/FE engineers can coordinate on API contracts.

## Project-Specific Context

All agents have access to:
- Project architecture documentation (`.cursor/rules/`)
- Coding standards and best practices
- Testing guidelines
- Authentication patterns
- Database patterns

They also respect:
- Domain-Driven Design principles
- Test-Driven Development approach
- Layered architecture
- Security-first mindset

## Quick Reference Commands

```bash
# View agent details
cat .cursor/agents/be-engineer.md
cat .cursor/agents/fe-engineer.md
cat .cursor/agents/product-owner.md

# Common prompts
"@product-owner Create a user story for [feature]"
"@be-engineer Implement [backend feature]"
"@fe-engineer Build UI for [feature]"
"@product-owner Review [feature] implementation"
```

---

**Remember**: Use the right agent for the task, be specific in your requests, and leverage their specialized expertise for the best results!