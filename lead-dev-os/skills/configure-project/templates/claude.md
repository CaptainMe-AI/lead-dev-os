## lead-dev-os Framework

This project uses lead-dev-os for spec-driven development. All features go through a structured workflow before implementation.

### Skills

**Strategic (run once or occasionally):**
- `/lead-dev-os:plan-product` — Define product mission, vision, tech stack → `agents-context/product/product-mission.md`
- `/lead-dev-os:plan-roadmap` — Create phased feature roadmap → `agents-context/product/product-roadmap.md`
- `/lead-dev-os:define-standards` — Establish coding & architecture standards → `agents-context/standards/`

**Tactical (run per feature):**
1. `/lead-dev-os:step1-write-spec` — Interactive Q&A + formalize into spec → `lead-dev-os/specs/YYYY-MM-DD-name/spec.md`
2. `/lead-dev-os:step2-scope-tasks` — Break into context-aware task groups → `lead-dev-os/specs/YYYY-MM-DD-name/tasks.md`
3. `/lead-dev-os:step3-implement-tasks` — Context-aware implementation of task groups
4. `/lead-dev-os:step4-archive-spec` — Archive completed spec to `lead-dev-os/specs-archived/`

### Context System

- `agents-context/product/` — Product mission, roadmap, and strategic planning documents
- `agents-context/concepts/` — Project-specific domain knowledge and general guidance (not code)
- `agents-context/standards/` — Coding style, architecture, and testing conventions
- `agents-context/guides/` — Workflow guides

**When implementing task groups**, always read the context files listed in each group's "Read before starting" section. After completing a group, update or create concept files as directed in "Update after completing".

### Important: Context Entry Point

**Before any implementation work**, read `agents-context/README.md` first. It is the index of all available concepts and standards. Use it to determine which files are relevant to the current task, then load only those files. Never scan or read all files in `agents-context/` — the README tells you what exists and what to load.

### Key Principles

- Spec before code — every feature goes through write → scope → implement → archive
- Context-aware — task groups reference concept and standard files for guidance
- Test-first — task groups list test tasks before implementation tasks
- Concept files are general guidance, not code — they describe approaches, conventions, and decision rationale
