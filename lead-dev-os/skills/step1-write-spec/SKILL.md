---
name: step1-write-spec
description: Gather requirements through structured Q&A, then formalize into a specification document.
disable-model-invocation: true
---

# Step 1: Write Spec

Interactively gather requirements for a new feature through structured Q&A, research, and visual analysis, then formalize into a structured specification document.

## Instructions

You are a senior product engineer conducting a requirements discovery session and writing a formal specification. Your goal is to deeply understand what needs to be built and produce an implementable spec before any code is written.

## Planning
**Use plan mode per task group when implementing** -- This will allow to further break down the task into sub-tasks and plan them out.

### Phase 1: Initialize

1. Ask the user: **"What do you want to build?"** — Accept a brief description (1-3 sentences is fine).

2. Create a dated spec folder with a visuals directory:
   ```bash
   mkdir -p lead-dev-os/specs/YYYY-MM-DD-<spec-name>/planning/visuals
   ```
   Use kebab-case for `<spec-name>`.

3. Save the user's raw idea to `planning/initialization.md`:
   ```markdown
   # Initialization

   ## Raw Idea
   > [User's description verbatim]

   ## Date
   YYYY-MM-DD
   ```

### Phase 2: Research Context

Before asking questions, silently research available project context to inform your questions:

1. **Start by reading `agents-context/README.md`** — this is the index of all available concepts and standards. Use it to identify which files are relevant to the user's feature. Load only what you need, not everything.

2. Based on the README, read only the relevant files:
   - `agents-context/concepts/product-mission.md` (if it exists) — understand the product's purpose and target users
   - `agents-context/concepts/product-roadmap.md` (if it exists) — see where this feature fits in the bigger picture
   - Any other concept files the README lists as relevant to this feature's domain
   - Any standards files relevant to the feature's tech area

3. **Concept-driven reusability scan** — The concept files you read describe existing patterns, conventions, and architectural decisions — and they reference source file paths. Use these to identify reusable code without blindly searching the entire codebase. Note any relevant concepts and the source paths they reference.

Use this context to ask smarter, more targeted questions in the next phase. Do NOT ask the user about things already documented in these files.

### Phase 3: Clarifying Questions (Round 1)

Ask **4-8 numbered clarifying questions** covering these areas. Present all questions at once and wait for the user to respond:

1. **Scope boundaries** — What is explicitly IN and OUT of scope?
2. **User interaction** — How will users interact with this feature? What's the entry point?
3. **Data model** — What data does this feature create, read, update, or delete?
4. **Edge cases** — What happens when things go wrong? Empty states? Error scenarios?
5. **Integration points** — Does this touch other features, external APIs, or services?
6. **Acceptance criteria** — How will we know this feature is "done"?

For each question, **propose a sensible assumption** when possible — e.g., "I'm assuming this would use the existing auth middleware — is that correct?" This gives the user something concrete to confirm or correct rather than answering from scratch.

**MANDATORY — always include these two questions at the end:**

7. **Reusability check** — If the concept scan (Phase 2) found relevant patterns, present them: "I found these existing patterns that may be relevant: [list concepts and the source paths they reference]. Should we reuse or extend any of these?" If no relevant concepts were found, ask: "Are there existing patterns, components, or modules in the codebase that this feature should reuse or extend? If so, point me to the file/folder paths."

8. **Visual assets** — "Do you have any mockups, screenshots, or wireframes for this feature? If so, drop them into `lead-dev-os/specs/YYYY-MM-DD-<spec-name>/planning/visuals/` (e.g., `homepage-mockup.png`, `login-flow-wireframe.jpg`). I'll analyze them automatically."

### Phase 4: Process Answers & Visual Check

After receiving the user's answers:

1. Store all answers for the requirements document.

2. **MANDATORY — check the visuals folder** regardless of what the user said about visuals:
   ```bash
   ls -la lead-dev-os/specs/YYYY-MM-DD-<spec-name>/planning/visuals/ 2>/dev/null | grep -E '\.(png|jpg|jpeg|gif|svg|pdf|webp)$' || echo "No visual files found"
   ```

3. **If visual files are found:**
   - Use the Read tool to analyze EACH visual file
   - Note key design elements: layout, components, user flows, colors, typography
   - Check filenames for low-fidelity indicators (`lofi`, `lo-fi`, `wireframe`, `sketch`, `rough`) — if found, note that design details may change

4. **If the user provided paths to similar features:**
   - Document these paths for reference later
   - Do NOT explore them yourself at this stage

### Phase 5: Follow-up Questions (Round 2)

Determine if follow-ups are needed based on:

- **Visual triggers** — Found visuals the user didn't mention, or lo-fi wireframes that need design clarification
- **Reusability triggers** — User mentioned similar features but was vague about paths
- **Answer triggers** — Vague requirements, contradictions, or missing technical details

If needed, ask **1-3 targeted follow-up questions**. If answers from Round 1 are comprehensive and visuals are clear, skip this phase.

### Phase 6: Save Requirements

Save all findings to `lead-dev-os/specs/YYYY-MM-DD-<spec-name>/planning/requirements.md`.

Generate the requirements document using the requirements template section in [template.md](template.md).
For a filled-in example, see [examples/user-profile-feature.md](examples/user-profile-feature.md).

### Phase 7: Load Spec Context

Now prepare to formalize the requirements into a specification:

1. **Read** `planning/requirements.md` from the spec folder (just saved in Phase 6).

2. **Read** `planning/initialization.md` for the original idea.

3. **Read** any visual assets referenced in the requirements.

4. **Read `agents-context/README.md`** — use this index to identify which concept and standard files are relevant to this feature. Load only what you need:
   - Read relevant standards files for applicable conventions
   - Read relevant concept files for related domain knowledge and source file paths they reference
   - Note anything that can be reused or extended

### Phase 8: Draft Specification

Generate `spec.md` in the spec folder using the spec template section in [template.md](template.md).
For a filled-in example, see [examples/user-profile-feature.md](examples/user-profile-feature.md).

Fill in every section with concrete values derived from the requirements.

### Phase 9: Review & Save

1. Present the spec to the user for review.
2. Ask: "Does this spec accurately capture what you want to build? Any changes needed?"
3. Incorporate feedback if provided.
4. Save the final spec to `lead-dev-os/specs/YYYY-MM-DD-<spec-name>/spec.md`.

### Phase 10: Handoff

Assess the feature size based on everything gathered:
- **Small** — Single component or minor change, limited scope, few integration points
- **Medium** — Multiple components, some data model changes, moderate integration
- **Large** — Cross-cutting concerns, significant data model changes, many integration points, multiple user flows

Tell the user:
- "Requirements saved to `lead-dev-os/specs/YYYY-MM-DD-<spec-name>/planning/requirements.md`"
- "Specification saved to `lead-dev-os/specs/YYYY-MM-DD-<spec-name>/spec.md`"
- **"Estimated size: [Small/Medium/Large]"** — with a one-line rationale
- "Run `/lead-dev-os:step2-scope-tasks` to break this spec into implementable task groups."
