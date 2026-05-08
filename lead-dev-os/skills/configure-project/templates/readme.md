# {Project Name} Context

This directory contains modular knowledge files that document {Project Name}'s concepts, architecture, and design principles. These files are designed to be:

- **Composable** — Load **only** what you need
- **Self-referencing** — Concepts link to related concepts (see `related:` in each file's YAML frontmatter)
- **Version-controlled** — Track evolution of ideas over time
- **AI-friendly** — Agents can load specific concepts as context

**Quick navigation:**
- **[HOW_TO_CREATE_A_CONCEPT.md](HOW_TO_CREATE_A_CONCEPT.md)** — authoring guide + frontmatter reference
- **[Concept Index](#concept-index)** — every concept file grouped by bucket
- **[Load-When Cheatsheet](#load-when-cheatsheet)** — what to load for a given task

## Product

> Strategic product documents created by `/lead-dev-os:plan-product` and `/lead-dev-os:plan-roadmap`.

<!-- Entries are added automatically by the skills that create these files:
- **[product-mission.md](product/product-mission.md)** — Product mission, vision, target users, and technology stack
- **[product-roadmap.md](product/product-roadmap.md)** — Prioritized feature roadmap with phased milestones
-->

## Directory Layout

Concept files live under `concepts/` in three top-level groups:

| Group | Purpose |
|---|---|
| `concepts/domains/` | Business-logic domains. A concept that spans multiple sources (e.g. `social-publishing` touches backend + jobs + frontend) lives here. |
| `concepts/source/` | Stack-specific concepts tied to a single source app (Rails / Python / TypeScript / etc.). |
| `concepts/shared/` | True cross-cutting concerns (platform overview, infra, shared DB, testing stack). |

Each `.md` file (except this README) carries YAML frontmatter:

```yaml
---
title: "..."                 # quoted; matches H1
source_app: [...]            # array, even with one entry
domain: <one-of>             # primary business-logic domain (single value)
scope: [...]                 # backend | frontend | jobs | webhooks | testing | infra | overview
related: [...]               # other concept basenames (no path, no .md)
load_when:                   # plain-language tasks that should load this file
  - "..."
status: current              # current | draft | deprecated
last_reviewed: YYYY-MM-DD    # bump on every meaningful edit
---
```

For field-by-field semantics, authoring rules, and how agents query these tags, see **[HOW_TO_CREATE_A_CONCEPT.md](HOW_TO_CREATE_A_CONCEPT.md)**.

A file's primary owner determines its folder; `source_app[]` and `related[]` carry the full multi-axis association.

---

## Concept Index

> This section is populated by `/lead-dev-os:create-or-update-concepts` as you build your project. It mirrors the directory layout — Domains, Source, Shared — with a sub-heading per directory.

<!-- Example shape, populated by create-or-update-concepts:

### Domains — business-logic concepts

#### `domains/auth/` — Identity across services

- **[auth.md](concepts/domains/auth/auth.md)** — JWT, OAuth, session validation

#### `domains/billing/` — Stripe-driven subscriptions

- **[subscription-plans-management.md](concepts/domains/billing/subscription-plans-management.md)** — Subscription lifecycle, webhooks, plan resolution

### Source — stack-specific concepts

#### `source/active_snap/` — Rails app

- **[api.md](concepts/source/active_snap/api.md)** — REST API conventions
- **[models.md](concepts/source/active_snap/models.md)** — ActiveRecord entities

### Shared — true cross-cutting

- **[architecture.md](concepts/shared/architecture.md)** — Platform overview, tech stack
- **[dynamodb.md](concepts/shared/dynamodb.md)** — DDB tables, idempotency
-->

---

## Development Standards

Each concept file links to relevant standards in `agents-context/standards/`. These standards define best practices that must be followed:

| Category | Standards |
|----------|-----------|
| **Global** | [coding-style.md](standards/coding-style.md), [commenting.md](standards/commenting.md), [conventions.md](standards/conventions.md), [error-handling.md](standards/error-handling.md), [validation.md](standards/validation.md) |
| **Testing** | [test-writing.md](standards/test-writing.md) |

> Add rows to this table as new standards files are created via `/lead-dev-os:define-standards`.

---

## Load-When Cheatsheet

> **How to use this index:** The Load-When Cheatsheet below is the primary discovery surface — find your task, load the listed files. Each concept file declares its own `scope`, `domain`, `source_app`, and `load_when` in YAML frontmatter; before fully loading a concept body, peek at its frontmatter to confirm it's the right match. The README is the map, the frontmatter is the marker that says "you've arrived at the right place."

> This table is populated by `/lead-dev-os:create-or-update-concepts` from each concept file's `load_when` array. Most rows combine the file declaring the trigger plus 1–3 closely related files.

<!-- Example shape, populated by create-or-update-concepts:

| Task | Load these |
|---|---|
| Onboarding / system map | `shared/architecture.md` |
| Adding a Rails API endpoint | `source/active_snap/api.md`, `domains/auth/auth.md` |
| Stripe webhook handling | `domains/billing/subscription-plans-management.md`, `source/active_snap/background-jobs.md` |
-->

Task groups generated by `/lead-dev-os:step2-scope-tasks` automatically include **"Read before starting"** directives that list exactly which concept and standard files to load.

---

## Contributing

For step-by-step instructions on creating or modifying concept files — including frontmatter field semantics, folder-placement decision tree, link conventions, and the "no source-file copies" rule — see **[HOW_TO_CREATE_A_CONCEPT.md](HOW_TO_CREATE_A_CONCEPT.md)**.

Quick checklist:

| Action | Don't forget |
|---|---|
| New file | Pick folder (domains / source / shared) → frontmatter → body → README index entry → Load-When row → back-references in `related:` of cross-linked files → update `AGENTS.md` only if essential-reading tier |
| Edited file | Bump `last_reviewed` → keep `related:` and prose in sync → run the link-check script in [HOW_TO_CREATE_A_CONCEPT.md](HOW_TO_CREATE_A_CONCEPT.md#8-verify) |
| Code sample | Pattern teaching = OK. Copy of a file body = not OK — replace with `**Source:** [\`path\`](...)` link |

## Philosophy

> "Context engineering isn't about prompt templates — it's about managing modular knowledge as first-class composable primitives."

These concept files allow agents to fetch only the knowledge they need, keeping context windows efficient while maintaining comprehensive project documentation.
