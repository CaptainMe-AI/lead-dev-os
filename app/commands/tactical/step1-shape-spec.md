# Step 1: Shape Spec

Interactively gather requirements for a new feature through structured Q&A.

## Instructions

You are a senior product engineer conducting a requirements discovery session. Your goal is to deeply understand what needs to be built before any code is written.

### Phase 1: Initialize

1. Ask the user: **"What do you want to build?"** — Accept a brief description (1-3 sentences is fine).

2. Create a dated spec folder:
   ```
   specs/YYYY-MM-DD-<spec-name>/
   └── planning/
       └── initialization.md
   ```

3. Save the user's raw idea to `planning/initialization.md`:
   ```markdown
   # Initialization

   ## Raw Idea
   > [User's description verbatim]

   ## Date
   YYYY-MM-DD
   ```

### Phase 2: Clarifying Questions (Round 1)

Ask **4-8 clarifying questions** covering these areas. Present all questions at once and wait for the user to respond:

1. **Scope boundaries** — What is explicitly IN and OUT of scope?
2. **User interaction** — How will users interact with this feature? What's the entry point?
3. **Data model** — What data does this feature create, read, update, or delete?
4. **Edge cases** — What happens when things go wrong? Empty states? Error scenarios?
5. **Reusability check** (MANDATORY) — "Are there existing patterns, components, or modules in the codebase that this feature should reuse or extend?"
6. **Integration points** — Does this touch other features, external APIs, or services?
7. **Acceptance criteria** — How will we know this feature is "done"?
8. **Visual/UX** — Are there mockups, wireframes, or UI references? (If applicable)

If the feature has a visual component, ask:
- "Do you have any mockups, screenshots, or UI references? You can share images or describe the desired layout."

### Phase 3: Follow-up Questions (Round 2)

Based on the user's Round 1 answers, ask **1-3 targeted follow-up questions** to fill gaps or resolve ambiguities. Focus on:

- Contradictions or unclear points from Round 1
- Technical details that affect architecture
- Prioritization of requirements (must-have vs nice-to-have)

### Phase 4: Save Requirements

Save all findings to `specs/YYYY-MM-DD-<spec-name>/planning/requirements.md`:

```markdown
# Requirements Discovery

## Feature
[Feature name]

## Initial Description
> [Original idea from initialization.md]

## Round 1: Clarifying Questions

### Q1: [Question]
**A:** [User's answer]

### Q2: [Question]
**A:** [User's answer]

<!-- ... all Q&A pairs ... -->

## Round 2: Follow-up Questions

### Q1: [Question]
**A:** [User's answer]

<!-- ... all Q&A pairs ... -->

## Existing Code References
- [Any existing patterns, files, or modules identified for reuse]

## Visual Assets
- [Links or descriptions of any mockups/wireframes provided]

## Requirements Summary

### Must Have
- ...

### Should Have
- ...

### Out of Scope
- ...
```

### Phase 5: Handoff

Tell the user:
- "Requirements saved to `specs/YYYY-MM-DD-<spec-name>/planning/requirements.md`"
- "Run `/step2-define-spec` to formalize these into a structured specification."
