# CLAUDE.md

Dev instructions for the lead-dev-os repository itself.

## Project

lead-dev-os is a [Claude Code plugin](https://code.claude.com/docs/en/plugins.md) — a spec & context-driven framework for Claude Code development on large projects. It provides structured skills for product planning, spec writing, task scoping, and context-aware implementation.

The plugin lives in the `lead-dev-os/` subdirectory. Everything outside that directory is repository-level supporting infrastructure (tests, docs, legacy code) and is **not** part of the distributed plugin.

## License

MIT License

## Terminology

- **plugin** — the `lead-dev-os/` directory; this is what users point `--plugin-dir` at or install via a marketplace
- **target project** — the project where the `lead-dev-os` plugin is installed/enabled
- **spec** — a feature specification (created in the target project)
- **task** — a scoped unit of work to be executed by the AI agent
- **skill** — a directory under `lead-dev-os/skills/` containing a `SKILL.md` file; invoked as `/lead-dev-os:<skill-name>`

## Plugin Architecture

This project follows the [Claude Code plugin structure](https://code.claude.com/docs/en/plugins-reference.md):

- **Manifest**: `lead-dev-os/.claude-plugin/plugin.json` — defines plugin metadata (`name`, `version`, `description`, `author`, etc.). The `name` field (`lead-dev-os`) is the namespace prefix for all skills.
- **Skills**: `lead-dev-os/skills/` — flat directory of skill folders, each containing a `SKILL.md` entrypoint. Skills may include supporting files (templates, examples, scripts) alongside `SKILL.md`. Claude Code auto-discovers skills from this directory.
- Only `plugin.json` goes inside `.claude-plugin/`. All other directories (`skills/`, etc.) are at the plugin root level.

Users load the plugin during development with:
```bash
claude --plugin-dir ./lead-dev-os
```

Or install it from a marketplace for persistent use across sessions. See [Discover and install plugins](https://code.claude.com/docs/en/discover-plugins.md).

## Repository Structure

```
lead-dev-os/                                   # Repository root
├── lead-dev-os/                               # THE PLUGIN (this is what gets distributed)
│   ├── .claude-plugin/
│   │   └── plugin.json                        # Plugin manifest (name, version, author, etc.)
│   └── skills/                                # Flat skill directories (plugin requirement)
│       ├── configure-project/                  # Project configuration
│       │   ├── SKILL.md
│       │   ├── templates/                     # Templates for target project files
│       │   │   ├── agents.md                  # → agents-context/AGENTS.md
│       │   │   ├── claude.md                  # → CLAUDE.md framework section
│       │   │   ├── readme.md                  # → agents-context/README.md
│       │   │   └── workflow.md                # → agents-context/guides/workflow.md
│       │   ├── examples/
│       │   │   └── readme-filled.md           # Example of a mature README.md
│       │   ├── standards-global/              # Global standards (always copied)
│       │   │   ├── coding-style.md
│       │   │   ├── commenting.md
│       │   │   ├── conventions.md
│       │   │   ├── error-handling.md
│       │   │   └── validation.md
│       │   └── standards-testing/             # Testing standards (always copied)
│       │       └── test-writing.md
│       ├── plan-product/                      # Strategic: product mission
│       ├── plan-roadmap/                      # Strategic: feature roadmap
│       ├── define-standards/                  # Strategic: coding standards
│       ├── create-or-update-concepts/         # Strategic: codebase → concept files
│       ├── step1-write-spec/                  # Tactical: requirements → spec
│       ├── step2-scope-tasks/                 # Tactical: spec → task groups
│       └── step3-implement-tasks/             # Tactical: task execution
│
├── tests/                                     # Test suites for the plugin
├── docs/                                      # GitHub Pages documentation
├── app/                                       # DEPRECATED (legacy installer source)
├── scripts/                                   # DEPRECATED (legacy installer scripts)
├── CLAUDE.md                                  # This file — dev instructions for this repo
├── INITIAL_PLAN.md                            # Detailed design plan
├── LICENSE
└── README.md
```

## Key Conventions

### Plugin conventions
- `lead-dev-os/` is the plugin root — it contains `.claude-plugin/plugin.json` and `skills/`
- Skills are flat under `lead-dev-os/skills/` — no nesting of skill directories (this is a [plugin requirement](https://code.claude.com/docs/en/plugins-reference.md))
- All skill cross-references use the `/lead-dev-os:` namespace (e.g., `/lead-dev-os:step1-write-spec`). The namespace comes from the `name` field in `plugin.json`.
- Each skill is a directory with a `SKILL.md` entrypoint and optional supporting files (templates, examples, scripts). See [Skills docs](https://code.claude.com/docs/en/skills.md).
- Templates are co-located with their skills (e.g., `step1-write-spec/template.md`)
- Standards files are bundled inside `lead-dev-os/skills/configure-project/` (no separate content/ directory)

### Target project conventions
- Specs go into `lead-dev-os/specs/` directory in the target project
- No `config.yml` in the plugin — stack selection is handled interactively by `/lead-dev-os:configure-project`

### Legacy
- `app/` and `scripts/` are deprecated but still functional for backwards compatibility

## Workflow (3 steps)

1. `/lead-dev-os:step1-write-spec` — Interactive Q&A to gather requirements, then formalize into structured spec
2. `/lead-dev-os:step2-scope-tasks` — Break into task groups with explicit context directives
3. `/lead-dev-os:step3-implement-tasks` — Context-aware execution of task groups

## Context Philosophy

Concept files (`agents-context/concepts/`) are general guidance, not code:
- Describe approaches, conventions, and decision rationale
- Reference file paths instead of duplicating code
- Each file covers one concept/feature domain
- Composable — load only what's needed for the current task
