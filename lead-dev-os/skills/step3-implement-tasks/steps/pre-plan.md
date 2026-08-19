# Pre-execution planning

*Applies to modes A and H only. L mode plans per group during direct execution — skip this step entirely for L.*

The goal: produce a `plans/group-N.md` file for every incomplete task group before any code is written, pressure-test the batch with the adversarial-thinker, and derive a parallel-wave execution schedule — so the user reviews the whole execution upfront in one batch instead of group-by-group.

## 1. Check for existing plans

If `lead-dev-os/specs/<spec>/plans/` already contains files, ask the user whether to reuse, regenerate, or amend them. Don't silently overwrite plans the user may have edited.

## 2. Spawn planner subagents — one per incomplete group, in parallel

Issue all subagent calls in a single tool-call batch so they run concurrently. Use `subagent_type: "general-purpose"` and give each a self-contained prompt of roughly this shape:

```
You are planning Task Group <N> from <spec-path>/tasks.md.

Read these files first (and only these — don't broadly scan the codebase):
- <spec-path>/tasks.md (focus on Group N's section)
- <spec-path>/spec.md
- agents-context/README.md, then load only the concept/standard files Group N's
  "Read before starting" header names
- Each file Group N will modify or extend, so you know the starting state

Write <spec-path>/plans/group-<N>.md following the plan template at
<plugin-path>/skills/step3-implement-tasks/template.md exactly — every
section (Goal, Sub-tasks, File operations, Test approach, Verification,
Risks) filled with concrete values.

Constraints:
- Do NOT write code or modify any file outside <spec-path>/plans/.
- Stay within the scope of Group N as defined in tasks.md. If you spot a
  missing dependency on another group or a gap in the spec, flag it in
  Risks rather than expanding scope.
- The plan will be read cold by an executor agent; be specific about file
  paths and exact patterns to follow.
```

## 3. Adversarial plan challenge

When all planner subagents return, dispatch the **adversarial-thinker** with the plan-challenge prompt from [../shared/adversarial-agent.md](../shared/adversarial-agent.md). It reads the spec, the task breakdown, and every plan, and hunts for what the planners assumed — unhandled inputs, failure modes, contract mismatches between groups, hidden dependencies.

Triage its findings per that file's guidance: amend plan files directly for clear plan-level fixes, and carry spec-level questions into the report below for the user to rule on.

## 4. Derive the execution schedule

Group the incomplete task groups into **waves**. Two or more groups may share a wave only when BOTH hold:

- **(a) No dependency** between them, directly or transitively, per the `Dependencies:` headers.
- **(b) Disjoint file sets** per the plans' "File operations" sections — no file appears in two plans in the same wave. Two exclusions, both because parallel executors never write these files: `tasks.md` and everything under `agents-context/`. The orchestrator applies each group's checkboxes and context edits itself at commit time, from `plans/group-N-updates.md`, so they cannot clobber each other. **Do not serialize a wave over a shared concept file** — that is a conflict this workflow has already solved, and counting it costs real parallelism. Everything else counts, including test files: a shared test suite two groups both need to repair is a genuine collision.

Start from the Execution Waves subsection in `tasks.md` if present, then validate it against the actual plans — condition (b) can only be confirmed now that plans exist. If the adversarial-thinker flagged a hidden dependency or file contention, respect the flag.

When a wave fails only on condition (b), try to fix the contention before serializing:

- If `tasks.md` carries a **file-ownership rule** naming a single owner for the contended file, amend the non-owner's plan to drop the edit (declaring a dependency on the owner if it genuinely needs it) rather than splitting the wave.
- If the contended file is a shared test suite whose assertions separate cleanly along group boundaries, amending one plan to own the whole file is usually enough.

Serialize when neither works — a serialized group is cheaper than a merge conflict. Whichever way it resolves, say so in the schedule: name the file, the groups, and why it forced a split. Serialization that isn't explained reads as a dependency and gets copied forward into the next spec.

## 5. Report and wait for "go"

> All plans are ready in `lead-dev-os/specs/<spec>/plans/`. Review and edit the files as needed. Reply **"go"** when ready to execute.
>
> - `plans/group-1.md` — <one-line summary>
> - `plans/group-2.md` — <one-line summary>
> - …
>
> **Adversarial review:** <plan amendments made, plus any open questions the user must rule on>
>
> **Execution schedule:**
> - Wave 1: Group 1, Group 2 (independent — no shared files)
> - Wave 2: Group 3
> - …

Wait for explicit "go" before executing anything. Do not start on your own initiative. The user may edit plans or reorder the schedule before approving.
