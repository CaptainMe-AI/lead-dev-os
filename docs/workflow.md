---
layout: default
title: Workflow
nav_order: 3
---

# Workflow

lead-dev-os uses a 3-step tactical workflow to go from idea to shipped feature. Each step produces an artifact that feeds into the next.

## Getting started (new project)

Run the strategic skills once to establish your project foundation:

```
/lead-dev-os:plan-product          → Defines mission, vision, users, tech stack
/lead-dev-os:define-standards      → Establishes coding style, architecture, testing conventions
/lead-dev-os:plan-roadmap          → Creates prioritized feature roadmap with phases
```

These are one-time setup skills. They populate `agents-context/` with the standards and domain knowledge that all future specs will reference.

---

## Building a feature

Run the tactical skills sequentially for each feature:

### Step 1: Write Spec (`/lead-dev-os:step1-write-spec`)

Interactive Q&A session to gather requirements, then formalizes into a structured spec with numbered requirements (`FR-001`, `FR-002`, etc.). Produces `requirements.md` and `spec.md` — the contract that implementation executes against.

### Step 2: Scope (`/lead-dev-os:step2-scope-tasks`)

Breaks the spec into task groups with explicit context directives. Each task group declares which files from `agents-context/` to load before executing. Produces `tasks.md` with atomic, implementable work items.

### Step 3: Implement (`/lead-dev-os:step3-implement-tasks`)

Context-aware execution of task groups. The agent loads only the context it needs for each task group, implements the code, and runs tests. See [Implementation]({{ site.baseurl }}/implementation) for the three execution modes.

---

## Spec folder structure

Each feature produces a dated folder in `lead-dev-os/specs/`:

```
lead-dev-os/
└── specs/
    └── 2026-02-25-user-auth/
        ├── planning/
        │   ├── initialization.md       # Raw idea captured in Step 1
        │   └── requirements.md         # Structured Q&A from Step 1
        ├── spec.md                     # Formal specification from Step 1
        └── tasks.md                    # Context-aware task groups from Step 2
```

## Context philosophy

The `agents-context/` directory contains an `AGENTS.md` index file that points to `README.md` — the full context documentation index. The README lists all available concepts, standards, and task-to-concept mappings.

Concept files in `agents-context/concepts/` are general guidance, not code:

- Describe approaches, conventions, and decision rationale
- Reference file paths instead of duplicating code
- Each file covers one concept or feature domain
- Composable — load only what's needed for the current task

When implementing features (`/lead-dev-os:step3-implement-tasks`), the agent keeps `agents-context/README.md` in sync whenever new concept files are created or updated.

This keeps agent context windows focused and prevents information overload.
