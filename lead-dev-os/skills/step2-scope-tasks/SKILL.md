---
name: step2-scope-tasks
description: Break a specification into ordered task groups with explicit context-awareness directives.
disable-model-invocation: true
---

# Step 2: Scope Tasks

Break a specification into ordered task groups with explicit context-awareness directives.

Phases 1–2 are read-only research; plan mode is optional. If invoked in plan mode, present the task-group outline (groups, dependencies, grouping strategy) as the plan, and write `tasks.md` after the user approves and plan mode exits — file writes are blocked while plan mode is active.

## Instructions

You are a senior engineer breaking down a spec into implementable task groups. Each group is an atomic, focused unit of work — a vertical slice of the feature or a stack layer, per the grouping strategy chosen in Phase 2 — with hierarchical numbered subtasks. Every task group MUST include explicit directives to read and update context files.

Every task group MUST also stand on its own as a **complete user story** — a non-technical stakeholder who understands the feature's goal should be able to read the group and know (a) what value it delivers and (b) what "done" looks like, without reading any code or technical acceptance criteria.

This skill does not write code or implementation plans — it produces `tasks.md` only; execution and per-group planning belong to `/lead-dev-os:step3-implement-tasks`.

### Phase 1: Load Context

1. **Find the spec folder.** Look for the most recent `lead-dev-os/specs/YYYY-MM-DD-*/` folder, or ask the user which spec to work from.

2. **Read** `spec.md` from the spec folder.

3. **Read** `planning/requirements.md` for additional context.

4. **Read `agents-context/README.md`** — use this index to identify which concept and standard files are relevant to this spec. Load only what you need for the current feature, not everything.

5. **Read the relevant concept and standard files** identified from the README — understand domain knowledge, established patterns, and project conventions that apply to this feature.

6. **Analyze the existing codebase — via research subagents, not in this conversation.** A broad codebase scan in the main context crowds out the spec and concept files you just loaded. Dispatch 1–3 read-only research subagents (prefer the `Explore` agent type; fall back to `general-purpose`) in a single parallel batch. Split by area when the feature spans several (e.g. one for backend, one for frontend). Give each a bounded prompt of this shape:

   ```
   In the project at <project-root>, research what <feature summary from
   spec.md> will touch in <area>. Report under 400 words:
   - Files/modules that will need modification, with paths
   - Existing patterns to follow for consistency (name the exemplar files)
   - Shared utilities, helpers, or components to reuse instead of rebuilding
   - Anything that will constrain the task breakdown (migrations,
     feature flags, cross-cutting concerns)
   - Contention hot spots: files that several parts of the feature will
     all need to touch (these force sequential work)
   Do not propose a design — just report what exists.
   ```

   Use the returned reports to ground the task groups. Do not scan the repository yourself beyond the files the reports and concept files point at.

### Phase 2: Create Task Groups

**Choose a grouping strategy first**, and record the choice with a one-line rationale in the Overview section of `tasks.md`:

- **Vertical slices (preferred).** Each group is a thin end-to-end increment — data + logic + UI for one user-visible capability. Choose this whenever the feature decomposes into independently verifiable increments. Two payoffs: every group is demoable at a review gate, and slice groups with no mutual dependency and disjoint file sets can be executed in parallel by `/lead-dev-os:step3-implement-tasks`. Example slices for a profile feature:
  1. **View profile** — read path end-to-end (model, endpoint, page)
  2. **Edit profile** — write path end-to-end (validations, update endpoint, form)
  3. **Avatar upload** — upload flow end-to-end
  4. **Testing** — test review & gap analysis (always last)
- **Layers.** Groups follow the stack: Database → API → Frontend → Testing. Choose this when the data model is the hard part, the feature lives in a single layer, or slices would all contend for the same few files. Trade-off: layer groups form a strict dependency chain — they always execute sequentially, and nothing is user-demoable until the top layer lands.

Whichever strategy you choose, keep each group's `Dependencies:` list minimal and honest — over-declared dependencies serialize execution for no reason. Use the research reports' contention hot spots when carving groups: if two candidate slices would both rewrite the same few files, either merge them or declare the dependency, rather than pretending they're parallel.

Each task group uses **hierarchical numbered subtasks**. The parent task (N.0) is the group's completion goal. Subtasks (N.1, N.2, ...) are the steps to achieve it.

For each task group (except the final Testing group), follow a **test-first approach**:
- Subtask N.1 is ALWAYS writing 2-8 focused tests
- The final subtask is ALWAYS ensuring those tests pass
- Tests should cover only critical behaviors, not exhaustive scenarios

The **final task group is always "Test Review & Gap Analysis"**. This group reviews all tests from previous groups, identifies critical gaps, and adds up to 10 additional strategic tests. Its last subtask is the workflow's **single full-test-suite backstop run** — the only point where the entire suite runs, to catch regressions the feature introduced elsewhere. New failures caused by the feature get fixed; pre-existing failures get reported, not fixed.

### Phase 3: Generate Tasks Document

Create `tasks.md` in the spec folder using the template in [template.md](template.md).
For a filled-in example, see [examples/user-profile-feature.md](examples/user-profile-feature.md).

**CRITICAL: Context Directives**

Every task group MUST include explicit context directives in its header. These directives tell the implementer exactly which concept and standard files to load before starting work, and when to update or create new concept files after completing work.

Example format:

```markdown
### Database Layer

#### Task Group 1: Data Models and Migrations

Set up the database schema and model validations needed to persist user profile data.

**User Story:**
As a registered user, I want my profile details to be saved reliably so that the information I enter is still there when I come back.

**Done when (plain language):**
- The system can store a user's profile information.
- Invalid information (e.g., a blank name) is rejected instead of being saved.
- Saved information can be loaded back exactly as it was entered.

**Read before starting:**
- `agents-context/concepts/[concept].md` — [why this is relevant]
- `agents-context/standards/[standard].md` — [why this is relevant]

**Update after completing:**
- `agents-context/concepts/[concept].md` — if [condition for when to update]
- Create `agents-context/concepts/[new-concept].md` — if [condition for when to create]

**Dependencies:** None

- [ ] 1.0 Complete database layer
  - [ ] 1.1 Write 2-8 focused tests for [Model] functionality
    - Limit to 2-8 highly focused tests maximum
    - Test only critical model behaviors
    - Skip exhaustive coverage of all methods and edge cases
  - [ ] 1.2 Create [Model] with validations
    - Fields: [list]
    - Validations: [list]
    - Reuse pattern from: [existing model if applicable]
  - [ ] 1.3 Ensure tests pass
    - Run ONLY the 2-8 tests written in 1.1
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 1.1 pass
- [Criterion specific to this group]
```

If a relevant concept or standard file does NOT yet exist, the directive should say:
- "Create `agents-context/concepts/[name].md` after completing this group if [condition]"

### Rules for Task Groups

- Organize groups under **theme sections** (### headings — a slice name or a layer name, per the chosen strategy) with task groups as #### headings
- Use **hierarchical numbered subtasks** (N.0 parent, N.1, N.2, ... children)
- Subtask N.1 is always **writing 2-8 focused tests** — test only critical behaviors, not exhaustive scenarios
- The final subtask in each group is always **ensuring those specific tests pass** — never run the full test suite
- Each group ends with **Acceptance Criteria** specific to that group
- Each task group MUST have a **1-2 sentence description** immediately after the title — describe WHAT will be delivered, not HOW
- Each task group MUST include a **User Story** and a **Done when (plain language)** block immediately after the description (before "Read before starting"):
  - The **User Story** uses the form *"As a [persona], I want [outcome] so that [benefit]."* It must be written for a non-technical reader and framed around end-user value — even for backend layers (database, API, services), express the value the layer ultimately enables for a person, not the technical artifact
  - Exception: a pure enabling group (infrastructure or plumbing with no user-visible outcome of its own) MAY instead declare `**User Story:** Enables Group N's story by [one line]` — don't fabricate a persona for plumbing. Vertical-slice groups always get a full story
  - **Done when (plain language)** is a short bulleted list of observable, jargon-free outcomes a non-technical stakeholder could confirm. It is the human-readable counterpart to the technical Acceptance Criteria, not a duplicate of it (no test counts, file names, or framework terms)
- Each task should be **completable in one focused session**
- Tasks must reference **specific files** to create or modify where possible
- The **"Read before starting"** section MUST list all relevant context files — concept files for domain guidance, standard files for conventions
- The **"Update after completing"** section MUST specify which concept files to update or create when new patterns are established
- Groups must have explicit **dependency ordering**
- Context directives reference **general guidance, not code** — concept files describe approaches, conventions, and decision rationale, never code snippets
- The **final group is always "Test Review & Gap Analysis"** — reviews previous tests, fills critical gaps (up to 10 additional tests), runs feature-specific tests, then runs the full test suite ONCE as a final backstop (fix new failures, report pre-existing ones)
- Include an **Execution Order** section at the end listing the recommended implementation sequence, with an **Execution Waves** subsection: waves of groups that can run in parallel during `/lead-dev-os:step3-implement-tasks`. Groups share a wave only when they have no dependency on each other (direct or transitive) AND their expected file sets are disjoint (per the research reports and contention hot spots). When every group depends on the previous one (e.g. layers), say so — one group per wave is an honest answer
- Include an **Overview** section at the top with total task count

### Phase 4: Self-check, Review & Save

Before presenting the result, verify `tasks.md` against the Rules for Task Groups above — every group has description, User Story, Done-when block, context directives, honest Dependencies, test-first subtasks, and Acceptance Criteria; the final group is Test Review & Gap Analysis; Overview records the grouping strategy; Execution Order includes the Execution Waves subsection. Fix any gap before showing the file.

Display the following message to the user:

```
The tasks list has been created at `lead-dev-os/specs/YYYY-MM-DD-<spec-name>/tasks.md`.

Review it closely to make sure it all looks good.

NEXT STEP 👉 Run `/lead-dev-os:step3-implement-tasks` with the preferred mode 
```