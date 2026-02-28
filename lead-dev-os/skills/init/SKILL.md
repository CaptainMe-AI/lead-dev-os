---
name: init
description: Initialize lead-dev-os framework in your project — sets up agents-context, specs directory, and CLAUDE.md.
disable-model-invocation: true
---

# Initialize lead-dev-os

Set up the lead-dev-os framework in the current project.

## Instructions

You are a project setup assistant. Initialize the lead-dev-os framework by creating the required directory structure, copying standards from this skill's bundled files, generating guides and config, and configuring the project's CLAUDE.md.

### Phase 1: Check Existing Setup

Check if any lead-dev-os artifacts already exist:
- `agents-context/` directory
- `specs/` directory
- `CLAUDE.md` with `## lead-dev-os Framework` section

If any exist, inform the user what was found and ask: **"Some lead-dev-os artifacts already exist. Should I skip existing files (preserve your changes) or overwrite them with fresh defaults?"**

### Phase 2: Ask About Technology Stack

Ask the user: **"What technology stacks does your project use? Select all that apply:"**

Present these categories:
- **Languages:** Python, Ruby, TypeScript, JavaScript
- **Backend frameworks:** FastAPI, Django, Rails, Express
- **Databases:** PostgreSQL, MySQL, MongoDB, Redis
- **Frontend frameworks:** React, Next.js, Vue
- **Infrastructure:** Nginx, Gunicorn, Uvicorn, Docker

This determines which stack-specific standard directories to create. Global standards (coding style, conventions, error handling, commenting, validation) and testing standards are always included.

### Phase 3: Create Directory Structure

Create the following directories:

```bash
mkdir -p agents-context/concepts
mkdir -p agents-context/standards
mkdir -p agents-context/guides
mkdir -p specs
```

### Phase 4: Copy Standards

Locate the skill's bundled standards using the `CLAUDE_PLUGIN_ROOT` environment variable:

```bash
echo ${CLAUDE_PLUGIN_ROOT}
```

**Always copy global standards** from `${CLAUDE_PLUGIN_ROOT}/skills/init/standards-global/` into `agents-context/standards/`:
- `coding-style.md`
- `commenting.md`
- `conventions.md`
- `error-handling.md`
- `validation.md`

**Always copy testing standards** from `${CLAUDE_PLUGIN_ROOT}/skills/init/standards-testing/` into `agents-context/standards/`:
- `test-writing.md`

**For each stack the user selected**, create an empty directory at `agents-context/standards/{stack}/` with a `.gitkeep` file. These directories are placeholders where `/lead-dev-os:define-standards` will generate stack-specific standards.

When copying, use the Read tool to read each file from the skill's standards directory, then use the Write tool to create the file in the project. **Do not overwrite existing files** unless the user chose to overwrite in Phase 1.

### Phase 5: Generate Guides and README

Write `agents-context/guides/workflow.md` with this content:

```markdown
# Workflow Guide

How to use lead-dev-os for spec-driven development.

## Overview

lead-dev-os follows a **write → scope → implement** workflow for building features. This ensures every feature is well-understood before implementation begins, and that implementation stays aligned with project conventions through context files.

## Strategic Skills (Run Once or Occasionally)

These skills establish the project foundation. Run them when starting a new project or when the product direction changes.

| Skill | Purpose | When to Run |
|-------|---------|-------------|
| `/lead-dev-os:plan-product` | Define product mission, vision, users, tech stack | Project kickoff |
| `/lead-dev-os:plan-roadmap` | Create phased feature roadmap | After product mission, or when priorities shift |
| `/lead-dev-os:define-standards` | Establish coding and architecture standards | Project kickoff, or when conventions evolve |

### Recommended order:
1. `/lead-dev-os:plan-product` — Establish what you're building and why
2. `/lead-dev-os:define-standards` — Establish how you build
3. `/lead-dev-os:plan-roadmap` — Plan what to build and when

## Tactical Skills (Run Per Feature)

These skills drive the spec-to-implementation pipeline. Run them sequentially for each feature.

### Step 1: Write Spec (`/lead-dev-os:step1-write-spec`)

**What it does:** Interactive Q&A to deeply understand what needs to be built, then formalizes into a structured specification.

**Inputs:** Your feature idea (1-3 sentences)
**Outputs:** `specs/YYYY-MM-DD-<name>/planning/requirements.md` + `specs/YYYY-MM-DD-<name>/spec.md`

### Step 2: Scope Tasks (`/lead-dev-os:step2-scope-tasks`)

**What it does:** Breaks the spec into ordered task groups with explicit context directives.

**Inputs:** Spec from Step 1 + project standards and concepts
**Outputs:** `specs/YYYY-MM-DD-<name>/tasks.md`

### Step 3: Implement Tasks (`/lead-dev-os:step3-implement-tasks`)

**What it does:** Context-aware execution of task groups from Step 2.

**Inputs:** Tasks from Step 2 + all referenced context files
**Outputs:** Implemented feature + updated/new concept files

## Context System

The `agents-context/` directory is a modular knowledge base that grows with your project.

- **`agents-context/concepts/`** — Project-specific domain knowledge. Captures approaches, conventions, and decision rationale — never code snippets.
- **`agents-context/standards/`** — Coding style, architecture patterns, and testing conventions. Created by `/lead-dev-os:define-standards`.
- **`agents-context/guides/`** — How-to guides for common workflows (like this one).
```

Write `agents-context/README.md` with this content:

```markdown
# Agents Context

This directory contains modular knowledge files that document your project's concepts, architecture, and design principles. These files are designed to be:

- **Composable** — Load only what you need for the current task
- **Self-referencing** — Concepts link to related concepts
- **Version-controlled** — Track evolution of ideas over time
- **AI-friendly** — Agents load specific concepts as context before working

## Available Concepts

> This section is populated as you build your project. Add entries here when creating new concept files.

### Core Concepts

<!-- Example entries (uncomment and adapt as you create files):
- **[architecture.md](concepts/architecture.md)** — System design, tech stack, data flow, service layer patterns
- **[models.md](concepts/models.md)** — Data models, relationships, factories
- **[auth.md](concepts/auth.md)** — Authentication and authorization patterns
-->

### Domain Concepts

<!-- Example entries (uncomment and adapt as you create files):
- **[api.md](concepts/api.md)** — REST API structure, endpoints, request/response formats, error handling
- **[frontend.md](concepts/frontend.md)** — Frontend architecture, component patterns, styling
-->

## Development Standards

Standards are organized by category. Global standards are always included; stack-specific standards are added based on your project's technology stack.

| Category | Standards |
|----------|-----------|
| **Coding Style** | `standards/coding-style.md` |
| **Architecture** | `standards/architecture.md` |
| **Testing** | `standards/testing.md` |

> Standards are installed by running `/lead-dev-os:define-standards`. Add rows to this table as new standards files are added.

## Using Context Files

Task groups generated by `/lead-dev-os:step2-scope-tasks` automatically include **"Read before starting"** directives that list exactly which concept and standard files to load.

## Contributing

When adding new concepts:

1. Create focused, single-topic files (prefer smaller over larger)
2. Use wiki-style links to reference related concepts: `[[concept-name]]`
3. Include a "Related:" section at the top
4. Add an entry to this README under the appropriate section
5. Adding code samples: reference the source file path instead of duplicating code

## Philosophy

> "Context engineering isn't about prompt templates — it's about managing modular knowledge as first-class composable primitives."

Concept files allow agents to fetch only the knowledge they need, keeping context windows efficient while maintaining comprehensive project documentation.
```

### Phase 6: Update CLAUDE.md

Write the following framework instructions to the project's CLAUDE.md:

- If `CLAUDE.md` does not exist in the project root, create it with the content below.
- If `CLAUDE.md` exists but does NOT contain `## lead-dev-os Framework`, append the content below to the end of the file.
- If `CLAUDE.md` exists and already contains `## lead-dev-os Framework`, skip this step (unless the user chose to overwrite).

```markdown
## lead-dev-os Framework

This project uses lead-dev-os for spec-driven development. All features go through a structured workflow before implementation.

### Skills

**Strategic (run once or occasionally):**
- `/lead-dev-os:plan-product` — Define product mission, vision, tech stack → `agents-context/concepts/product-mission.md`
- `/lead-dev-os:plan-roadmap` — Create phased feature roadmap → `agents-context/concepts/product-roadmap.md`
- `/lead-dev-os:define-standards` — Establish coding & architecture standards → `agents-context/standards/`

**Tactical (run per feature):**
1. `/lead-dev-os:step1-write-spec` — Interactive Q&A + formalize into spec → `specs/YYYY-MM-DD-name/spec.md`
2. `/lead-dev-os:step2-scope-tasks` — Break into context-aware task groups → `specs/YYYY-MM-DD-name/tasks.md`
3. `/lead-dev-os:step3-implement-tasks` — Context-aware implementation of task groups

### Context System

- `agents-context/concepts/` — Project-specific domain knowledge and general guidance (not code)
- `agents-context/standards/` — Coding style, architecture, and testing conventions
- `agents-context/guides/` — Workflow guides

**When implementing task groups**, always read the context files listed in each group's "Read before starting" section. After completing a group, update or create concept files as directed in "Update after completing".

### Key Principles

- Spec before code — every feature goes through write → scope → implement
- Context-aware — task groups reference concept and standard files for guidance
- Test-first — task groups list test tasks before implementation tasks
- Concept files are general guidance, not code — they describe approaches, conventions, and decision rationale
```

### Phase 7: Summary

Print a summary of what was created:

```
lead-dev-os initialized successfully!

Created:
  agents-context/
    README.md
    concepts/
    standards/
      coding-style.md
      commenting.md
      conventions.md
      error-handling.md
      validation.md
      test-writing.md
      {stack dirs based on selection}
    guides/
      workflow.md
  specs/
  CLAUDE.md (updated)

Next steps:
  1. Run /lead-dev-os:plan-product to define your product mission
  2. Run /lead-dev-os:define-standards to establish coding standards
  3. Run /lead-dev-os:plan-roadmap to create your feature roadmap
  4. Pick a feature and run /lead-dev-os:step1-write-spec to start building!
```
