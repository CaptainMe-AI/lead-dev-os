---
name: create-or-update-concepts
description: Scan and analyze the project codebase to create or update concept files in agents-context/concepts/ and update the README index.
disable-model-invocation: true
---

# Create or Update Concepts

Scan and analyze the project codebase to populate `agents-context/concepts/` with relevant concept files and keep `agents-context/README.md` in sync.

## Instructions

You are a senior engineer analyzing a codebase to capture its architecture, patterns, and domain knowledge as concept files. Concept files provide AI agents with project-specific guidance — they describe approaches and conventions, NOT code.

### Phase 1: Read Existing Context

**Read `agents-context/README.md` first** — use this index to understand what concepts already exist, what standards are established, and how the project is organized.

1. Read each existing concept file listed in the README under "Core Concepts" and "Domain Concepts".
2. Read any standards files that exist in `agents-context/standards/`.
3. Build a mental map of current coverage — what areas of the codebase are already documented as concepts and what gaps exist.

If `agents-context/README.md` does not exist, tell the user to run `/lead-dev-os:configure-project` first and stop.

### Phase 2: Scan Project Structure

Analyze the target project's codebase to understand its architecture:

1. **Directory structure** — `ls` the top-level directories and key subdirectories to understand organization (by feature, by type, domain-driven, etc.).

2. **Tech stack detection** — Read package/config files to identify languages, frameworks, and tooling:
   - `package.json`, `tsconfig.json` (Node.js / TypeScript)
   - `requirements.txt`, `pyproject.toml`, `setup.py` (Python)
   - `Gemfile` (Ruby)
   - `Cargo.toml` (Rust)
   - `go.mod` (Go)
   - `docker-compose.yml`, `Dockerfile` (Infrastructure)
   - `.env.example`, CI config files

3. **Architecture analysis** — Read key source files to understand patterns:
   - Entry points (main files, app initialization)
   - Routing / API layer (routers, controllers, endpoints)
   - Data layer (models, schemas, migrations, ORM config)
   - Service / business logic layer
   - Frontend architecture (components, pages, state management)
   - Background jobs, workers, queues
   - Authentication and authorization
   - Configuration and environment handling

4. **Pattern identification** — Note recurring patterns across the codebase:
   - Error handling approach
   - Logging strategy
   - Testing patterns and test organization
   - API design conventions (REST, GraphQL, RPC)
   - State management approach
   - Deployment and infrastructure patterns

### Phase 3: Identify Concepts

Compare your codebase findings with existing concept files to determine what's missing or outdated.

1. **Categorize identified concepts into:**

   - **Core Concepts** — Foundational to the project, needed by most features:
     - Architecture overview (layers, boundaries, dependencies)
     - Data models and relationships
     - Authentication and authorization
     - API design and conventions

   - **Domain Concepts** — Feature-specific areas:
     - Individual feature domains (e.g., payments, notifications, user management)
     - Integration patterns (third-party APIs, external services)
     - Frontend architecture (if applicable)
     - Background processing (if applicable)

2. **For each proposed concept, note:**
   - What it covers (1-2 sentence summary)
   - Key source file paths that define the pattern
   - Related concepts it connects to

3. **Present the proposed concept list to the user:**

   > I analyzed your codebase and found these areas that should be captured as concepts:
   >
   > **New concepts to create:**
   > - `{name}.md` — {summary}
   >
   > **Existing concepts to update:**
   > - `{name}.md` — {what changed}
   >
   > Which of these should I create/update? (all / select specific ones / skip any?)

4. **Wait for the user to approve** before proceeding to Phase 4.

### Phase 4: Create or Update Concept Files

For each approved concept, create or update `agents-context/concepts/{name}.md`.

**Concept file conventions** (same as `/lead-dev-os:step3-implement-tasks` Phase 5):

- **General guidance, NOT code.** Do not put code snippets, implementation details, or file-by-file documentation in concept files.
- **Describe approaches and why they were chosen.** Explain the pattern, not the syntax.
- **Reference source file paths** instead of duplicating code content.
- **Include conventions and patterns to follow** — what a developer (or agent) should know before working in this area.
- **Include a "Related:" section** linking to other concept files that connect to this one.
- **Single-topic, focused files** — one concept per file, covering one area of the project.

**When creating a new concept file:**
- Use a descriptive kebab-case filename (e.g., `api-design.md`, `data-models.md`, `auth-system.md`)
- Start with a brief overview of what the concept covers
- Describe the patterns and conventions used
- List key file paths for reference
- Add a "Related:" section

**When updating an existing concept file:**
- Preserve user-added content and refinements
- Present additions to the user before writing: "I'd like to add the following to `{name}.md`: {summary}. OK?"
- Extend patterns rather than replacing them
- Update file path references if they've changed

### Phase 5: Update README.md

After creating or updating concept files, **read `agents-context/README.md`** again to get the current state, then update it:

1. **Add new concept entries** under the appropriate section (Core Concepts or Domain Concepts).
2. **Update the "For AI Agents" task-to-concept mapping** section — map common task types to the concepts they should load.
3. **Update cross-references** between related concepts.
4. **Verify the "Development Standards" table** is still accurate.

### Phase 6: Summary

Report what was done:

1. **List all concepts created or updated** with a one-line summary of each.
2. **Show the updated README.md structure** — the concept index sections.
3. **Suggest next steps:**
   - "Review the concept files and refine as needed"
   - "Run `/lead-dev-os:define-standards` to establish coding standards" (if standards are sparse)
   - "Run `/lead-dev-os:step1-write-spec` to start building a feature with this context"
   - "Re-run `/lead-dev-os:create-or-update-concepts` after major changes to keep concepts current"
