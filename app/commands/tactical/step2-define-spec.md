# Step 2: Define Spec

Formalize gathered requirements into a structured specification document.

## Instructions

You are a senior engineer writing a formal specification. Transform the raw requirements from Step 1 into a precise, implementable spec.

### Phase 1: Load Context

1. **Find the spec folder.** Look for the most recent `specs/YYYY-MM-DD-*/` folder, or ask the user which spec to formalize if multiple exist.

2. **Read** `planning/requirements.md` from the spec folder.

3. **Read** `planning/initialization.md` for the original idea.

4. **Read** any visual assets referenced in the requirements.

5. **Read `agents-context/README.md`** — use this index to identify which concept and standard files are relevant to this feature. Load only what you need:
   - Read relevant standards files for applicable conventions
   - Read relevant concept files for related domain knowledge and source file paths they reference
   - Note anything that can be reused or extended

### Phase 2: Draft Specification

Generate `spec.md` in the spec folder using the template from `templates/spec-template.md`.

Fill in every section:

```markdown
# Spec: [Feature Name]

> Spec ID: YYYY-MM-DD-<spec-name>
> Status: Draft
> Date: YYYY-MM-DD

## Goal
[1-2 sentences: what this feature does and why it matters]

## User Stories

### Story 1: [Title]
**As a** [user type],
**I want to** [action],
**So that** [benefit].

**Acceptance Criteria:**
- **Given** [precondition], **When** [action], **Then** [expected result]
- **Given** [precondition], **When** [action], **Then** [expected result]

### Story 2: [Title]
...

## Requirements

### Functional Requirements
| ID | Requirement | Priority |
|----|------------|----------|
| FR-001 | System MUST [requirement] | Must |
| FR-002 | System MUST [requirement] | Must |
| FR-003 | System SHOULD [requirement] | Should |

### Non-Functional Requirements
| ID | Requirement | Priority |
|----|------------|----------|
| NFR-001 | System MUST [performance/security/etc requirement] | Must |

## Technical Approach
[High-level approach: what patterns to use, what to extend, key architectural decisions]

### Existing Code to Reuse
- [File/module path]: [What to reuse and how]

## Success Criteria
- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]
- [ ] [Measurable outcome 3]

## Out of Scope
- [Explicitly excluded items]
- [Items deferred to future work]
```

### Phase 3: Review & Save

1. Present the spec to the user for review.
2. Ask: "Does this spec accurately capture what you want to build? Any changes needed?"
3. Incorporate feedback if provided.
4. Save the final spec to `specs/YYYY-MM-DD-<spec-name>/spec.md`.

### Phase 4: Handoff

Tell the user:
- "Specification saved to `specs/YYYY-MM-DD-<spec-name>/spec.md`"
- "Run `/step3-scope-tasks` to break this spec into implementable task groups."
