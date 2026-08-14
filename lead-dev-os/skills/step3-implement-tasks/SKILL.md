---
name: step3-implement-tasks
description: Implement tasks from a scoped task breakdown — parallel executor subagents, per-group verification agents, and adversarial review before delivery.
disable-model-invocation: true
---

# Step 3: Implement Tasks

Execute task groups from a scoped task breakdown. Three modes — Autonomous, Lead-in-the-Loop, Hybrid — trade off speed vs. review.

You are a senior engineer implementing a feature from a scoped task breakdown, acting as the **orchestrator** of a small team of subagents: planners, executors, an implementation-reviewer, a test-verifier, and an adversarial-thinker. Work through task groups in dependency order, loading relevant context before each group and updating context when new patterns emerge. Every group is planned before its code is written — A and H modes pre-generate `plans/group-N.md` files via parallel planner subagents; L mode uses Claude Code's native plan mode at the start of each group. Every group is independently verified before it is committed.

This skill does not write or change specs or task breakdowns — requirements belong to `/lead-dev-os:step1-write-spec` and scoping to `/lead-dev-os:step2-scope-tasks`; when implementation reveals a gap in either, surface it instead of silently expanding scope.

## Process

Work through these steps in order. Read each step file when you reach it, not before.

1. **Load spec context** — [steps/load-context.md](steps/load-context.md): find the spec folder; read `tasks.md`, `spec.md`, and requirements; identify incomplete groups.
2. **Select execution mode** — [steps/select-mode.md](steps/select-mode.md): recommend A / L / H from the spec's size estimate; the user decides.
3. **Pre-execution planning** (modes A and H only; L plans per group during execution) — [steps/pre-plan.md](steps/pre-plan.md): parallel planner subagents write `plans/group-N.md` for every incomplete group, the adversarial-thinker challenges the plan batch, and an execution schedule of parallel waves is derived for user approval.
4. **Execute task groups** — two paths, chosen by mode:
   - **Orchestrated** (A, and H before the checkpoint) — [steps/execute-orchestrated.md](steps/execute-orchestrated.md): a fresh executor subagent per group, independent groups dispatched in parallel waves, each group verified before commit.
   - **Direct** (L, and H at/after the checkpoint) — [steps/execute-direct.md](steps/execute-direct.md): plan and execute each group in the main conversation; verification findings feed the user's review gate.
5. **Finalize** — [steps/finalize.md](steps/finalize.md): adversarial delivery review, the single full-test-suite backstop run, runtime verification, acceptance-criteria check, summary, archive handoff.

Shared procedures used by more than one step:

- [shared/verification-agents.md](shared/verification-agents.md) — the per-group verification pair (implementation-reviewer + test-verifier) and its bounded fix cycle. Read it the first time a group finishes executing.
- [shared/adversarial-agent.md](shared/adversarial-agent.md) — the adversarial-thinker's two prompts (plan challenge, delivery challenge) and how to triage its findings. Read it from the pre-planning and finalize steps.
- [template.md](template.md) — the format of a `plans/group-N.md` file. Planner subagents and L-mode plans both follow it.

## Hard rules (all modes, all steps)

- **Executor subagents never commit** — the orchestrator commits after verifying each group's work. When groups ran in parallel, stage each group's files separately so each group still gets its own atomic commit.
- **Never delete tests, weaken assertions, skip migrations, or use `--no-verify`** to get to green — in your own work or by accepting it from a subagent. Surface the failure instead.
- **Bounded retries everywhere.** Test-failure fixes: 2 attempts. Verification fix cycles: 2 rounds. After the limit, stop and report — the user would rather debug a stuck group with you than inherit silently disabled tests.
- **Check off tasks in `tasks.md` as each completes**, not in a batch at the end. This protects progress if the session is interrupted.

## Error handling

If you hit a blocker the bounded retries can't resolve, or one that doesn't surface as a test failure:

1. Do not skip the task or work around it silently.
2. Tell the user what's blocking you and why.
3. If the blocker exposes a gap in the spec, name the gap.
4. If the blocker exposes a gap in context, name the concept file that should be created.
5. Ask how to proceed before continuing.
