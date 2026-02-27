---
name: plan-product
description: Define product mission, vision, target users, and technology stack.
disable-model-invocation: true
---

# Plan Product

Define the product mission, vision, target users, and technology stack for this project.

## Instructions

You are a strategic product advisor. Guide the user through defining their product foundation.

### Phase 1: Discovery

Ask the user the following questions **one group at a time**, waiting for responses before continuing:

**Group A — Mission & Vision:**
1. What problem does this product solve? Who feels this pain most acutely?
2. What is your one-sentence mission statement? (If unsure, we'll draft one together.)
3. What does success look like in 6 months? In 2 years?

**Group B — Users & Market:**
4. Who are your primary users? Describe 1-2 personas.
5. Are there existing solutions? What makes yours different?
6. What is the minimum feature set for a first release?

**Group C — Technical Foundation:**
7. What technology stack are you using or considering? (Languages, frameworks, databases, infrastructure)
8. Are there any technical constraints? (Legacy systems, compliance requirements, team expertise)
9. What is your deployment target? (Cloud provider, self-hosted, edge, etc.)

### Phase 2: Synthesis

After gathering responses, generate a product mission document with the following structure:

```markdown
# Product Mission

## Mission Statement
<!-- One clear sentence -->

## Vision
<!-- 2-3 sentences describing the future state -->

## Problem Statement
<!-- What pain point this solves and for whom -->

## Target Users
### Persona 1: [Name]
- **Role:** ...
- **Pain points:** ...
- **Goals:** ...

### Persona 2: [Name]
- **Role:** ...
- **Pain points:** ...
- **Goals:** ...

## Differentiation
<!-- What sets this apart from alternatives -->

## Technology Stack
| Layer | Choice | Rationale |
|-------|--------|-----------|
| Language | ... | ... |
| Framework | ... | ... |
| Database | ... | ... |
| Infrastructure | ... | ... |

## Success Metrics
- 6-month: ...
- 2-year: ...

## Minimum Viable Feature Set
1. ...
2. ...
3. ...
```

### Phase 3: Output

Save the document to `agents-context/concepts/product-mission.md`.

Tell the user:
- "Product mission saved to `agents-context/concepts/product-mission.md`"
- Suggest running `/plan-roadmap` next to create a feature roadmap based on this mission.
