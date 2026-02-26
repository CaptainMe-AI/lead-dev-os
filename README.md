# 🚀 lead-dev-os 🚀 

<p align="center">
  <img src="images/banner.png" alt="lead-dev-os" width="800">
</p>

[![Tests](https://github.com/CaptainMe-AI/lead-dev-os/actions/workflows/actions.yml/badge.svg)](https://github.com/CaptainMe-AI/lead-dev-os/actions/workflows/actions.yml)
[![Docs](https://img.shields.io/badge/docs-GitHub%20Pages-blue)](https://captainme-ai.github.io/lead-dev-os/)


`lead-dev-os` is a spec & context-aware agentic kit for Claude Code development on large projects. It provides structured commands for product planning, spec writing, task scoping, and context-aware implementation.
The context of the project is stored under `agents-context/` directory, it is domain specific and an agents is provided only the context it needs to perform its task.

Think about it as a lead developer's main tool for guiding a team of AI agents.
A Lead Developer’s primary responsibility is to ensure their team of engineers consistently moves in the right direction, making strategic decisions that benefit the entire project. By closely reviewing each engineer’s progress before a feature is completed, the lead developer can identify potential issues early, address them proactively, and guarantee that the final product meets the highest standards of quality and reliability.

See [Recomendations for Development with `lead-dev-os`](#recomendations-for-development-with-lead-dev-os) for more details.

## Key Principles & Concepts 

### Spec-Driven Development
- Spec is the contract, code follows
- Requirements before implementation, always
- Agents execute against testable acceptance criteria
- Eliminates ambiguity-driven rework
- Inspirations from [agent-os](https://github.com/buildermethods/agent-os) for spec-driven development, file organization and thourough prompting

### Context-aware Implementation
- **Composable** — Load only what you need for the current task
- **Self-referencing** — Concepts link to related concepts
- **Version-controlled** — Track evolution of ideas over time
- **AI-friendly** — Agents load specific concepts as context before working
- Inspirations from [agor](https://github.com/preset-io/agor) for organizing the context

### PARA for AI Agents
- [PARA method from Tiego Forte](https://www.buildingasecondbrain.com/)


## 📖 Documentation

Full documentation is available at [captainme-ai.github.io/lead-dev-os](https://captainme-ai.github.io/lead-dev-os/).

- [Installation](https://captainme-ai.github.io/lead-dev-os/installation) — Prerequisites, installer options, what gets installed
- [Workflow](https://captainme-ai.github.io/lead-dev-os/workflow) — The 4-step shape → define → scope → implement process
- [Implementation](https://captainme-ai.github.io/lead-dev-os/implementation) — Autonomous, lead-in-the-loop, and hybrid execution modes
- [Contributing](https://captainme-ai.github.io/lead-dev-os/contributing) — Testing and how to contribute

## 📦 Installation

```bash
git clone https://github.com/CaptainMe-AI/lead-dev-os.git ~/lead-dev-os
cd /path/to/your-project
~/lead-dev-os/scripts/install.sh
```

See the [Installation Guide](https://captainme-ai.github.io/lead-dev-os/installation) for prerequisites, installer options, and what gets installed.

## 🚀 Usage

Run the strategic commands once to set up your project, then use the tactical workflow for each feature:

```
/step1-shape-spec      → Interactive Q&A to gather requirements
/step2-define-spec     → Formalize into spec with numbered requirements (FR-###)
/step3-scope-tasks     → Break into task groups with context directives
/step4-implement-tasks → Context-aware implementation of task groups
```

See the [Workflow Guide](https://captainme-ai.github.io/lead-dev-os/workflow) for the full process, and [Implementation Modes](https://captainme-ai.github.io/lead-dev-os/implementation) for autonomous, lead-in-the-loop, and hybrid execution.

## 🤝 Contributing

We are open to contributions — please open an issue or a pull request. See the [Contributing Guide](https://captainme-ai.github.io/lead-dev-os/contributing) for testing instructions.

## 📄 License

MIT License
