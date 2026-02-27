# CLAUDE.md

Dev instructions for the lead-dev-os repository itself.

## Project

lead-dev-os is a spec & context-driven framework for Claude Code development on large projects. It provides structured skills for product planning, spec writing, task scoping, and context-aware implementation.

## License

MIT License

## Terminology

- **target project** — the project where `lead-dev-os` is installed
- **spec** — a feature specification
- **task** — a task to be executed by the AI agent

## Repository Structure

```
lead-dev-os/
├── app/                               # Everything installed into target projects
│   ├── skills/                        # Skills (Claude Code)
│   │   ├── strategic/                 # High-level planning skills
│   │   │   ├── plan-product/
│   │   │   │   ├── SKILL.md
│   │   │   │   ├── template.md
│   │   │   │   └── examples/
│   │   │   ├── plan-roadmap/
│   │   │   │   ├── SKILL.md
│   │   │   │   ├── template.md
│   │   │   │   └── examples/
│   │   │   └── define-standards/
│   │   │       ├── SKILL.md
│   │   │       ├── template.md
│   │   │       └── examples/
│   │   └── tactical/                  # Spec-driven implementation skills
│   │       ├── step1-shape-spec/
│   │       │   ├── SKILL.md
│   │       │   ├── template.md
│   │       │   └── examples/
│   │       ├── step2-define-spec/
│   │       │   ├── SKILL.md
│   │       │   ├── template.md
│   │       │   └── examples/
│   │       ├── step3-scope-tasks/
│   │       │   ├── SKILL.md
│   │       │   ├── template.md
│   │       │   └── examples/
│   │       └── step4-implement-tasks/
│   │           └── SKILL.md
│   ├── agents-context/                # Modular knowledge base (installed top-level)
│   │   ├── concepts/                  # Project-specific domain knowledge
│   │   ├── standards/                 # Coding standards and conventions
│   │   └── guides/                    # How-to guides for workflows
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
- Skills in `app/skills/` are installed as `.claude/skills/<category>/<skill-name>/SKILL.md` in the target project, preserving directory structure
- `app/agents-context/` is installed as top-level `agents-context/` in the target project
- Templates are co-located with their skills (e.g., `step1-shape-spec/template.md`)
- Specs go into `lead-dev-os/specs/` directory in the target project
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
