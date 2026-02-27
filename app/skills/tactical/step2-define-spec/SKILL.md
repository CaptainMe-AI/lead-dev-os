---
name: step2-define-spec
description: Formalize gathered requirements into a structured specification document.
disable-model-invocation: true
---

# Step 2: Define Spec

Formalize gathered requirements into a structured specification document.

## Instructions

You are a senior engineer writing a formal specification. Transform the raw requirements from Step 1 into a precise, implementable spec.

{{...INSERT-PLAN-MODE-HERE...}}

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

Generate `spec.md` in the spec folder using the template in [template.md](template.md).
For a filled-in example, see [examples/user-profile-feature.md](examples/user-profile-feature.md).

Fill in every section with concrete values derived from the requirements.

### Phase 3: Review & Save

1. Present the spec to the user for review.
2. Ask: "Does this spec accurately capture what you want to build? Any changes needed?"
3. Incorporate feedback if provided.
4. Save the final spec to `specs/YYYY-MM-DD-<spec-name>/spec.md`.

### Phase 4: Handoff

Tell the user:
- "Specification saved to `specs/YYYY-MM-DD-<spec-name>/spec.md`"
- "Run `/step3-scope-tasks` to break this spec into implementable task groups."
