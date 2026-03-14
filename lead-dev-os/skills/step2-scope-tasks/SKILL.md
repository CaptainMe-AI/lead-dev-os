---
name: step2-scope-tasks
description: Break a specification into ordered task groups with explicit context-awareness directives.
disable-model-invocation: true
---

# Step 2: Scope Tasks

Break a specification into ordered task groups with explicit context-awareness directives. **Run this command while in plan mode.**


## Instructions

You are a senior engineer breaking down a spec into implementable task groups. Each group should be an atomic focused unit of work organized by layer (database, API, frontend, etc.) with hierarchical numbered subtasks. Every task group MUST include explicit directives to read and update context files.

## Planning
**Use plan mode per task group when implementing** -- This will allow to further break down the task into sub-tasks and plan them out.

### Phase 1: Load Context

1. **Find the spec folder.** Look for the most recent `lead-dev-os/specs/YYYY-MM-DD-*/` folder, or ask the user which spec to work from.

2. **Read** `spec.md` from the spec folder.

3. **Read** `planning/requirements.md` for additional context.

4. **Read `agents-context/README.md`** — use this index to identify which concept and standard files are relevant to this spec. Load only what you need for the current feature, not everything.

5. **Read the relevant concept and standard files** identified from the README — understand domain knowledge, established patterns, and project conventions that apply to this feature.

6. **Analyze the existing codebase:**
   - Identify files and modules that will be modified
   - Identify patterns to follow for consistency
   - Note any shared utilities or helpers to leverage

### Phase 2: Create Task Groups

Organize tasks into **sequential groups by layer**. Each group builds on the previous one.

Common layer ordering (adapt based on the feature):
1. **Database Layer** — Schema, models, migrations
2. **API Layer** — Endpoints, controllers, services
3. **Frontend Components** — Components, pages, styling
4. **Testing** — Test review & gap analysis (always last)

Each task group uses **hierarchical numbered subtasks**. The parent task (N.0) is the group's completion goal. Subtasks (N.1, N.2, ...) are the steps to achieve it.

For each task group (except the final Testing group), follow a **test-first approach**:
- Subtask N.1 is ALWAYS writing 2-8 focused tests
- The final subtask is ALWAYS ensuring those tests pass
- Tests should cover only critical behaviors, not exhaustive scenarios

The **final task group is always "Test Review & Gap Analysis"**. This group reviews all tests from previous groups, identifies critical gaps, and adds up to 10 additional strategic tests. It does NOT run the entire application test suite — only feature-specific tests.

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

- Organize groups under **layer sections** (### headings) with task groups as #### headings
- Use **hierarchical numbered subtasks** (N.0 parent, N.1, N.2, ... children)
- Subtask N.1 is always **writing 2-8 focused tests** — test only critical behaviors, not exhaustive scenarios
- The final subtask in each group is always **ensuring those specific tests pass** — never run the full test suite
- Each group ends with **Acceptance Criteria** specific to that group
- Each task group MUST have a **1-2 sentence description** immediately after the title — describe WHAT will be delivered, not HOW
- Each task should be **completable in one focused session**
- Tasks must reference **specific files** to create or modify where possible
- The **"Read before starting"** section MUST list all relevant context files — concept files for domain guidance, standard files for conventions
- The **"Update after completing"** section MUST specify which concept files to update or create when new patterns are established
- Groups must have explicit **dependency ordering**
- Context directives reference **general guidance, not code** — concept files describe approaches, conventions, and decision rationale, never code snippets
- The **final group is always "Test Review & Gap Analysis"** — reviews previous tests, fills critical gaps (up to 10 additional tests), runs only feature-specific tests
- Include an **Execution Order** section at the end listing the recommended implementation sequence
- Include an **Overview** section at the top with total task count

### Phase 4: Review & Save

Display the following message to the user:

```
The tasks list has created at `lead-dev-os/specs/YYYY-MM-DD-<spec-name>/tasks.md`.

Review it closely to make sure it all looks good.

NEXT STEP 👉 Run `/lead-dev-os:step3-implement-tasks` with the preferred mode 
```