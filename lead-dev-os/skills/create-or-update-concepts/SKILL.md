---
name: create-or-update-concepts
description: Scan and analyze the project codebase to create or update concept files in agents-context/concepts/ and update the README index.
disable-model-invocation: true
---

# Create or Update Concepts

Scan and analyze the project codebase to populate `agents-context/concepts/` with concept files that capture project-specific architecture, patterns, and domain knowledge, then keep `agents-context/README.md` in sync.

Concept files are **general guidance**, not code dumps. They describe approaches, conventions, and decision rationale so AI agents working on the project have the right context loaded for each task.

## Working principle: focused, parallel analysis

A single serial walk of the codebase tends to miss things — the model skims, declares "nothing new to add", and stops. This skill avoids that failure mode by:

1. **Reading the handcrafted evidence first.** `CLAUDE.md`, `AGENTS.md`, and top-level `README.md` files are the user's own summaries of what matters. They are primary sources — a concept the user wrote into `CLAUDE.md` is almost certainly one they want captured.
2. **Dispatching focused subagents per area, in parallel.** One subagent per significant top-level directory produces a deep, bounded analysis. Running them in parallel keeps the main context clean and surfaces detail a serial pass would miss.
3. **Requiring a full coverage map before writing anything.** Every significant top-level directory must be mapped to a concept (create, update, or sub-concept) or be explicitly skipped with a reason. "No new concepts needed" is only an acceptable conclusion after building the map, never before.

## Instructions

### Phase 1: Read existing context

**Read `agents-context/README.md` first.** This is the index of current concepts and standards.

If it does not exist, tell the user to run `/lead-dev-os:configure-project` first and stop.

Then gather both sides of the existing context — what's already in `agents-context/`, and what the user has already hand-written about the project:

1. Read each concept file listed in the README under "Core Concepts" and "Domain Concepts".
2. Read the standards files listed under "Development Standards".
3. **Read the target project's handcrafted docs.** These are primary evidence of what the user considers important:
   - `CLAUDE.md` at project root (always, if present)
   - `AGENTS.md` at project root (if present)
   - `README.md` at project root
   - Nested `CLAUDE.md` / `AGENTS.md` / `README.md` inside top-level directories. Find them with:
     ```
     find . -maxdepth 3 \( -name CLAUDE.md -o -name AGENTS.md -o -name README.md \) \
       -not -path '*/node_modules/*' -not -path '*/.git/*' \
       -not -path '*/agents-context/*' -not -path '*/lead-dev-os/*'
     ```

Build a mental map: what concepts already exist, what areas the handcrafted docs describe, and where the obvious gaps are. A topic that appears in `CLAUDE.md` but not in any concept file is a near-certain gap.

### Phase 2: Map the territory

**2a. List top-level structure.**

Run `ls` at the project root. Identify top-level areas that look like real code or infra domains. Skip:
- `node_modules`, `vendor`, `.venv`, build artifacts (`dist`, `build`, `.next`, `cdk.out`)
- Asset-only directories (`public`, `images`, `fonts`) unless they contain meaningful structure
- `agents-context/` and `lead-dev-os/` themselves
- Hidden directories (`.git`, `.github` — though `.github/workflows` may be a concept if CI is significant)

For each remaining top-level area, do a quick peek at package/config files to identify the stack:
- `package.json`, `tsconfig.json` — Node.js / TypeScript
- `requirements.txt`, `pyproject.toml` — Python
- `Gemfile` — Ruby; `Cargo.toml` — Rust; `go.mod` — Go
- `cdk.json`, `serverless.yml`, `*.tf` — Infrastructure as Code
- `Dockerfile`, `docker-compose.yml` — containers

**2b. Dispatch focused subagents per area, in parallel.**

For each significant top-level area identified in 2a, dispatch a codebase-analysis subagent via the Task tool. **Launch them all in a single message so they execute in parallel** — do not dispatch serially.

Use this prompt template for each subagent (fill in the area path and project root):

```
Analyze the directory <ABSOLUTE_PATH> in the project at <PROJECT_ROOT>.

Context: this report will become a concept file for AI agents who will later work
in this area. I need to know what's here and how to work with it — not a
line-by-line description.

Report under 300 words with these sections:

1. Purpose — what this area does, in 1-2 sentences
2. Tech stack — languages, frameworks, key libraries
3. Structure — 5-10 key files or subdirectories, one line each explaining purpose
4. Patterns & conventions — recurring patterns (error handling, testing, API
   style, state management, deployment, etc.). Include the WHY where evident
   from comments or commit history.
5. Integrations — what this area depends on or produces (APIs, queues, DBs,
   other directories in this repo)
6. Gotchas — non-obvious constraints, workarounds, things that would surprise
   someone new to the area. Skip if nothing qualifies.

Also answer: what questions would an AI agent need answered before making
changes here?
```

**Subagent type:** prefer `Explore` (purpose-built for codebase exploration, read-only, bounded token usage). If `codebase-analyzer` is available in the environment it's an even better fit for deep per-area analysis. Fall back to `general-purpose` if neither is available.

Collect the reports. If any report is thin or obviously shallow (e.g. a `src/` with dozens of files summarized in one line), re-dispatch with a narrower prompt targeting the specific gap.

**2c. Cross-check subagent reports against handcrafted docs.**

Compare each subagent report against the `CLAUDE.md` / `AGENTS.md` / `README.md` content from Phase 1. If a handcrafted doc mentions a concern — a specific pattern, a deployment nuance, a gotcha — that the subagent missed, add it to the notes for that area. The user called it out for a reason.

Also check for **cross-cutting concerns** that don't live in a single directory but do appear in handcrafted docs: auth flow, background jobs, observability, deployment. These often deserve their own concept even though they span areas.

### Phase 3: Build the coverage map

Produce a **coverage map** that accounts for every significant top-level area. This is the gate that prevents the skill from silently doing nothing.

Present it to the user as a table:

```
| Area (path)   | Purpose                  | Existing concept  | Proposed action                          |
|---------------|--------------------------|-------------------|------------------------------------------|
| infra/        | AWS CDK IaC              | —                 | CREATE infrastructure.md                 |
| source/       | Static marketing site    | —                 | CREATE website.md                        |
| design/       | Figma exports, mockups   | —                 | SKIP (assets only, no code patterns)     |
| backend/      | Rails API                | architecture.md   | UPDATE architecture.md (add models)      |
| (cross-cut)   | Auth flow across areas   | —                 | CREATE auth.md                           |
```

**Rules:**
- Every top-level area with substantive code must map to a concept (create, update, or sub-concept split) — or be explicitly skipped with a reason.
- If one area is large enough to warrant split files (e.g. `frontend/` → `frontend.md` + `frontend-styling.md` + `frontend-components.md`), propose the split here, not later.
- If handcrafted docs mention a cross-cutting concern that doesn't map to one directory, propose a concept for it (labelled `(cross-cut)` in the Area column).
- "No action needed" for a substantive area requires a written reason (e.g. "already fully covered by existing concept X").

Present the map and wait for the user to approve, modify, or narrow scope before writing any files.

### Phase 4: Create or update concept files

For each approved concept, create or update `agents-context/concepts/{name}.md` using this structure:

```markdown
# {Concept Name}

{1-3 sentence summary of what this concept covers and why it matters to agents
working in this area.}

## Key paths

- `path/to/entry.ts` — entry point / main file
- `path/to/dir/` — {what's in here}
- ...

## Patterns & conventions

{Describe approaches and WHY they were chosen. One short paragraph per pattern.
No code dumps — reference file paths instead.}

## Integrations

{What this area depends on or produces. Link to related concepts where relevant.}

## Gotchas

{Non-obvious constraints, workarounds, or things that have burned people. Skip
this section if nothing qualifies — don't fabricate gotchas to fill the section.}

## Related

- [[other-concept-name]]
- [[another-concept]]
```

**File naming:** kebab-case, descriptive — e.g. `infrastructure.md`, `website.md`, `api-design.md`, `auth-system.md`, `background-jobs.md`.

**When updating an existing file:**
- Read it first.
- Preserve user-added content and refinements — the user may have tuned the file.
- Present proposed additions to the user before writing: *"I'd like to add a section on {topic} to `{name}.md` covering {summary}. OK?"*
- Extend rather than replace.

**What to keep out of concept files:**
- Code snippets that duplicate source files. Reference the path instead.
- File-by-file inventories. Describe patterns, not catalogs.
- Anything already fully covered by a linked standards file — link, don't duplicate.

### Phase 5: Update README.md

Re-read `agents-context/README.md` and update it:

1. **Add new concept entries** under the right section:
   - **Core Concepts** — foundational, needed by most features (architecture, data models, auth, API design)
   - **Domain Concepts** — feature-specific or area-specific (individual domains, integrations, frontend, infra, background work)
2. **Update the "For AI Agents" task-to-concept mapping.** Use the subagent reports to identify task types specific to this codebase — e.g. "Adding a new video platform integration", "Deploying the CDK stack", "Editing the marketing site". Generic task types alone aren't enough; pull real task types from what this project actually does.
3. **Update cross-references.** Each existing concept's "Related:" section should point to any new concept it connects to.
4. **Verify the Development Standards table** reflects all standards files currently in `agents-context/standards/`.

### Phase 6: Summary

Report back:

1. **Concepts created** — list with one-line summary each.
2. **Concepts updated** — list with what changed.
3. **Coverage map recap** — which top-level areas are now covered and which were explicitly skipped.
4. **Suggested next steps:**
   - Review the concept files and refine as needed
   - Run `/lead-dev-os:define-standards` if standards coverage is sparse
   - Run `/lead-dev-os:step1-write-spec` to start a feature using this context
   - Re-run `/lead-dev-os:create-or-update-concepts` after major structural changes
