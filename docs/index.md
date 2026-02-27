---
layout: default
title: Home
nav_order: 1
---

![lead-dev-os banner]({{ site.baseurl }}/assets/images/banner.png)

# lead-dev-os

`lead-dev-os` is a spec & context-aware agentic kit for Claude Code development on large projects. It provides structured commands for product planning, spec writing, task scoping, and context-aware implementation.
The context of the project is stored under `agents-context/` directory, it is domain specific and an agent is provided only the context it needs to perform its task.

Think about it as a lead developer's main tool for guiding a team of AI agents.
A Lead Developer’s primary responsibility is to ensure their team of engineers consistently moves in the right direction, making strategic decisions that benefit the entire project. By closely reviewing each engineer’s progress before a feature is completed, the lead developer can identify potential issues early, address them proactively, and guarantee that the final product meets the highest standards of quality and reliability.

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

```bash
# Clone lead-dev-os (one-time)
git clone https://github.com/CaptainMe-AI/lead-dev-os.git ~/lead-dev-os

# Navigate to your project
cd /path/to/your-project

# Run the installer
~/lead-dev-os/scripts/install.sh
```

See [Installation]({{ site.baseurl }}/installation) for full details and options.

---

## Workflow Overview

| Phase | Command | What it does |
|-------|---------|--------------|
| Shape | `/step1-shape-spec` | Interactive Q&A to gather requirements |
| Define | `/step2-define-spec` | Formalize into spec with numbered requirements (FR-###) |
| Scope | `/step3-scope-tasks` | Break into task groups with context directives |
| Implement | `/step4-implement-tasks` | Context-aware execution of task groups |

See [Workflow]({{ site.baseurl }}/workflow) for the full 4-step process, and [Implementation]({{ site.baseurl }}/implementation) for execution modes.
