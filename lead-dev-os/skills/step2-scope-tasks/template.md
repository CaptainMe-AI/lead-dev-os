# Task Breakdown: [Feature Name]

> Spec: [spec-name]
> Generated: YYYY-MM-DD
> Status: Pending

## Overview
Total Tasks: [count]

[brief summary of the task]

## Context Management

### Before Starting Each Task Group
Load relevant concepts from `agents-context/README.md` to understand existing patterns:
- Review the concept files listed in each task group's "Load Concepts" section
- Understand existing patterns before implementing new code

### After Completing Each Task Group
Update relevant concepts in `agents-context/README.md` if applicable:
- Document new fields, endpoints, or component changes added
- Update existing documentation if behavior changed
- Add cross-references to related concepts

## Planning
**Use plan mode per task group when implementing** - This will allow further breakdown of each task into sub-tasks and plan them out.

## Task List

### [Layer Name — e.g., Database Layer]

#### Task Group 1: [Group Name — e.g., Data Models and Migrations]

[1-2 sentence description of WHAT this task group delivers. Focus on the outcome, not implementation details.]

**Read before starting:**
- `agents-context/standards/[relevant-standard].md` — [why this is relevant]
- `agents-context/concepts/[relevant-concept].md` — [why this is relevant]

**Update after completing:**
- `agents-context/concepts/[concept].md` — if [condition for when to update]
- Create `agents-context/concepts/[new-concept].md` — if [condition for when to create]

**Dependencies:** None

- [ ] 1.0 Complete [layer name]
  - [ ] 1.1 Write 2-8 focused tests for [subject] functionality
    - Limit to 2-8 highly focused tests maximum
    - Test only critical behaviors (e.g., primary validation, key association, core method)
    - Skip exhaustive coverage of all methods and edge cases
  - [ ] 1.2 [Implementation task with clear scope]
    - [Detail: fields, validations, patterns to follow]
    - Reuse pattern from: [existing file if applicable]
  - [ ] 1.3 [Implementation task with clear scope]
    - [Detail: indexes, relationships, constraints]
  - [ ] 1.4 Ensure tests pass
    - Run ONLY the 2-8 tests written in 1.1
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 1.1 pass
- [Criterion specific to this group]
- [Criterion specific to this group]

### [Layer Name — e.g., API Layer]

#### Task Group 2: [Group Name — e.g., API Endpoints]

[1-2 sentence description of WHAT this task group delivers. Focus on the outcome, not implementation details.]

**Read before starting:**
- `agents-context/standards/[relevant-standard].md` — [why this is relevant]
- `agents-context/concepts/[relevant-concept].md` — [why this is relevant]

**Update after completing:**
- `agents-context/concepts/[concept].md` — if [condition for when to update]

**Dependencies:** Task Group 1

- [ ] 2.0 Complete [layer name]
  - [ ] 2.1 Write 2-8 focused tests for [subject]
    - Limit to 2-8 highly focused tests maximum
    - Test only critical actions (e.g., primary CRUD operation, auth check, key error case)
    - Skip exhaustive testing of all actions and scenarios
  - [ ] 2.2 [Implementation task with clear scope]
    - [Detail: actions, patterns to follow]
  - [ ] 2.3 [Implementation task with clear scope]
    - [Detail: auth, permissions, error handling]
  - [ ] 2.4 Ensure tests pass
    - Run ONLY the 2-8 tests written in 2.1
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 2.1 pass
- [Criterion specific to this group]
- [Criterion specific to this group]

### [Layer Name — e.g., Frontend Components]

#### Task Group 3: [Group Name — e.g., UI Design]

[1-2 sentence description of WHAT this task group delivers. Focus on the outcome, not implementation details.]

**Read before starting:**
- `agents-context/standards/[relevant-standard].md` — [why this is relevant]

**Update after completing:**
- `agents-context/concepts/[concept].md` — if [condition for when to update]

**Dependencies:** Task Group 2

- [ ] 3.0 Complete [layer name]
  - [ ] 3.1 Write 2-8 focused tests for [subject]
    - Limit to 2-8 highly focused tests maximum
    - Test only critical component behaviors (e.g., primary user interaction, key form submission, main rendering case)
    - Skip exhaustive testing of all component states and interactions
  - [ ] 3.2 [Implementation task with clear scope]
    - [Detail: components, props, state]
  - [ ] 3.3 [Implementation task with clear scope]
    - [Detail: layout, styling, responsiveness]
  - [ ] 3.4 Ensure tests pass
    - Run ONLY the 2-8 tests written in 3.1
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 3.1 pass
- [Criterion specific to this group]
- [Criterion specific to this group]

### Testing

#### Task Group 4: Test Review & Gap Analysis

[1-2 sentence description of WHAT this task group delivers. Focus on the outcome, not implementation details.]

**Read before starting:**
- All context files referenced by Task Groups 1-3

**Update after completing:**
- `agents-context/concepts/[feature-concept].md` — document final patterns and conventions established during implementation

**Dependencies:** Task Groups 1-3

- [ ] 4.0 Review existing tests and fill critical gaps only
  - [ ] 4.1 Review tests from previous Task Groups
    - Review the 2-8 tests from each preceding group
    - Total existing tests: approximately [N] tests
  - [ ] 4.2 Analyze test coverage gaps for THIS feature only
    - Identify critical user workflows that lack test coverage
    - Focus ONLY on gaps related to this spec's feature requirements
    - Do NOT assess entire application test coverage
    - Prioritize end-to-end workflows over unit test gaps
  - [ ] 4.3 Write up to 10 additional strategic tests maximum
    - Add maximum of 10 new tests to fill identified critical gaps
    - Focus on integration points and end-to-end workflows
    - Do NOT write comprehensive coverage for all scenarios
    - Skip edge cases, performance tests, and accessibility tests unless business-critical
  - [ ] 4.4 Run feature-specific tests only
    - Run ONLY tests related to this spec's feature
    - Do NOT run the entire application test suite
    - Verify critical workflows pass

**Acceptance Criteria:**
- All feature-specific tests pass
- Critical user workflows for this feature are covered
- No more than 10 additional tests added when filling gaps
- Testing focused exclusively on this spec's feature requirements

## Execution Order

Recommended implementation sequence:
1. [Layer Name] (Task Group 1)
2. [Layer Name] (Task Group 2)
3. [Layer Name] (Task Group 3)
4. Test Review & Gap Analysis (Task Group 4)
