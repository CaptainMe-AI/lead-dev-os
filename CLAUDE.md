# CLAUDE.md

Dev instructions for the lead-dev-os repository itself.

## Project

lead-dev-os is a spec & context-driven framework for Claude Code development on large projects. It provides structured skills for product planning, spec writing, task scoping, and context-aware implementation. Distributed as a Claude Code plugin.

## License

MIT License

## Terminology

- **target project** — the project where `lead-dev-os` plugin is used
- **spec** — a feature specification
- **task** — a task to be executed by the AI agent
- **plugin** — the `lead-dev-os/` directory containing `.claude-plugin/` and `skills/`

## Repository Structure

```
lead-dev-os/                                   # Repository root
├── lead-dev-os/                               # THE PLUGIN
│   ├── .claude-plugin/
│   │   └── plugin.json                        # Plugin metadata
│   ├── skills/                                # Flat skill directories (no nesting)
│   │   ├── init/                              # Project initialization (replaces install.sh)
│   │   │   ├── SKILL.md
│   │   │   ├── templates/                     # Templates for target project files
│   │   │   │   ├── agents.md                  # → agents-context/AGENTS.md
│   │   │   │   ├── claude.md                  # → CLAUDE.md framework section
│   │   │   │   ├── readme.md                  # → agents-context/README.md
│   │   │   │   └── workflow.md                # → agents-context/guides/workflow.md
│   │   │   ├── examples/
│   │   │   │   └── readme-filled.md           # Example of a mature README.md
│   │   │   ├── standards-global/              # Global standards (always copied)
│   │   │   │   ├── coding-style.md
│   │   │   │   ├── commenting.md
│   │   │   │   ├── conventions.md
│   │   │   │   ├── error-handling.md
│   │   │   │   └── validation.md
│   │   │   └── standards-testing/             # Testing standards (always copied)
│   │   │       └── test-writing.md
│   │   ├── plan-product/                      # Strategic: product mission
│   │   ├── plan-roadmap/                      # Strategic: feature roadmap
│   │   ├── define-standards/                  # Strategic: coding standards
│   │   ├── create-or-update-concepts/         # Strategic: codebase → concept files
│   │   ├── step1-write-spec/                  # Tactical: requirements → spec
│   │   ├── step2-scope-tasks/                 # Tactical: spec → task groups
│   │   └── step3-implement-tasks/             # Tactical: task execution
├── app/                                       # DEPRECATED (legacy installer source)
├── scripts/                                   # DEPRECATED (legacy installer scripts)
├── tests/                                     # Plugin + legacy tests
├── docs/                                      # GitHub Pages documentation
├── CLAUDE.md                                  # This file — dev instructions for this repo
├── INITIAL_PLAN.md                            # Detailed design plan
├── LICENSE
└── README.md
```

## Key Conventions

- `lead-dev-os/` is the plugin directory — this is what users point `--plugin-dir` at
- Skills are flat under `lead-dev-os/skills/` (no strategic/tactical nesting — plugin requirement)
- All skill cross-references use the `/lead-dev-os:` namespace (e.g., `/lead-dev-os:step1-write-spec`)
- Standards files are bundled inside `lead-dev-os/skills/init/` (no separate content/ directory)
- Templates are co-located with their skills (e.g., `step1-write-spec/template.md`)
- Specs go into `lead-dev-os/specs/` directory in the target project
- No `config.yml` in the plugin — stack selection is handled interactively by `/lead-dev-os:init`
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
