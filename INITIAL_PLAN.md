# agents-flight-deck — Initial Plan

## Vision

A spec & context-driven framework for Claude Code development on large projects. Inspired by agent-os v2, spec-kit, and agor's context engineering approach.

---

## Directory Structure

```
agents-flight-deck/
├── .github/
│   ├── CODE_OF_CONDUCT.md
│   └── SECURITY.md
│
├── app/                                # Everything that gets installed into a target project
│   ├── commands/                       # Slash commands (Claude Code skills)
│   │   ├── strategic/                  # High-level planning commands
│   │   │   ├── plan-product.md         # Define product mission, vision, tech stack
│   │   │   ├── plan-roadmap.md         # Create/update product roadmap
│   │   │   └── define-standards.md     # Establish coding & architecture standards
│   │   └── tactical/                   # Spec-driven implementation commands
│   │       ├── step1-shape-spec.md     # Interactive Q&A to gather requirements
│   │       ├── step2-define-spec.md    # Formalize into spec.md
│   │       ├── step3-scope-tasks.md    # Break spec into task groups
│   │       └── step4-implement-tasks.md # Context-aware task implementation
│   ├── context/                        # Modular knowledge base (agor-inspired)
│   │   ├── concepts/                   # Project-specific feature & domain concepts
│   │   ├── standards/                  # Coding standards, conventions, patterns
│   │   └── guides/                     # How-to guides for common workflows
│   ├── templates/                      # Reusable document templates
│   │   ├── spec-template.md            # Spec document structure
│   │   ├── tasks-template.md           # Task groups structure
│   │   └── requirements-template.md    # Requirements gathering structure
│   ├── specs/                          # Generated specs live here (YYYY-MM-DD-name/)
│   └── CLAUDE.md                       # Framework instructions injected into target project
│
├── scripts/                            # Installation & setup scripts
│   ├── install.sh                      # Install agents-flight-deck into a target project
│   └── common-functions.sh             # Shared shell utilities
│
├── tests/                              # Tests for the framework itself
│
├── CLAUDE.md                           # Dev instructions for this repo
├── LICENSE
└── README.md
```

---

## Commands

### Strategic Commands

| Command | Purpose | Output |
|---------|---------|--------|
| `plan-product` | Define product mission, vision, target users | `context/concepts/product-mission.md` |
| `plan-roadmap` | Create prioritized feature roadmap | `context/concepts/product-roadmap.md` |
| `define-standards` | Establish coding style, conventions, architecture | `context/standards/*.md` |

### Tactical Commands

| Step | Command | Purpose |
|------|---------|---------|
| 1 | `step1-shape-spec` | Interactive Q&A to gather requirements (agent-os style back-and-forth) |
| 2 | `step2-define-spec` | Formalize requirements into structured spec.md |
| 3 | `step3-scope-tasks` | Break spec into task groups with explicit context file references |
| 4 | `step4-implement-tasks` | Context-aware task execution |

---

## Tactical Command Details

### step1-shape-spec (identical to agent-os v2)
1. Create dated spec folder: `specs/YYYY-MM-DD-spec-name/`
2. Store raw idea in `planning/initialization.md`
3. Ask 4-8 clarifying questions (mandatory reusability check)
4. Request visual assets if applicable
5. Ask 1-3 follow-ups based on responses
6. Save findings to `planning/requirements.md`
7. Direct user to step2

### step2-define-spec (identical to agent-os v2)
1. Read `planning/requirements.md` and any visuals
2. Search codebase for reusable patterns
3. Generate formal `spec.md` using template
4. Sections: goal, user stories, requirements (FR-###), success criteria, out of scope

### step3-scope-tasks (agent-os v2 + context awareness)
Same as agent-os v2 create-tasks, with this key difference:
- The produced `tasks.md` must include **explicit directives** per task group to:
  - Read relevant concept files from `context/concepts/` before starting
  - Read relevant standard files from `context/standards/` before starting
  - Reference which guides from `context/guides/` apply
- Each task group header lists its required context files
- Example format in tasks.md:
  ```
  ## Task Group: API Development
  **Context:** Read `context/concepts/api-design.md`, `context/standards/rest-conventions.md`
  - [ ] Task 1: ...
  - [ ] Task 2: ...
  ```

### step4-implement-tasks (agent-os v2 + context awareness)
Same as agent-os v2 implement-tasks, with these differences:
- Before starting any task group, **load all context files** listed in that group's header
- After completing a task group, **update or create concept files** if new architectural patterns or decisions were established
- Context-aware means: the implementer uses the concept files as general guidance (not code snippets) to stay aligned with project philosophy and conventions
- If implementation reveals a gap in context, create a new concept file or update an existing one

---

## Context Philosophy (agor-inspired)

Concept files are **project-specific, per-feature/domain knowledge** — not generic architecture docs. They capture the specific guidance and decisions relevant to *this* project.

**What concept files ARE:**
- Project-specific feature guidance (e.g., "how social media posting works in our app")
- Domain-specific best practices relevant to this project (e.g., "rspec external API testing patterns we use")
- Design decisions and their rationale for this project
- Conventions specific to a feature area (e.g., "request specs best practices")

**What concept files are NOT:**
- Code snippets or implementation details (never duplicate code)
- Generic programming advice
- File-by-file documentation of the codebase

**Examples of good concept files:**
- `social-media-posting.md` — how our posting pipeline works, provider abstraction approach, rate limiting strategy
- `external-api-testing.md` — patterns for mocking external APIs in rspec, VCR cassette conventions, when to use webmock vs VCR
- `request-specs.md` — our request spec conventions, authentication helpers, shared examples patterns
- `background-jobs.md` — retry strategy, idempotency approach, error handling conventions for our Sidekiq setup

**Rules:**
- Each file covers one concept/feature domain
- Reference file paths instead of duplicating code
- Self-reference related concepts where relevant
- Keep composable — load only what's needed for the current task

---

## Scripts

### `scripts/install.sh`
Modeled after agent-os installation script. Key behaviors:
- Accepts `--commands-only` flag to update commands without overwriting context/standards
- Accepts `--verbose` flag for detailed output
- Validates it's not running inside the agents-flight-deck repo itself
- Copies `app/` contents into the target project's `agents-flight-deck/` directory
- Installs commands to `.claude/commands/agents-flight-deck/`
- Creates `specs/` directory
- Seeds empty context directories with `.gitkeep`
- Merges or creates `CLAUDE.md` in the target project
- Idempotent — safe to re-run
- Warns before overwriting existing standards/context

### `scripts/common-functions.sh`
Shared utilities: colored output (print_status, print_success, print_error, print_warning), directory creation (ensure_dir), verbose logging.

---

## Templates

### spec-template.md
- Goal (1-2 sentences)
- User Stories (up to 3, Given/When/Then acceptance criteria)
- Requirements (FR-### numbered, "System MUST" language)
- Success Criteria (measurable outcomes)
- Out of Scope

### tasks-template.md
- Task groups by specialization (DB → API → Frontend → Testing)
- Each group: **context file references**, 2-8 focused tests, implementation tasks
- Sequential dependency flow between groups
- Checkbox format for tracking

### requirements-template.md
- Initial description
- Q&A rounds (questions asked, answers received)
- Existing code references
- Visual assets
- Requirements summary

---

## What Gets Installed in a Target Project

When `scripts/install.sh` runs in a target project:

```
target-project/
├── .claude/
│   └── commands/
│       └── agents-flight-deck/               # Slash commands available in Claude Code
│           ├── plan-product.md
│           ├── plan-roadmap.md
│           ├── define-standards.md
│           ├── step1-shape-spec.md
│           ├── step2-define-spec.md
│           ├── step3-scope-tasks.md
│           └── step4-implement-tasks.md
├── agents-flight-deck/
│   ├── context/
│   │   ├── concepts/                  # Empty, populated per-project by user & commands
│   │   ├── standards/                 # Seeded from agents-flight-deck defaults or empty
│   │   └── guides/
│   ├── templates/
│   │   ├── spec-template.md
│   │   ├── tasks-template.md
│   │   └── requirements-template.md
│   └── specs/                         # Empty, populated by tactical commands
└── CLAUDE.md                          # Updated with framework instructions
```
