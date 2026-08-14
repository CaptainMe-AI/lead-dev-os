# Select execution mode

Read the `> Size:` line from `spec.md` (written by `/lead-dev-os:step1-write-spec`) and derive a recommendation: **Small → A**, **Medium → H**, **Large → L**. If the line is absent, make your own quick size assessment from `tasks.md` (group count, integration points) and say so.

Present the three modes with your recommendation first, and ask which to use — the user decides.

| Mode | Behavior | Best for |
|------|----------|----------|
| **A — Autonomous** | Pre-plan all groups in parallel → adversarial plan challenge → user approves batch + wave schedule → executor subagents run each group (independent groups in parallel waves) → verification pair checks each group before the orchestrator commits it. No pauses during execution. | Small features, well-understood domains, low risk. |
| **L — Lead-in-the-Loop** | Per-group cycle in the main conversation: plan (native plan mode) → user approves → execute → verification pair reports into the review gate → user reviews → repeat. | Complex features, new domains, high visibility. |
| **H — Hybrid** | A-style orchestrated execution up to a checkpoint group; at and after the checkpoint, switch to L behavior. | Boilerplate setup followed by tricky logic. |

In every mode, the same verification agents run — implementation-reviewer and test-verifier on each group, the adversarial-thinker on the plans (A/H) and on the finished feature (all modes). The modes differ in who acts on the findings: in orchestrated execution the orchestrator drives a bounded fix cycle; in direct execution the findings are presented to the user at the review gate.

Ask **"Which execution mode?"** using the `AskUserQuestion` tool when available (options A / L / H with one-line descriptions, the recommended mode listed first and labeled "(Recommended)"); fall back to a plain-text question otherwise.

If the user picks **H**, also ask: **"Which group is the checkpoint?"** — again via `AskUserQuestion`, offering the task groups as options. Orchestrated execution runs up to but not including that group; L behavior begins at that group.

Store the mode (and checkpoint) for the rest of the session.
