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

Organize features into phases based on priority, dependencies, and complexity using the template in [template.md](template.md).
For a filled-in example, see [examples/saas-project-tracker.md](examples/saas-project-tracker.md).

### Phase 3: Output

Save the document to `agents-context/concepts/product-roadmap.md`.

Tell the user:
- "Roadmap saved to `agents-context/concepts/product-roadmap.md`"
- Suggest picking a feature from Phase 1 and running `/step1-shape-spec` to begin speccing it out.
