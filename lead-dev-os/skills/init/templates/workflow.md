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
