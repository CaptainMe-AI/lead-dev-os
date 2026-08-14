---
layout: default
title: Home
nav_order: 1
---

![lead-dev-os banner]({{ site.baseurl }}/assets/images/banner.png)

# lead-dev-os

`lead-dev-os` is a spec & context-aware agentic kit for Claude Code development on large projects. It provides structured skills for product planning, spec writing, task scoping, and context-aware implementation.
The context of the project is stored under `agents-context/` directory, it is domain specific and an agent is provided only the context it needs to perform its task.

Think about it as a lead developer's main tool for guiding a team of AI agents.
A Lead Developer's primary responsibility is to ensure their team of engineers consistently moves in the right direction, making strategic decisions that benefit the entire project. By closely reviewing each engineer's progress before a feature is completed, the lead developer can identify potential issues early, address them proactively, and guarantee that the final product meets the highest standards of quality and reliability.

---

## Key Principles

### Spec-Driven Development

- Spec is the contract, code follows
- Requirements before implementation, always
- Agents execute against testable acceptance criteria
- Eliminates ambiguity-driven rework

### Context-Aware Implementation

- **Composable** — Load only what you need for the current task
- **Self-referencing** — Concepts link to related concepts
- **Version-controlled** — Track evolution of ideas over time
- **AI-friendly** — Agents load specific concepts as context before working

### PARA for AI Agents

Organization follows the [PARA method](https://www.buildingasecondbrain.com/) adapted for agent workflows — Projects, Areas, Resources, Archives — ordered by actionability.

---

## Quick Start

Inside Claude Code, run:

```
# Add the marketplace and install the plugin (one-time)
/plugin marketplace add CaptainMe-AI/lead-dev-os
/plugin install lead-dev-os@captainme-ai

# Configure your project
/lead-dev-os:configure-project
```

See [Installation]({{ site.baseurl }}/installation) for full details.

---

## Workflow Overview

| Phase | Skill | What it does |
|-------|---------|--------------|
| Write | `/lead-dev-os:step1-write-spec` | Interactive Q&A + formalize into spec with numbered requirements (FR-###) |
| Scope | `/lead-dev-os:step2-scope-tasks` | Break into task groups (vertical slices or layers) with context directives |
| Implement | `/lead-dev-os:step3-implement-tasks` | Orchestrated execution — executor subagents per group, full-suite backstop |
| Archive | `/lead-dev-os:step4-archive-spec` | Archive completed spec and block agent access |
| Utility | `/lead-dev-os:create-pr` | Open a GitHub PR for the current branch with a WHAT-focused description and emoji-prefixed title |

See [Workflow]({{ site.baseurl }}/workflow) for the full 4-step process, and [Implementation]({{ site.baseurl }}/implementation) for execution modes.
