---
name: step2-scope-tasks
description: Break a specification into ordered task groups with explicit context-awareness directives.
disable-model-invocation: true
---

# Step 2: Scope Tasks

Break a specification into ordered task groups with explicit context-awareness directives.

## Instructions

You are a senior engineer breaking down a spec into implementable task groups. Each group should be a focused unit of work that can be delegated to an AI agent or developer. The key differentiator is that every task group MUST include explicit directives to read and update context files.

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

Organize tasks into **sequential groups by specialization**. Each group builds on the previous one.

Common group ordering (adapt based on the feature):
1. **Data Layer** — Schema, models, migrations
2. **Business Logic** — Services, domain logic, validations
3. **API / Interface** — Endpoints, controllers, routes
4. **Frontend / UI** — Components, pages, styling
5. **Integration** — Connecting pieces, end-to-end flows
6. **Testing & Polish** — Edge cases, error handling, documentation

For each task group, follow a **test-first approach**: write tests before implementation.

### Phase 3: Generate Tasks Document

Create `tasks.md` in the spec folder using the template in [template.md](template.md).
For a filled-in example, see [examples/user-profile-feature.md](examples/user-profile-feature.md).

**CRITICAL: Context Directives**

Every task group MUST include explicit context directives in its header. These directives tell the implementer exactly which concept and standard files to load before starting work, and when to update or create new concept files after completing work.

Example format:

```markdown
## Task Group 1: API Development

**Read before starting:**
- `agents-context/concepts/api-design.md` — understand our API conventions and patterns
- `agents-context/standards/rest-conventions.md` — follow REST naming and response format standards
- `agents-context/standards/testing.md` — follow testing conventions for API specs

**Update after completing:**
- `agents-context/concepts/api-design.md` — if new API patterns or conventions were established
- Create `agents-context/concepts/[new-concept].md` — if a new domain pattern emerged

**Depends on:** None
**Modifies:** [List of files/directories this group touches]

- [ ] **Test:** [Write test for specific behavior]
- [ ] **Implement:** [Implementation task with clear scope]
- [ ] **Verify:** Run tests, confirm all pass
```

If a relevant concept or standard file does NOT yet exist, the directive should say:
- "Create `agents-context/concepts/[name].md` after completing this group if [condition]"

### Rules for Task Groups

- Each group should have **2-8 tasks** (focused, not sprawling)
- Every group starts with **test tasks** before implementation tasks
- Each task should be **completable in one focused session**
- Tasks must reference **specific files** to create or modify where possible
- The **"Read before starting"** section MUST list all relevant context files — concept files for domain guidance, standard files for conventions
- The **"Update after completing"** section MUST specify which concept files to update or create when new patterns are established
- Groups must have explicit **dependency ordering**
- Context directives reference **general guidance, not code** — concept files describe approaches, conventions, and decision rationale, never code snippets

### Phase 4: Review & Save

1. Present the task breakdown to the user.
2. Ask: "Does this task breakdown look right? Any groups to add, remove, or reorder?"
3. Incorporate feedback.
4. Save to `lead-dev-os/specs/YYYY-MM-DD-<spec-name>/tasks.md`.

### Phase 5: Handoff

Tell the user:
- "Tasks saved to `lead-dev-os/specs/YYYY-MM-DD-<spec-name>/tasks.md`"
- "Run `/lead-dev-os:step3-implement-tasks` to begin context-aware implementation, or work through task groups manually."
- "Each group's **Read before starting** section lists the context files to load before beginning."
