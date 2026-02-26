# agents-flight-deck

Command center for spec & context-driven Claude Code development on large projects in a mono repo or just diverse engineering logic.

## Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- A git repository for your target project

### Install into a project

Clone this repo somewhere on your machine, then run the install script from inside your target project:

```bash
# Clone agents-flight-deck (one-time)
git clone https://github.com/your-org/agents-flight-deck.git ~/agents-flight-deck

# Navigate to your project
cd /path/to/your-project

# Run the installer
~/agents-flight-deck/scripts/install.sh
```

### Installer options

```bash
# Full install (commands + context + templates)
~/agents-flight-deck/scripts/install.sh

# Update commands only (preserves your context and standards)
~/agents-flight-deck/scripts/install.sh --commands-only

# Verbose output for debugging
~/agents-flight-deck/scripts/install.sh --verbose
```

The installer is idempotent — safe to re-run. It will:
- Overwrite commands, templates, and guides (framework-managed files)
- Preserve your `agents-context/concepts/` and `agents-context/standards/` content
- Append to your existing `CLAUDE.md` without duplicating if the section already exists

## What gets installed

After running `install.sh` in your project, you'll have:

```
your-project/
│
├── .claude/
│   └── commands/
│       └── agents-flight-deck/                    # Slash commands available in Claude Code
│           ├── plan-product.md             # /plan-product
│           ├── plan-roadmap.md             # /plan-roadmap
│           ├── define-standards.md         # /define-standards
│           ├── step1-shape-spec.md         # /step1-shape-spec
│           ├── step2-define-spec.md        # /step2-define-spec
│           ├── step3-scope-tasks.md        # /step3-scope-tasks
│           └── step4-implement-tasks.md    # /step4-implement-tasks
│
├── agents-context/                         # Top-level knowledge base (grows with your project)
│   ├── concepts/                           # Project-specific domain guidance
│   │   └── .gitkeep                        # Empty — populated by commands and implementation
│   ├── standards/                          # Coding style, architecture, testing conventions
│   │   └── .gitkeep                        # Empty — populated by /define-standards
│   └── guides/
│       └── workflow.md                     # Overview of the shape → define → scope → implement workflow
│
├── agents-flight-deck/
│   ├── templates/                          # Document structure templates
│   │   ├── spec-template.md                # Spec document format
│   │   ├── tasks-template.md               # Task groups format with context directives
│   │   └── requirements-template.md        # Requirements gathering format
│   └── specs/                              # Generated specs live here
│       └── .gitkeep                        # Empty — populated by /step1-shape-spec
│
└── CLAUDE.md                               # Updated with agents-flight-deck framework instructions
```

### What each directory does

| Directory | Purpose | Managed by |
|-----------|---------|------------|
| `.claude/commands/agents-flight-deck/` | Slash commands that appear in Claude Code | Installer (overwritten on update) |
| `agents-context/concepts/` | Project-specific domain knowledge and general guidance | You + commands + implementation |
| `agents-context/standards/` | Coding standards, conventions, architecture patterns | `/define-standards` command |
| `agents-context/guides/` | Workflow documentation | Installer (overwritten on update) |
| `agents-flight-deck/templates/` | Reusable document templates for specs and tasks | Installer (overwritten on update) |
| `agents-flight-deck/specs/` | Dated spec folders created by the tactical workflow | `/step1-shape-spec` and subsequent steps |

### Spec folder structure

Each feature produces a dated folder in `agents-flight-deck/specs/`:

```
agents-flight-deck/specs/
└── 2026-02-25-user-auth/
    ├── planning/
    │   ├── initialization.md       # Raw idea captured in Step 1
    │   └── requirements.md         # Structured Q&A from Step 1
    ├── spec.md                     # Formal specification from Step 2
    └── tasks.md                    # Context-aware task groups from Step 3
```

## Usage

### Getting started (new project)

Run the strategic commands once to establish your project foundation:

```
/plan-product          → Defines mission, vision, users, tech stack
/define-standards      → Establishes coding style, architecture, testing conventions
/plan-roadmap          → Creates prioritized feature roadmap with phases
```

### Building a feature

Run the tactical commands sequentially for each feature:

```
/step1-shape-spec      → Interactive Q&A to gather requirements
/step2-define-spec     → Formalize into spec with numbered requirements (FR-###)
/step3-scope-tasks     → Break into task groups with context directives
/step4-implement-tasks → Context-aware implementation of task groups
```

### Updating commands

When agents-flight-deck releases new command versions, update without touching your project's context:

```bash
~/agents-flight-deck/scripts/install.sh --commands-only
```

## Testing

Tests live in `tests/` and cover both unit and integration behavior of the install script.

### Run all tests

```bash
./tests/test_common_functions.sh && ./tests/test_install_creates.sh && ./tests/test_install_overwrites.sh
```

### Individual test suites

| Suite | File | What it tests |
|-------|------|---------------|
| Unit | `tests/test_common_functions.sh` | `ensure_dir`, `ensure_gitkeep`, `copy_if_not_exists`, `copy_with_warning`, `print_verbose` |
| Integration: creates | `tests/test_install_creates.sh` | Fresh install produces all expected files, `--commands-only` flag, append to existing CLAUDE.md, install without .git |
| Integration: overwrites | `tests/test_install_overwrites.sh` | Re-install overwrites commands/templates/guides, preserves concepts/standards/specs/CLAUDE.md, `--commands-only` only touches commands |

Each test suite creates a temporary directory, runs `install.sh` against it, asserts outcomes, and cleans up. No side effects on your working directory.

### Expected output

```
=== Unit Tests: common-functions.sh ===

test_ensure_dir
  PASS: creates nested directories
  PASS: idempotent on existing directory
test_ensure_gitkeep
  PASS: creates directory
  PASS: creates .gitkeep
  PASS: idempotent .gitkeep
test_copy_if_not_exists
  PASS: copies file when dest missing
  PASS: content matches source
  PASS: does not overwrite existing file
test_copy_with_warning
  PASS: copies when dest missing
  PASS: content matches
  PASS: overwrites existing file
test_print_verbose_respects_flag
  PASS: silent when VERBOSE=false
  PASS: prints when VERBOSE=true

=== Results: 13 passed, 0 failed ===

=== Integration Tests: install.sh (fresh install) ===

test_full_install — fresh install into empty project
  PASS: commands directory exists
  PASS: plan-product.md installed
  PASS: plan-roadmap.md installed
  PASS: define-standards.md installed
  PASS: step1-shape-spec.md installed
  PASS: step2-define-spec.md installed
  PASS: step3-scope-tasks.md installed
  PASS: step4-implement-tasks.md installed
  PASS: exactly 7 command files installed
  PASS: agents-context/ exists
  PASS: agents-context/concepts/ exists
  PASS: agents-context/standards/ exists
  PASS: agents-context/guides/ exists
  PASS: concepts/.gitkeep exists
  PASS: standards/.gitkeep exists
  PASS: workflow.md installed
  PASS: workflow.md has content
  PASS: agents-flight-deck/ exists
  PASS: agents-flight-deck/templates/ exists
  PASS: agents-flight-deck/specs/ exists
  PASS: spec-template.md installed
  PASS: tasks-template.md installed
  PASS: requirements-template.md installed
  PASS: spec-template.md has content
  PASS: specs/.gitkeep exists
  PASS: CLAUDE.md created
  PASS: CLAUDE.md has framework section
test_commands_only_flag — --commands-only skips context/templates
  PASS: commands installed
  PASS: commands installed
  PASS: agents-context/ not created with --commands-only
  PASS: agents-flight-deck/ not created with --commands-only
  PASS: CLAUDE.md not created with --commands-only
test_claude_md_appended_to_existing — appends to existing CLAUDE.md
  PASS: preserves existing content
  PASS: appends framework section
test_no_git_directory_still_works — installs without .git
  PASS: commands still installed
  PASS: agents-context still created

=== Results: 36 passed, 0 failed ===

=== Integration Tests: install.sh (overwrite behavior) ===

test_commands_overwritten — commands are replaced on re-install
  PASS: command overwritten with original
  PASS: user modifications replaced
test_templates_overwritten — templates are replaced on re-install
  PASS: template overwritten
test_guides_overwritten — guides are replaced on re-install
  PASS: guide overwritten
test_concepts_preserved — user concept files survive re-install
  PASS: api-design.md preserved
  PASS: auth.md preserved
  PASS: api-design content intact
  PASS: auth content intact
test_standards_preserved — user standard files survive re-install
  PASS: coding-style.md preserved
  PASS: content intact
test_specs_preserved — user spec folders survive re-install
  PASS: spec.md preserved
  PASS: initialization.md preserved
  PASS: spec content intact
test_claude_md_not_duplicated — CLAUDE.md section not appended twice
  PASS: framework section appears exactly once
  PASS: count is 1
test_commands_only_preserves_everything — --commands-only updates only commands
  PASS: command updated
  PASS: concept preserved
  PASS: guide NOT overwritten
  PASS: template NOT overwritten

=== Results: 19 passed, 0 failed ===
```

## License

MIT License
