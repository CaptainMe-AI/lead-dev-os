# Step 1: Shape Spec

Interactively gather requirements for a new feature through structured Q&A, research, and visual analysis.

## Instructions

You are a senior product engineer conducting a requirements discovery session. Your goal is to deeply understand what needs to be built before any code is written.

### Phase 1: Initialize

1. Ask the user: **"What do you want to build?"** — Accept a brief description (1-3 sentences is fine).

2. Create a dated spec folder with a visuals directory:
   ```bash
   mkdir -p specs/YYYY-MM-DD-<spec-name>/planning/visuals
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

8. **Visual assets** — "Do you have any mockups, screenshots, or wireframes for this feature? If so, drop them into `specs/YYYY-MM-DD-<spec-name>/planning/visuals/` (e.g., `homepage-mockup.png`, `login-flow-wireframe.jpg`). I'll analyze them automatically."

### Phase 4: Process Answers & Visual Check

After receiving the user's answers:

1. Store all answers for the requirements document.

2. **MANDATORY — check the visuals folder** regardless of what the user said about visuals:
   ```bash
   ls -la specs/YYYY-MM-DD-<spec-name>/planning/visuals/ 2>/dev/null | grep -E '\.(png|jpg|jpeg|gif|svg|pdf|webp)$' || echo "No visual files found"
   ```

3. **If visual files are found:**
   - Use the Read tool to analyze EACH visual file
   - Note key design elements: layout, components, user flows, colors, typography
   - Check filenames for low-fidelity indicators (`lofi`, `lo-fi`, `wireframe`, `sketch`, `rough`) — if found, note that design details may change

4. **If the user provided paths to similar features:**
   - Document these paths for the spec-writer to reference later
   - Do NOT explore them yourself at this stage

### Phase 5: Follow-up Questions (Round 2)

Determine if follow-ups are needed based on:

- **Visual triggers** — Found visuals the user didn't mention, or lo-fi wireframes that need design clarification
- **Reusability triggers** — User mentioned similar features but was vague about paths
- **Answer triggers** — Vague requirements, contradictions, or missing technical details

If needed, ask **1-3 targeted follow-up questions**. If answers from Round 1 are comprehensive and visuals are clear, skip this phase.

### Phase 6: Save Requirements

Save all findings to `specs/YYYY-MM-DD-<spec-name>/planning/requirements.md`:

```markdown
# Spec Requirements: [Feature Name]

## Initial Description
> [User's original description from initialization.md]

## Requirements Discussion

### First Round Questions

**Q1:** [Question]
**Answer:** [User's answer]

**Q2:** [Question]
**Answer:** [User's answer]

<!-- ... all Q&A pairs ... -->

### Existing Code to Reference

**From Concept Files:**
- Concept: [concept filename] — Related source: `[path referenced in concept]`
- Relevance: [why this pattern applies to the current feature]

**From User Input:**
- Feature: [Name] — Path: `[path]`
- Components to potentially reuse: [description]

[OR: No similar existing features identified for reference.]

### Follow-up Questions

**Follow-up 1:** [Question]
**Answer:** [User's answer]

[OR: No follow-up questions needed.]

## Visual Assets

### Files Provided
[Based on actual bash check, NOT user statement]
- `filename.png`: [Description from analysis]

### Visual Insights
- [Design patterns identified]
- [User flow implications]
- [UI components shown]
- [Fidelity level: high-fidelity mockup / low-fidelity wireframe]

[OR: No visual assets provided.]

## Requirements Summary

### Must Have
- ...

### Should Have
- ...

### Reusability Opportunities
- [Components/patterns that may already exist]
- [Backend patterns to investigate]

### Out of Scope
- ...
```

### Phase 7: Handoff

Assess the feature size based on everything gathered:
- **Small** — Single component or minor change, limited scope, few integration points
- **Medium** — Multiple components, some data model changes, moderate integration
- **Large** — Cross-cutting concerns, significant data model changes, many integration points, multiple user flows

Tell the user:
- "Requirements saved to `specs/YYYY-MM-DD-<spec-name>/planning/requirements.md`"
- **"Estimated size: [Small/Medium/Large]"** — with a one-line rationale
- "Run `/step2-define-spec` to formalize these into a structured specification."
