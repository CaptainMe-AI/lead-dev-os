---
name: create-or-update-concepts
description: Scan and analyze the project codebase to create or update concept files in agents-context/concepts/ (organized by domains/, source/, shared/) and update the README index and Load-When Cheatsheet.
disable-model-invocation: true
---

# Create or Update Concepts

Scan and analyze the project codebase to populate `agents-context/concepts/` with concept files that capture project-specific architecture, patterns, and domain knowledge, then keep `agents-context/README.md` in sync.

Concept files are **general guidance**, not code dumps. They describe approaches, conventions, and decision rationale so AI agents working on the project have the right context loaded for each task.

## Directory layout

Concept files live in three buckets under `agents-context/concepts/`:

| Bucket | Purpose | Example |
|---|---|---|
| `domains/<domain>/` | Business-logic concepts that span multiple source apps | `domains/billing/subscription-plans-management.md` |
| `source/<app>/` | Stack-specific concepts tied to a single source app | `source/active_snap/rspec-patterns.md` |
| `shared/` | True cross-cutting concerns (platform overview, infra, shared DB) | `shared/architecture.md` |

A file's primary owner determines its folder; `source_app[]` and `related[]` carry the multi-axis association. Maximum two levels under `concepts/` — don't nest deeper.

## Frontmatter contract

Every concept file opens with YAML frontmatter:

```yaml
---
title: "..."                 # quoted; matches H1
source_app: [...]            # array, even if single value
domain: <one-of>             # single value from the approved domain enum
scope: [...]                 # array from the approved scope enum
related: [...]               # other concept basenames (no path, no .md)
load_when:                   # 2–5 plain-language task triggers
  - "..."
status: current              # current | draft | deprecated
last_reviewed: YYYY-MM-DD
---
```

The frontmatter lets agents and tooling decide whether a concept is relevant *without reading the whole file*. The contract is: the README's Load-When Cheatsheet points at the file, the frontmatter confirms it's the right one, the body explains how.

`agents-context/HOW_TO_CREATE_A_CONCEPT.md` is the canonical authoring reference (laid down by `/lead-dev-os:configure-project`). If it exists in the target project, **read it and defer to it** when its rules diverge from this skill — it's the project's tuned authoring guide.

## Working principle: focused, parallel analysis

A single serial walk of the codebase tends to miss things — the model skims, declares "nothing new to add", and stops. This skill avoids that failure mode by:

1. **Reading the handcrafted evidence first.** `CLAUDE.md`, `AGENTS.md`, and top-level `README.md` files are the user's own summaries of what matters. They are primary sources — a concept the user wrote into `CLAUDE.md` is almost certainly one they want captured.
2. **Dispatching focused subagents per area, in parallel.** One subagent per significant top-level directory produces a deep, bounded analysis. Running them in parallel keeps the main context clean and surfaces detail a serial pass would miss.
3. **Approving enums and a coverage map before writing.** Two explicit gates: (1) the closed enum vocabulary for `source_app` / `domain` / `scope`, and (2) a coverage map that places every concept in a bucket. "No new concepts needed" is only an acceptable conclusion after both gates have run.

## Instructions

### Phase 1: Read existing context

**Read `agents-context/README.md` first.** This is the index of current concepts and standards.

If it does not exist, tell the user to run `/lead-dev-os:configure-project` first and stop.

If it exists but `agents-context/concepts/` is missing the three buckets (`domains/`, `source/`, `shared/`), create them — the user may have configured the project before this layout was introduced.

Then gather both sides of the existing context:

1. **Read `agents-context/HOW_TO_CREATE_A_CONCEPT.md`** if present. This is the project's authoring contract. Note any project-specific enum values, naming conventions, or rules that override this skill's defaults.
2. Read existing concept files referenced by the README's Concept Index — don't scan blindly.
3. Read the standards files listed under "Development Standards".
4. **Read the target project's handcrafted docs.** Primary evidence of what the user considers important:
   - `CLAUDE.md` at project root (always, if present)
   - `AGENTS.md` at project root (if present)
   - `README.md` at project root
   - Nested `CLAUDE.md` / `AGENTS.md` / `README.md` inside top-level directories. Find them with:
     ```
     find . -maxdepth 3 \( -name CLAUDE.md -o -name AGENTS.md -o -name README.md \) \
       -not -path '*/node_modules/*' -not -path '*/.git/*' \
       -not -path '*/agents-context/*' -not -path '*/lead-dev-os/*'
     ```

Build a mental map: existing concepts and their bucket placement, what areas the handcrafted docs describe, where the obvious gaps are. A topic that appears in `CLAUDE.md` but not in any concept file is a near-certain gap.

### Phase 2: Map the territory

**2a. List top-level structure and identify source apps.**

Run `ls` at the project root. Identify top-level areas that look like real code or infra domains. Skip:
- `node_modules`, `vendor`, `.venv`, build artifacts (`dist`, `build`, `.next`, `cdk.out`)
- Asset-only directories (`public`, `images`, `fonts`) unless they contain meaningful structure
- `agents-context/` and `lead-dev-os/` themselves
- Hidden directories (`.git`, `.github` — though `.github/workflows` may be a concept if CI is significant)

For each remaining area, do a quick peek at package/config files to identify the stack:
- `package.json`, `tsconfig.json` — Node.js / TypeScript
- `requirements.txt`, `pyproject.toml` — Python
- `Gemfile` — Ruby; `Cargo.toml` — Rust; `go.mod` — Go
- `cdk.json`, `serverless.yml`, `*.tf` — Infrastructure as Code
- `Dockerfile`, `docker-compose.yml` — containers

**Identify candidate `source_app` values.** Each source app gets its own directory under `concepts/source/<app>/`. Source app candidates come from:
- A `source/` or `apps/` or `services/` or `packages/` parent — each child is a source_app.
- Multiple top-level directories that each carry their own package manifest.
- Distinct deployment units (an `infra/` directory is typically its own source_app even when it deploys other apps).
- Single-app projects: one source_app, named after the project's primary directory or after the project itself.

**2b. Dispatch focused subagents per area, in parallel.**

For each significant top-level area, dispatch a codebase-analysis subagent via the Task tool. **Launch them all in a single message so they execute in parallel** — do not dispatch serially.

Use this prompt template (fill in the area path and project root):

```
Analyze the directory <ABSOLUTE_PATH> in the project at <PROJECT_ROOT>.

Context: this report will become a concept file for AI agents who will later
work in this area. I need to know what's here and how to work with it — not a
line-by-line description.

Report under 300 words with these sections:

1. Purpose — what this area does, in 1–2 sentences
2. Tech stack — languages, frameworks, key libraries
3. Structure — 5–10 key files or subdirectories, one line each explaining purpose
4. Patterns & conventions — recurring patterns (error handling, testing, API
   style, state management, deployment, etc.). Include the WHY where evident
   from comments or commit history.
5. Integrations — what this area depends on or produces (APIs, queues, DBs,
   other directories in this repo)
6. Gotchas — non-obvious constraints, workarounds, things that would surprise
   someone new to the area. Skip if nothing qualifies.

Also identify:
- The source_app this area belongs to (single value, the directory name).
- The business domain(s) the area covers (e.g., auth, billing, video pipeline,
  social publishing, frontend platform, api platform, data, jobs, infra, etc.).
- Whether any concept here is genuinely cross-cutting — touches multiple source
  apps and isn't owned by any one of them. These are candidates for shared/.

Also answer: what questions would an AI agent need answered before making
changes here?
```

**Subagent type:** prefer `Explore` (purpose-built for codebase exploration, read-only, bounded token usage). If `codebase-analyzer` is available it's an even better fit for deep per-area analysis. Fall back to `general-purpose` if neither is available.

Collect the reports. If any report is thin or obviously shallow (e.g. a `src/` with dozens of files summarized in one line), re-dispatch with a narrower prompt targeting the specific gap.

**2c. Cross-check subagent reports against handcrafted docs.**

Compare each subagent report against the `CLAUDE.md` / `AGENTS.md` / `README.md` content from Phase 1. If a handcrafted doc mentions a concern — a specific pattern, a deployment nuance, a gotcha — that the subagent missed, add it to the notes for that area. The user called it out for a reason.

Also identify **cross-cutting concerns** that don't live in a single directory but appear in handcrafted docs: auth flow, background jobs, observability, deployment. These often deserve their own concept even though they span areas — they're candidates for `domains/<domain>/` (if domain-shaped) or `shared/` (if truly platform-wide).

**2d. Synthesize the enums.**

Roll up the reports into three closed enums:

- **`source_app[]`** — every source app the project contains (e.g., `[active_snap, chatbot, infra]`). Values are directory names.
- **`domain[]`** — the business-logic domains worth documenting (e.g., `[auth, billing, video-pipeline, social-publishing, chatbot-runtime, frontend-platform, api-platform, data, jobs, infra, dev-tooling, platform-overview]`). Values are kebab-case slugs.
- **`scope[]`** — start with the standard set: `[backend, frontend, jobs, webhooks, testing, infra, overview]`. Extend only if the project has a genuinely missing axis (rare — most projects fit the standard set).

If `agents-context/HOW_TO_CREATE_A_CONCEPT.md` already declares enums (the project's existing authoring contract), **start from those values** and only propose additions. Don't rename or remove without user approval.

These enums are presented for approval in Phase 3. Once approved, they are **closed** — every concept file's frontmatter must use values from these sets. Any future need for a new value triggers an explicit "should I add `X` to the `domain` enum?" question.

### Phase 3: Approval gates

Two approval gates run together. **Do not write any files until both are approved.**

**Gate 1 — Enum approval.**

Show the proposed enums to the user:

```
source_app: [active_snap, chatbot, infra]
domain:     [auth, billing, video-pipeline, social-publishing, chatbot-runtime,
             frontend-platform, api-platform, data, jobs, infra, dev-tooling,
             platform-overview]
scope:      [backend, frontend, jobs, webhooks, testing, infra, overview]
```

Ask: *"Are these the right enums for this project? Add, remove, or rename any value before I start writing files."*

Wait for explicit approval (or edits) before continuing.

**Gate 2 — Coverage map.**

Produce a coverage map that accounts for every significant top-level area. Every concept must have a folder placement.

Folder placement decision tree (mirrors `HOW_TO_CREATE_A_CONCEPT.md`):

1. Concept describes a **business domain** that touches multiple source apps? → `domains/<domain>/<file>.md`
2. Concept documents **code or conventions specific to one source app**? → `source/<app>/<file>.md`
3. Concept documents a system **every source app participates in** (platform overview, shared DB layer, cross-stack test stack)? → `shared/<file>.md`

Present the map as a table:

```
| Area / Topic              | Folder placement              | Existing concept           | Proposed action                |
|---------------------------|-------------------------------|----------------------------|--------------------------------|
| infra/                    | source/infra/                 | —                          | CREATE infrastructure.md       |
| Stripe billing flow       | domains/billing/              | —                          | CREATE subscription-plans.md   |
| Cross-stack DDB tables    | shared/                       | —                          | CREATE dynamodb.md             |
| backend/ Rails patterns   | source/active_snap/           | rails-best-practices.md    | UPDATE rails-best-practices.md |
| design/                   | (skip)                        | —                          | SKIP (assets only, no patterns)|
```

**Rules:**
- Every top-level area with substantive code maps to a folder placement (or is explicitly skipped with a written reason).
- If one area warrants split files (e.g. `source/active_snap/` → `frontend.md` + `frontend-styling.md` + `frontend-components.md`), propose the split here, not later.
- Cross-cutting concerns named in handcrafted docs propose `shared/` or `domains/<domain>/` placement.
- "No action needed" for a substantive area requires a written reason ("already fully covered by existing concept X").

Wait for the user to approve, modify, or narrow scope before writing any files.

### Phase 4: Create or update concept files

For each approved concept, create or update `agents-context/concepts/{folder}/{name}.md` using this structure:

```markdown
---
title: "{Human-readable concept name}"
source_app: [{app}]
domain: {single-domain-from-enum}
scope: [{scope-tag}, {scope-tag}]
related: [{other-concept-basename}, {another-basename}]
load_when:
  - {Trigger phrase, e.g., "Working on Twelve Labs integration"}
  - {Another trigger, e.g., "Webhook idempotency / DDB lookups"}
status: current
last_reviewed: {YYYY-MM-DD}
---

# {Concept Name}

{One-sentence summary stating what this concept covers.}

## {Section relevant to this concept}

{Describe behaviors, contracts, and invariants in prose. Use Good/Bad pattern
examples — small snippets that *teach* a pattern. Include wire-format examples
(JSON, SSE events, error envelopes) where they ARE the contract. Reference
source files instead of reproducing them.}

## Related concepts

- [other-concept](relative/path/to/other-concept.md) — one-line description
```

#### File naming

- Lowercase, hyphen-separated.
- Match an existing prefix when adding a sibling: `social-media-*`, `frontend-*`, `chatbot-*`, `api-*`.
- Don't include the folder name in the basename (`auth/auth.md`, not `auth/auth-domain.md`).
- The slug should be what other concepts will use in their frontmatter `related:` list.

#### Frontmatter fields

Every field is **required** unless explicitly noted as optional.

- **`title`** (string, **always double-quoted**) — human-readable concept name. Quoting is required even with no special characters; consistency makes the files predictable for tooling.
- **`source_app`** (array) — which source applications this concept documents. Always an array, even with one entry. Use multiple values when the concept genuinely spans apps (e.g. a DDB layer touched by both Rails and Python); use a single value when one app owns the surface and other apps merely interact with it.
- **`domain`** (single string from the approved enum) — the single best-fit business-logic domain. Pick exactly one.
- **`scope`** (array from the approved enum) — which implementation surfaces this concept covers. Answers "if I'm working on backend only, which files matter?".
- **`related`** (array of basenames) — other concept files that cross-reference this one. Basenames only — no paths, no `.md` extension. Stay in sync with the body's "Related concepts" section.
- **`load_when`** (array of plain-language tasks, 2–5 entries) — the canonical "when to load this file" triggers. Action-oriented, no fluff. Avoid vague triggers ("Working with the system" — everything is "working with the system"). Avoid triggers that overlap heavily with another file (decide which file owns the trigger). The README's Load-When Cheatsheet aggregates these across files.
- **`status`** (`current` | `draft` | `deprecated`) — defaults to `current`. Mark `deprecated` only when an architecture has been retired but the file is kept for historical context (link to its replacement).
- **`last_reviewed`** (ISO date `YYYY-MM-DD`) — the date the file was last verified against the codebase. Bump on every meaningful edit. Use today's date from your environment context.
- **`notes`** (optional, free-text) — caveat that doesn't fit the structured fields. Use sparingly; usually a TODO comment in the body is better.

**Strict enums.** Values for `source_app`, `domain`, and `scope` must come from the approved enums. If a concept genuinely needs a new value, **stop and ask the user to extend the enum first** — don't silently invent values. Drift kills the index.

#### Body rules

- H1 matches `title` (without quotes). First sentence states what the concept covers.
- **No source-file copies.** If you find yourself pasting a class body, function body, route table, or factory, replace it with a `**Source:** [path](relative/link)` reference and a one-paragraph behavior summary. Pattern-teaching snippets (10–20 lines that *show a pattern*) are different from copying source — keep those.
- **Wire-format examples are encouraged.** Request/response JSON, SSE events, error envelopes — those *are* the contract, not implementation.
- **Don't copy text from another concept file.** Cross-link instead.

#### Cross-link conventions

- Markdown links between concept files use **relative paths** from the file's location:
  - Same folder: `(other-file.md)`
  - Sibling folder under `domains/`: `(../other-folder/other-file.md)`
  - Across the tree from `domains/X/` to `source/Y/`: `(../../source/Y/other-file.md)`
- For source-code references, use enough `../` to escape `concepts/<folder>/<file>.md` to repo root. Files at depth 2 (`shared/X.md`) need 3 `../`; files at depth 3 (`domains/X/Y.md` or `source/X/Y.md`) need 4 `../`.
- Frontmatter `related:` uses **basenames only** (no path, no `.md`). The body's "Related concepts" section uses full markdown links — keep both in sync.

#### When updating an existing file

- Read it first.
- Preserve user-added content and refinements — the user may have tuned the file. Extend rather than replace.
- Present proposed additions to the user before writing: *"I'd like to add a section on {topic} to `{name}.md` covering {summary}. OK?"*
- **Frontmatter handling:**
  - If the file has frontmatter, preserve user-set values for `status`, `domain`, `load_when`, `scope`, and `source_app`. Bump `last_reviewed` to today's date. Update `related` if you discovered new connections (mirror in the body's "Related concepts").
  - If the file predates frontmatter (no `---` block at the top), back-fill it. Derive `title` from the existing H1, `source_app` and `domain` from the file's content (using the approved enum), and set `last_reviewed` to today. Tell the user when back-filling so they can review.
- If the update changes which tasks should load the file, update `load_when` accordingly — and update the README's Load-When Cheatsheet to match.
- If you remove a duplicated source-code block, log a one-line note when you summarize at the end — that's a quality improvement worth surfacing.

### Phase 5: Update README.md

Re-read `agents-context/README.md` and update it:

1. **Concept Index — grouped by bucket.** Mirror the directory layout:

   ```markdown
   ## Concept Index

   ### Domains — business-logic concepts

   #### `domains/<domain>/` — {one-line description of the domain}

   - **[file-name.md](concepts/domains/<domain>/file-name.md)** — {one-line summary}

   ### Source — stack-specific concepts

   #### `source/<app>/` — {one-line description of the app}

   - **[file-name.md](concepts/source/<app>/file-name.md)** — {one-line summary}

   ### Shared — true cross-cutting

   - **[file-name.md](concepts/shared/file-name.md)** — {one-line summary}
   ```

   Use the file's `title` (from frontmatter) as the foundation; the one-line summary distills the concept's first body sentence into something scannable. Don't duplicate frontmatter fields (`scope`, `domain`, `load_when`) into the README — readers open the file when they need them.

2. **Load-When Cheatsheet.** Aggregate `load_when` entries from all concept files into a single table:

   ```markdown
   ## Load-When Cheatsheet

   | Task | Load these |
   |---|---|
   | {load_when phrase} | `path/to/concept.md`, `path/to/related.md` |
   ```

   This is the **primary discovery surface** for agents — most rows combine the file declaring the trigger plus 1–3 related files an agent will likely also need (consult the file's `related:` array for hints). Group similar triggers and merge rows that point at the same files. The cheatsheet should answer most "what should I load?" questions without further hunting.

3. **Loading rule.** Above the Cheatsheet, include this paragraph (idempotent — leave existing copy in place):

   > **How to use this index:** The Load-When Cheatsheet below is the primary discovery surface — find your task, load the listed files. Each concept file declares its own `scope`, `domain`, `source_app`, and `load_when` in YAML frontmatter; before fully loading a concept body, peek at its frontmatter to confirm it's the right match. The README is the map, the frontmatter is the marker that says "you've arrived at the right place."

4. **Cross-references.** Each existing concept's body "Related concepts" section *and* its frontmatter `related:` list should point to any new concept it connects to. Keep the two in sync.

5. **Development Standards table.** Verify it reflects all standards files currently in `agents-context/standards/`.

### Phase 6: Summary

Report back:

1. **Enums established / extended** — the final `source_app`, `domain`, `scope` values. Note any new values added in this run.
2. **Concepts created** — list with bucket placement and one-line summary: `domains/billing/subscription-plans.md — Stripe subscription lifecycle, webhooks, plan resolution`.
3. **Concepts updated** — list with bucket placement and what changed.
4. **Coverage map recap** — top-level areas now covered, areas explicitly skipped (and the reason).
5. **README updates** — Concept Index entries added, Load-When Cheatsheet rows added or merged.
6. **Suggested next steps:**
   - Review concept files and refine prose / `load_when` triggers
   - Run `/lead-dev-os:define-standards` if standards coverage is sparse
   - Run `/lead-dev-os:step1-write-spec` to start a feature using this context
   - Re-run `/lead-dev-os:create-or-update-concepts` after major structural changes
