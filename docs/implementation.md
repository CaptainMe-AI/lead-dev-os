---
layout: default
title: Implementation
nav_order: 4
---

# Implementation Phase (`/lead-dev-os:step3-implement-tasks`)

The implementation phase executes task groups produced by `/lead-dev-os:step2-scope-tasks`. Each task group contains context directives (which files from `agents-context/` to load) and atomic tasks derived from the spec. Templates and examples are co-located with each skill for reference.

Three execution modes control how much human oversight the AI receives during implementation.

![Implementation modes diagram]({{ site.baseurl }}/assets/images/implementation-diagram.png)

---

## Mode A: Autonomous

All tasks execute sequentially with no human intervention. The agent loads context, implements each task, runs tests, and auto-commits after each one.

```
T1 → T2 → T3 → T4 → T5 → DONE
         (auto-commit after each task)
```

**Best for:** Small features, well-understood domains, no unknowns in the spec. The spec and task definitions are clear enough that the agent can ship without review.

---

## Mode L: Lead-in-the-Loop

The agent implements one task, then pauses and waits for the lead developer to review before continuing. This creates a feedback loop at every task boundary.

```
T1 → [REVIEW] → T2 → [REVIEW] → T3 → [REVIEW] → T4
         ↑                ↑                ↑
      lead reviews     lead reviews     lead reviews
```

At each review gate, the lead can:

- **Visual QA** — Check the UI, behavior, or output matches expectations.
- **Code review** — Inspect the diff via git GUI (e.g., GitLens, GitHub Desktop, `lazygit`).
- **Request changes** — Prompt the agent with modifications, missing edge cases, or corrections. These are "just-in-time" adjustments that stay within the spec's scope.
- **Commit** — Either let the agent auto-commit or commit manually with a curated message.
- **Continue** — Approve and move to the next task.

**Best for:** Complex features, new domains, specs with unknowns, or any work where the lead wants tight control over quality and direction.

---

## Mode H: Hybrid

Implementation starts in autonomous mode and switches to lead-in-the-loop at a defined checkpoint. The lead specifies which task group triggers the handoff.

```
T1 → T2 → T3 ── STOP ── T4 → [REVIEW] → T5 → [REVIEW] → T6
|← autonomous →|        |←────── lead-in-the-loop ──────→|
```

The autonomous portion handles scaffolding, boilerplate, or well-defined setup tasks. The lead takes over at the checkpoint where decisions, integrations, or nuanced implementation begins.

**Best for:** Features where the first N tasks are mechanical (DB migrations, file scaffolding, API stubs) but later tasks require judgment (business logic, UI polish, integration points).

---

## Choosing a Mode

| Signal | Mode |
|--------|------|
| Spec is tight, domain is known, low risk | **Autonomous** |
| New domain, unclear edge cases, high visibility | **Lead-in-the-Loop** |
| Mix of boilerplate + complex logic | **Hybrid** |
| Prototype / spike / throwaway | **Autonomous** |
| Production feature with stakeholder scrutiny | **Lead-in-the-Loop** |

When you run `/lead-dev-os:step3-implement-tasks`, the skill prompts you to select a mode (A / L / H) after loading the spec context. If you choose Hybrid, it also asks which task group number to use as the checkpoint.
