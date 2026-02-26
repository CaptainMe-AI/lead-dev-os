# CLAUDE.md

Dev instructions for the lead-dev-os repository itself.

## Project

lead-dev-os is a spec & context-driven framework for Claude Code development on large projects. It provides structured commands for product planning, spec writing, task scoping, and context-aware implementation.

## License

MIT License

## Repository Structure

```
lead-dev-os/
├── app/                               # Everything installed into target projects
│   ├── commands/                      # Slash commands (Claude Code skills)
│   │   ├── strategic/                 # High-level planning commands
│   │   │   ├── plan-product.md
│   │   │   ├── plan-roadmap.md
│   │   │   └── define-standards.md
│   │   └── tactical/                  # Spec-driven implementation commands
│   │       ├── step1-shape-spec.md
│   │       ├── step2-define-spec.md
│   │       ├── step3-scope-tasks.md
│   │       └── step4-implement-tasks.md
│   ├── agents-context/                # Modular knowledge base (installed top-level)
│   │   ├── concepts/                  # Project-specific domain knowledge
│   │   ├── standards/                 # Coding standards and conventions
│   │   └── guides/                    # How-to guides for workflows
│   ├── templates/                     # Reusable document templates
│   ├── specs/                         # Generated specs output directory
│   └── CLAUDE.md                      # Framework instructions injected into target project
├── scripts/                           # Installation & setup scripts
│   ├── install.sh                     # Install lead-dev-os into a target project
│   └── common-functions.sh            # Shared shell utilities
├── tests/                             # Tests for the framework itself
├── CLAUDE.md                          # This file — dev instructions for this repo
├── INITIAL_PLAN.md                    # Detailed design plan
├── LICENSE
└── README.md
```

## Key Conventions

- `app/` contains everything that gets copied into target projects via `scripts/install.sh`
- Commands in `app/commands/` are flattened into `.claude/commands/lead-dev-os/` when installed
- `app/agents-context/` is installed as top-level `agents-context/` in the target project
- Templates and specs go into `lead-dev-os/` directory in the target project
- `app/CLAUDE.md` gets appended to the target project's CLAUDE.md

## Workflow (4 steps)

1. `/step1-shape-spec` — Interactive Q&A to gather requirements
2. `/step2-define-spec` — Formalize into structured spec with FR-### requirements
3. `/step3-scope-tasks` — Break into task groups with explicit context directives
4. `/step4-implement-tasks` — Context-aware execution of task groups

## Context Philosophy

Concept files (`agents-context/concepts/`) are general guidance, not code:
- Describe approaches, conventions, and decision rationale
- Reference file paths instead of duplicating code
- Each file covers one concept/feature domain
- Composable — load only what's needed for the current task
