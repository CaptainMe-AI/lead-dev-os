---
name: plan-roadmap
description: Create or update a prioritized product roadmap with phased milestones.
disable-model-invocation: true
---

# Plan Roadmap

Create or update a prioritized product roadmap with phased milestones.

## Instructions

You are a strategic product planner. Help the user create a phased roadmap.

### Phase 1: Context Gathering

1. **Read `agents-context/README.md` first** — use this index to understand what concepts already exist. Then read `agents-context/concepts/product-mission.md` if it exists. If it doesn't, ask the user to run `/plan-product` first or provide a brief product summary.

2. Ask the user:
   - What features or capabilities are most critical for your first release?
   - Are there any hard deadlines or external dependencies? (Launches, integrations, compliance dates)
   - What is your team's capacity? (Solo developer, small team, multiple teams)
   - Are there features you've already started or completed?

### Phase 2: Roadmap Creation

Organize features into phases based on priority, dependencies, and complexity:

```markdown
# Product Roadmap

> Last updated: YYYY-MM-DD
> Based on: [product-mission.md](../../agents-context/concepts/product-mission.md)

## Phase 1: Foundation
**Goal:** [What this phase achieves]
**Target:** [Timeframe or milestone]

| Priority | Feature | Description | Dependencies |
|----------|---------|-------------|--------------|
| P0 | ... | ... | None |
| P0 | ... | ... | ... |
| P1 | ... | ... | ... |

## Phase 2: Core Experience
**Goal:** [What this phase achieves]
**Target:** [Timeframe or milestone]

| Priority | Feature | Description | Dependencies |
|----------|---------|-------------|--------------|
| P0 | ... | ... | Phase 1 |
| P1 | ... | ... | ... |

## Phase 3: Growth & Polish
**Goal:** [What this phase achieves]
**Target:** [Timeframe or milestone]

| Priority | Feature | Description | Dependencies |
|----------|---------|-------------|--------------|
| P1 | ... | ... | Phase 2 |
| P2 | ... | ... | ... |

## Future Considerations
- ...
- ...

## Priority Legend
- **P0:** Must have — blocks release
- **P1:** Should have — significant value
- **P2:** Nice to have — enhances experience
```

### Phase 3: Output

Save the document to `agents-context/concepts/product-roadmap.md`.

Tell the user:
- "Roadmap saved to `agents-context/concepts/product-roadmap.md`"
- Suggest picking a feature from Phase 1 and running `/step1-shape-spec` to begin speccing it out.
