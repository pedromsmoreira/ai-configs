# AI Configs

Reusable AI configuration for **Cursor**, **Claude Code**, **GitHub Copilot**, **Codex-style** tools, Zed, Windsurf, and other assistants—with a focus on **Go** backends (DDD, TDD, clean architecture) and related frontend guidance.

## Layout

Clone this repository into whatever parent directory you use for tooling (for example `<editor-config-parent>/ai-configs`). Content lives at the **clone root**:

| Path | Contents |
|------|----------|
| [`AGENTS.md`](AGENTS.md) | Cross-editor baseline ([agents.md](https://agents.md/)) |
| [`agents/`](agents/) | Cursor agent personas (`be-engineer`, `fe-engineer`, …) |
| [`rules/`](rules/) | `.mdc` rules (architecture, style, testing, …) |
| [`skills/`](skills/) | [Agent Skills](https://agentskills.io/specification) task guides |
| [`CONFIGURATION_GUIDE.md`](CONFIGURATION_GUIDE.md) | How to install this pack into a **Cursor** project (`.cursor/` layout) |
| [`CONFIGURATION_CHECKLIST.md`](CONFIGURATION_CHECKLIST.md) | Checklist for applying and customizing |

**Cursor** expects `agents`, `rules`, and `skills` under each workspace’s **`.cursor/`** folder. Copy or symlink this repo’s three directories into `your-app/.cursor/` (see the configuration guide). Other tools can rely on **`AGENTS.md`** alone or mirror sections into `CLAUDE.md` / Copilot instructions as you prefer.

There is no git submodule flow. Copying `skills/` gives you the Go, React, testing, and git skills in this pack. To install Matt Pocock skills and Addy Osmani skills, run `bash plugins/pm51stack/skills/setup-pm51stack/scripts/install.sh` on a machine with Node.js 22.20 or later. The script asks whether to install into the user profile or the current project. In Cursor, `/setup-pm51stack` asks the same question, runs that script, and then tells you to install pstack with `/add-plugin pstack`.

The development workflow itself is the [`pm51stack`](plugins/pm51stack/README.md) Cursor plugin. `/pm51-mode` picks one phase and the skill that owns it. Link the plugin, run `/setup-pm51stack`, install pstack, run `/setup-pstack` once, then start a task with `/pm51-mode`.

## Quick install (Cursor project)

From this repository’s root:

```bash
mkdir -p /path/to/your-app/.cursor
cp -r agents rules skills /path/to/your-app/.cursor/
```

Then edit [`AGENTS.md`](AGENTS.md) at the app root and tailor any **`.mdc` rules** you copied under `.cursor/rules/`.

## Customization

- **`AGENTS.md`** — primary per-project overview, commands, and ports  
- **`rules/*.mdc`** — shared conventions (architecture, style, testing, …)  
- Agents under **`agents/`** — adjust doc paths and examples for your repo  

## License

MIT — see [LICENSE](LICENSE).
