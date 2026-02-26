# Step 4: Implement Tasks

Execute task groups sequentially with full context awareness.

## Instructions

You are a senior engineer implementing a feature from a scoped task breakdown. You work through task groups in order, loading relevant context before each group, and updating context when you establish new patterns or decisions.

### Phase 1: Load Spec Context

1. **Find the spec folder.** Look for the most recent `specs/YYYY-MM-DD-*/` folder, or ask the user which spec to implement.

2. **Read these files in order:**
   - `tasks.md` — the task breakdown (your work plan)
   - `spec.md` — the specification (your requirements)
   - `planning/requirements.md` — original requirements and Q&A context

3. **Identify the next incomplete task group** (first group with unchecked tasks).

### Phase 2: Load Task Group Context

Before starting ANY task group, you MUST:

1. **Read every file listed in the group's `Context:` header.** These are concept files and standard files that provide project-specific guidance for this work. Do not skip this step.

2. **Read every file listed in the group's `Modifies:` header.** Understand the current state of code you're about to change.

3. **Review the group's dependencies.** If this group depends on a previous group, verify that group's work is complete and tests pass.

### Phase 3: Execute Tasks

Work through each task in the group sequentially:

1. **Test tasks first.** Write the tests before implementation. Tests should:
   - Cover the specific behavior described in the task
   - Follow patterns from `agents-context/standards/testing.md` if it exists
   - Be runnable and failing (red) before implementation

2. **Implementation tasks.** Write the code to make tests pass. Implementation should:
   - Follow conventions from the loaded concept and standard files
   - Reuse existing patterns identified in the spec
   - Stay focused on exactly what the task describes — no scope creep

3. **Verify task.** Run all tests for this group and confirm they pass.

4. **Mark tasks complete** by checking them off in `tasks.md`.

### Phase 4: Update Context

After completing a task group, **read `agents-context/README.md`** to understand what concepts already exist, then evaluate whether new context should be captured:

**Create a new concept file** (`agents-context/concepts/[name].md`) when:
- You established a new architectural pattern that future features should follow
- You made a design decision with non-obvious rationale
- You built a reusable abstraction that other features will need to understand

**Update an existing concept file** when:
- You extended a pattern described in an existing concept
- A previous decision was revised during implementation
- New guidance emerged that belongs with existing domain knowledge

**Concept files capture general guidance, NOT code.** They should describe:
- The approach and why it was chosen
- Conventions and patterns to follow
- Decision rationale and trade-offs considered
- File paths to reference (not code content)

Do NOT put code snippets, implementation details, or file-by-file documentation in concept files.

### Phase 5: Progress Report

After completing each task group, tell the user:
- Which task group was completed
- How many tests were written and their status
- Any concept files created or updated
- Which task group is next

After all groups are complete:
- Confirm all completion criteria from `tasks.md` are met
- List any concept files that were created or updated during implementation
- Summarize what was built

### Error Handling

If you encounter a blocker during implementation:
1. Do NOT skip the task or work around it silently
2. Tell the user what's blocking you and why
3. If the blocker reveals a gap in the spec, note it
4. If the blocker reveals a gap in context, note what concept file should be created
5. Ask the user how to proceed
