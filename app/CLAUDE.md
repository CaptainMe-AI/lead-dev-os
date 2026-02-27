## lead-dev-os Framework

This project uses lead-dev-os for spec-driven development. All features go through a structured workflow before implementation.

### Skills

**Strategic (run once or occasionally):**
- `/plan-product` — Define product mission, vision, tech stack → `agents-context/concepts/product-mission.md`
- `/plan-roadmap` — Create phased feature roadmap → `agents-context/concepts/product-roadmap.md`
- `/define-standards` — Establish coding & architecture standards → `agents-context/standards/`

**Tactical (run per feature):**
1. `/step1-write-spec` — Interactive Q&A + formalize into spec → `lead-dev-os/specs/YYYY-MM-DD-name/spec.md`
2. `/step2-scope-tasks` — Break into context-aware task groups → `lead-dev-os/specs/YYYY-MM-DD-name/tasks.md`
3. `/step3-implement-tasks` — Context-aware implementation of task groups

### Context System

- `agents-context/concepts/` — Project-specific domain knowledge and general guidance (not code)
- `agents-context/standards/` — Coding style, architecture, and testing conventions (stack-filtered via `config.default.yml` / `config.local.yml` during install)
- `agents-context/guides/` — Workflow guides

**When implementing task groups**, always read the context files listed in each group's "Read before starting" section. After completing a group, update or create concept files as directed in "Update after completing".

### Key Principles

- Spec before code — every feature goes through write → scope → implement
- Context-aware — task groups reference concept and standard files for guidance
- Test-first — task groups list test tasks before implementation tasks
- Concept files are general guidance, not code — they describe approaches, conventions, and decision rationale
