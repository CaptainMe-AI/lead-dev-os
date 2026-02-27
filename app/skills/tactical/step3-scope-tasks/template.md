# Tasks: [Feature Name]

> Spec: [spec-name]
> Generated: YYYY-MM-DD
> Status: Pending

## Task Group 1: [Group Name — e.g., Data Layer]

**Read before starting:**
- `agents-context/standards/[relevant-standard].md` — [why this is relevant]
- `agents-context/concepts/[relevant-concept].md` — [why this is relevant]

**Update after completing:**
- `agents-context/concepts/[concept].md` — if [condition for when to update]
- Create `agents-context/concepts/[new-concept].md` — if [condition for when to create]

**Depends on:** None
**Modifies:** [List of files/directories this group touches]

- [ ] **Test:** [Write test for specific behavior]
- [ ] **Test:** [Write test for edge case]
- [ ] **Implement:** [Implementation task with clear scope]
- [ ] **Implement:** [Implementation task with clear scope]
- [ ] **Verify:** Run tests, confirm all pass

## Task Group 2: [Group Name — e.g., Business Logic]

**Read before starting:**
- `agents-context/standards/[relevant-standard].md` — [why this is relevant]
- `agents-context/concepts/[relevant-concept].md` — [why this is relevant]

**Update after completing:**
- `agents-context/concepts/[concept].md` — if [condition for when to update]

**Depends on:** Task Group 1
**Modifies:** [List of files/directories]

- [ ] **Test:** [Write test for specific behavior]
- [ ] **Test:** [Write test for edge case]
- [ ] **Implement:** [Implementation task with clear scope]
- [ ] **Implement:** [Implementation task with clear scope]
- [ ] **Verify:** Run tests, confirm all pass

## Task Group 3: [Group Name — e.g., API / Interface]

**Read before starting:**
- `agents-context/standards/[relevant-standard].md` — [why this is relevant]
- `agents-context/concepts/[relevant-concept].md` — [why this is relevant]

**Update after completing:**
- `agents-context/concepts/[concept].md` — if [condition for when to update]

**Depends on:** Task Group 2
**Modifies:** [List of files/directories]

- [ ] **Test:** [Write test for specific behavior]
- [ ] **Implement:** [Implementation task with clear scope]
- [ ] **Implement:** [Implementation task with clear scope]
- [ ] **Verify:** Run tests, confirm all pass

## Task Group 4: [Group Name — e.g., Frontend / UI]

**Read before starting:**
- `agents-context/standards/[relevant-standard].md` — [why this is relevant]

**Update after completing:**
- `agents-context/concepts/[concept].md` — if [condition for when to update]

**Depends on:** Task Group 3
**Modifies:** [List of files/directories]

- [ ] **Test:** [Write test for specific behavior]
- [ ] **Implement:** [Implementation task with clear scope]
- [ ] **Verify:** Run tests, confirm all pass

## Dependency Flow

Group 1 → Group 2 → Group 3 → Group 4

## Completion Criteria

- [ ] All tests pass
- [ ] All success criteria from spec.md are met
- [ ] Code follows standards in `agents-context/standards/`
- [ ] Concept files updated/created for any new patterns established
- [ ] No regressions in existing functionality
