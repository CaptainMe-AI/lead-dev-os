# Workflow Guide

How to use lead-dev-os for spec-driven development.

## Overview

lead-dev-os follows a **write → scope → implement** workflow for building features. This ensures every feature is well-understood before implementation begins, and that implementation stays aligned with project conventions through context files.

## Strategic Skills (Run Once or Occasionally)

These skills establish the project foundation. Run them when starting a new project or when the product direction changes.

| Skill | Purpose | When to Run |
|-------|---------|-------------|
| `/plan-product` | Define product mission, vision, users, tech stack | Project kickoff |
| `/plan-roadmap` | Create phased feature roadmap | After product mission, or when priorities shift |
| `/define-standards` | Establish coding and architecture standards | Project kickoff, or when conventions evolve |

### Recommended order:
1. `/plan-product` — Establish what you're building and why
2. `/define-standards` — Establish how you build
3. `/plan-roadmap` — Plan what to build and when

## Tactical Skills (Run Per Feature)

These skills drive the spec-to-implementation pipeline. Run them sequentially for each feature.

### Step 1: Write Spec (`/step1-write-spec`)

**What it does:** Interactive Q&A to deeply understand what needs to be built, then formalizes into a structured specification.

**Inputs:** Your feature idea (1-3 sentences)
**Outputs:** `specs/YYYY-MM-DD-<name>/planning/requirements.md` + `specs/YYYY-MM-DD-<name>/spec.md`

**Key behaviors:**
- Creates a dated spec folder
- Asks 4-8 clarifying questions (always includes a reusability check)
- Asks 1-3 follow-up questions based on your answers
- Saves structured requirements
- Searches codebase for reusable patterns
- Generates formal spec with user stories, numbered requirements (FR-###), and success criteria
- Presents for review before saving

### Step 2: Scope Tasks (`/step2-scope-tasks`)

**What it does:** Breaks the spec into ordered task groups with explicit context directives.

**Inputs:** Spec from Step 1 + project standards and concepts
**Outputs:** `specs/YYYY-MM-DD-<name>/tasks.md`

**Key behaviors:**
- Creates task groups by specialization (data → logic → API → UI → testing)
- Each group has a **"Read before starting"** section listing concept and standard files to load
- Each group has an **"Update after completing"** section specifying when to create/update concept files
- Test-first approach: tests come before implementation tasks
- Sequential dependency flow between groups

### Step 3: Implement Tasks (`/step3-implement-tasks`)

**What it does:** Context-aware execution of task groups from Step 2.

**Inputs:** Tasks from Step 2 + all referenced context files
**Outputs:** Implemented feature + updated/new concept files

**Key behaviors:**
- Loads all context files listed in a group's header before starting that group
- Follows test-first execution: write tests, then implement, then verify
- After each group, evaluates whether to create or update concept files
- Reports progress after each group with test status and context changes

## Context System

The `agents-context/` directory is a modular knowledge base that grows with your project.

### `agents-context/concepts/`
Project-specific domain knowledge and general guidance. Captures approaches, conventions, and decision rationale — never code snippets or implementation details. Created by strategic skills and updated during implementation.

### `agents-context/standards/`
Coding style, architecture patterns, and testing conventions. Created by `/define-standards`.

### `agents-context/guides/`
How-to guides for common workflows (like this one).

### What concept files ARE:
- Project-specific feature guidance (e.g., "how our posting pipeline works")
- Domain-specific conventions relevant to this project
- Design decisions and their rationale
- File paths to reference (not code content)

### What concept files are NOT:
- Code snippets or implementation details (never duplicate code)
- Generic programming advice
- File-by-file documentation of the codebase

### How context is used:
- **Task groups reference context files** — each group header lists which files to read before starting and when to update after completing
- **Context grows over time** — as you build features, new concept files capture patterns and decisions
- **Context stays composable** — each file covers one topic, load only what's relevant

## Directory Structure

```
specs/
└── YYYY-MM-DD-feature-name/
    ├── planning/
    │   ├── initialization.md    # Raw idea (Step 1)
    │   └── requirements.md      # Requirements Q&A (Step 1)
    ├── spec.md                  # Formal specification (Step 1)
    └── tasks.md                 # Task groups (Step 2)
```
