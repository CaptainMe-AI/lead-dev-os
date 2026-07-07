---
name: step3-implement-tasks
description: Implement tasks from a scoped task breakdown.
disable-model-invocation: true
---

# Step 3: Implement Tasks

Execute task groups from a scoped task breakdown. Three modes — Autonomous, Lead-in-the-Loop, Hybrid — trade off speed vs. review.

**Use plan mode per task group when implementing.** The exact mechanism varies by mode: A and H produce all task-group plans up front via parallel subagents (Phase 3); L uses Claude Code's native plan mode at the start of each group (Phase 4b). Either way, every group is planned before its code is written.

## Instructions

You are a senior engineer implementing a feature from a scoped task breakdown. Work through task groups in dependency order, loading relevant context before each group, and updating context when new patterns emerge.

### Phase 1: Load Spec Context

1. **Find the spec folder.** Look for the most recent `lead-dev-os/specs/YYYY-MM-DD-*/` directory, or ask the user which spec to implement.

2. **Read these files in order:**
   - `tasks.md` — the task breakdown (your work plan)
   - `spec.md` — the specification (your requirements)
   - `planning/requirements.md` — original requirements and Q&A context (if present)

3. **Identify the next incomplete task group** (first group with unchecked tasks).

### Phase 2: Select Execution Mode

Read the `> Size:` line from `spec.md` (written by `/lead-dev-os:step1-write-spec`) and derive a recommendation: **Small → A**, **Medium → H**, **Large → L**. If the line is absent, make your own quick size assessment from `tasks.md` (group count, integration points) and say so.

Present the three modes with your recommendation first, and ask which to use — the user decides.

| Mode | Behavior | Best for |
|------|----------|----------|
| **A — Autonomous** | Pre-plan all groups in parallel → user approves batch → each group is executed by a fresh executor subagent; the orchestrator verifies and commits per group. Independent groups may run in parallel. No pauses during execution. | Small features, well-understood domains, low risk. |
| **L — Lead-in-the-Loop** | Per-group cycle in the main conversation: plan (native plan mode) → user approves → execute → review gate → repeat. | Complex features, new domains, high visibility. |
| **H — Hybrid** | Pre-plan all groups in parallel → user approves batch → orchestrated executor-subagent execution up to the checkpoint → at and after the checkpoint, switch to L behavior. | Boilerplate setup followed by tricky logic. |

Ask: **"Which execution mode? (A / L / H)"**

If the user picks **H**, also ask: **"Which group is the checkpoint?"** Autonomous execution runs up to but not including that group; L behavior begins at that group.

Store the mode (and checkpoint) for the rest of the session.

### Phase 3: Pre-execution Planning (A and H only)

Skip this phase for L mode — L plans per group during execution (Phase 4b).

The goal: produce a `plans/group-N.md` file for every incomplete task group before any code is written, so the user can review and edit the whole execution upfront in one batch instead of group-by-group.

**Check for existing plans first.** If `lead-dev-os/specs/<spec>/plans/` already contains files, ask the user whether to reuse, regenerate, or amend them. Don't silently overwrite plans the user may have edited.

**Spawn one planner subagent per incomplete task group, in parallel.** Issue all subagent calls in a single tool-call batch so they run concurrently. Use `subagent_type: "general-purpose"` and give each a self-contained prompt of roughly this shape:

```
You are planning Task Group <N> from <spec-path>/tasks.md.

Read these files first (and only these — don't broadly scan the codebase):
- <spec-path>/tasks.md (focus on Group N's section)
- <spec-path>/spec.md
- agents-context/README.md, then load only the concept/standard files Group N's
  "Read before starting" header names
- Each file Group N will modify or extend, so you know the starting state

Write <spec-path>/plans/group-<N>.md with these sections:

1. Goal — one paragraph: what shipping this group accomplishes.
2. Sub-tasks — an ordered, atomic list. Each sub-task should be small enough
   to be a coherent commit on its own. Mark which sub-tasks merit their own
   commit vs. rolling into the group commit.
3. File operations — every file you'll create, modify, or delete, with a
   one-line rationale per file.
4. Test approach — which test files, how many tests, what they cover, and
   the patterns you'll follow from the project's test standards.
5. Verification — the exact command(s) to run this group's tests
   (per the group's "Ensure tests pass" sub-task).
6. Risks — anything that could cause the group to fail or need spec
   clarification before execution. If you spot a missing dependency on
   another group or a gap in the spec, flag it here rather than expanding
   scope.

Constraints:
- Do NOT write code or modify any file outside <spec-path>/plans/.
- Stay within the scope of Group N as defined in tasks.md.
- The plan will be read cold by an executor agent; be specific about file
  paths and exact patterns to follow.
```

When all planner subagents return, report:

> All plans are ready in `lead-dev-os/specs/<spec>/plans/`. Review and edit the files as needed. Reply **"go"** when ready to execute.
>
> - `plans/group-1.md` — <one-line summary>
> - `plans/group-2.md` — <one-line summary>
> - …

Wait for explicit "go" before proceeding to Phase 4. Do not start executing on your own initiative.

### Phase 4: Execute Task Groups

There are two execution paths:

- **Orchestrated — A mode, and H before the checkpoint.** The main conversation acts as an orchestrator: each group is executed by a fresh executor subagent, then the orchestrator verifies and commits. This keeps the main context small regardless of how many groups the feature has — group 6 gets the same quality of attention as group 1. Follow **4-O**.
- **Direct — L mode, and H at/after the checkpoint.** The main conversation executes the group itself so the user can watch and steer. Follow **4a–4g**.

#### 4-O. Orchestrated execution (A, and H pre-checkpoint)

Work through incomplete groups in dependency order:

1. **Dispatch an executor subagent per group** (`subagent_type: "general-purpose"`) using the prompt template below. Each executor starts with a fresh context and reads everything it needs from disk — never assume it inherits knowledge from this conversation.

2. **Parallel dispatch (optional).** Two or more groups may be dispatched in the same batch only when BOTH hold: (a) neither depends on the other, directly or transitively, per the `Dependencies:` headers, and (b) their plans' "File operations" lists don't overlap. When in doubt, dispatch sequentially — a serialized group is cheaper than a merge conflict.

3. **Verify — trust but verify.** When an executor returns, run the group's verification command from `plans/group-<N>.md` yourself. Do not take the executor's report at face value.

4. **Review the diff** briefly for scope creep, deleted tests, or weakened assertions.

5. **Commit.** Executors never commit — the orchestrator commits after verifying, per 4f. When groups ran in parallel, stage each group's files separately (use the plan's "File operations" list) so each group still gets its own atomic commit.

6. **Report and continue** (A-mode gate):
   - Group N complete
   - Tests written / passing
   - Concept files created or updated
   - Next group(s) queued
   Then dispatch the next group(s). In H mode, when the checkpoint group is reached, switch to the direct path (4a–4g) with L behavior.

If an executor reports a blocker, plan-invalidating drift, or exhausted retries, stop and apply the Error Handling section — surface it to the user; don't redispatch blindly.

**Executor prompt template:**

```
You are executing Task Group <N> of <spec-path>/tasks.md as part of
/lead-dev-os:step3-implement-tasks.

Read first, in this order:
- <spec-path>/plans/group-<N>.md — your working plan
- <spec-path>/tasks.md — Group N's section (subtasks + acceptance criteria)
- agents-context/README.md, then every file Group N's "Read before
  starting" header names
- Every file the plan's "File operations" section says you'll modify

Reconcile before you code: earlier groups may have changed the code since
this plan was written. If reality has drifted (files moved, signatures
changed, patterns replaced), update plans/group-<N>.md to match reality
first and note the drift in your final report. If the drift invalidates
the group's goal, stop and report instead of improvising.

Then execute the group:
1. Tests first — write the group's tests before implementation; they
   should fail before the code that satisfies them exists.
2. Implement to make them pass, following the conventions from the loaded
   context files. Stay within Group N's scope — no scope creep.
3. Verify with the plan's verification command. Run ONLY this group's
   tests, not the entire suite.
4. If a test fails: diagnose, fix the most likely cause, re-run. Retry
   limit: 2 attempts. Never delete tests, weaken assertions, or skip
   behavior to get green — report the failure instead.
5. Check off completed tasks in tasks.md as each one finishes, not in a
   batch at the end.
6. Update context: create or update the concept files named in the
   group's "Update after completing" header; keep agents-context/README.md
   in sync (index entry, Load-When Cheatsheet, cross-references).

Do NOT commit — the orchestrator commits after verifying your work.

Final report (structured):
- Tests written / passing (counts and file paths)
- Files created / modified / deleted
- Concept files created or updated
- Plan drift found and how the plan was amended (if any)
- Blockers or open questions (if any)
```

#### Direct execution (L, and H at/after checkpoint)

For each incomplete task group, in dependency order, run the 4a–4g sub-cycle in the main conversation.

#### 4a. Load Context

1. **Read every file listed in the group's `Read before starting:` header.** These supply project-specific guidance — concept files and standards. Don't skip.
2. **Read every file the group will modify or extend** (named in the plan's "File operations" section, or in the group's `Modifies:` header if present). Understand the starting state before changing it.
3. **Verify dependencies.** If this group depends on earlier groups, confirm those groups' tasks are checked off and their tests pass.

#### 4b. Plan

- **H mode (at/after the checkpoint):** read `plans/group-<N>.md`. Treat it as the working plan. The user approved the batch in Phase 3, but they may also have edited the file — read it fresh. If earlier groups changed the code in ways the plan didn't anticipate, update the plan file to match reality before executing, and tell the user what drifted.
- **L mode:** enter Claude Code's native plan mode and produce a plan with the same structure as Phase 3 (Goal, Sub-tasks, File ops, Test approach, Verification, Risks). In the plan header, include this identifier so the agent stays aware of its workflow context after `ExitPlanMode` clears the conversation: "Running as part of `/lead-dev-os:step3-implement-tasks` for `<spec-path>/tasks.md`, task group N. Final step: return to tasks.md and check off completed tasks." Wait for the user to approve via `ExitPlanMode` before continuing.

#### 4c. Execute

Work through each task in the group sequentially:

1. **Tests first.** Write tests before implementation. Tests should cover the specific behavior described in the task, follow the project's test patterns, and be runnable and failing before you write the code that satisfies them.

2. **Implementation.** Write code to make the tests pass. Follow the conventions from the concept and standard files loaded in 4a. Reuse patterns identified in the spec. Stay within the task's scope — no scope creep.

3. **Verify.** Run only this group's tests, using the verification command in the plan. Do not run the entire test suite at this stage — slow feedback loops cost more than they save here.

4. **Mark tasks complete** by checking them off in `tasks.md` as soon as each task is done, not in a batch at the end. This protects progress if the session is interrupted.

#### 4d. Self-fix on Test Failure

If a test fails:

1. Inspect the failure. Determine whether the issue is in the test, the implementation, or an assumption about the surrounding code.
2. Fix the most likely cause and re-run the group's tests.
3. **Retry limit: 2 attempts.** After two unsuccessful fixes, stop and report:
   - The failing test name and message
   - What you tried in each retry
   - Your hypothesis on the root cause
   - Whether the blocker likely sits in the spec, the existing code, or the new code

Do not loop indefinitely, and do not "fix" by deleting tests, weakening assertions, or skipping behavior. The user would rather debug a stuck group with you than inherit a feature whose tests were silently disabled.

#### 4e. Update Context

After the group's tests pass:

1. **Read `agents-context/README.md`** to see what concepts already exist.
2. **Create or update concept files** when the group's `Update after completing:` header calls for it, OR when implementation revealed a pattern future features will need to understand.
3. **Concept files capture general guidance, not code.** Describe approach, conventions, decision rationale, and file paths — not code snippets, not file-by-file documentation.
4. **Keep `agents-context/README.md` in sync.** When you create or update a concept file, add or update its entry under Core/Domain Concepts, refresh the "For AI Agents" task-to-concept mapping, and update cross-references in related concept entries. The README is the entry point — if it's stale, future agents won't find the concept.

#### 4f. Commit

Atomic-commit policy:

- **Default: one commit per task group.** The commit message describes what the group shipped (not how) and references the spec folder name.
- **Optional sub-commits:** if a group has natural sub-units (e.g. a "primitives" sub-task that lands cleanly on its own, then "integration" on top), commit each sub-unit separately. Use judgment — if you can't summarize a sub-commit in one clean line, it isn't ready as its own commit.
- **Don't sweep up unrelated changes.** If the user has uncommitted edits in files outside this group's scope, ask before staging anything.

In **L** mode you may skip the auto-commit and let the user commit manually after the review gate (4g).

#### 4g. Review Gate

After the group is complete (this gate applies to the direct path — L mode, and H at/after the checkpoint; A mode's gate is 4-O step 6):

1. Report:
   - Group N complete
   - Tests written / passing
   - Concept files created or updated
   - Diff overview
2. Stop and present the review gate:
   > **Review gate — Task Group N complete.**
   > Changes ready for review.
   > - 🔍 Review the diff in your git GUI (GitLens, GitHub Desktop, `lazygit`, `git diff`)
   > - ✏️ Request changes — tell me what to modify
   > - ✅ Say "commit" and I'll create a descriptive commit, or commit yourself
   > - ➡️ Say "continue" to proceed to the next group
3. Wait for explicit instruction. Do not advance until the user says to continue.

#### After all groups complete

Regardless of mode:
- **Run the full test suite once** (if the final task group's backstop subtask didn't already). This is the only full-suite run in the workflow. Triage failures: fix NEW failures this feature caused; report pre-existing failures without fixing them.
- **Verify at runtime.** Tests passing is not the same as the feature working — exercise the feature's primary user flow in the running app where feasible (start the app, hit the endpoint, click through the UI) and confirm the observable behavior matches the spec's acceptance criteria. If runtime verification isn't feasible, say so explicitly rather than skipping silently.
- Confirm every "Acceptance Criteria" block in `tasks.md` is satisfied.
- List concept files created or updated during execution.
- Summarize what was built.
- Suggest `/lead-dev-os:step4-archive-spec` to archive the spec.

### Error Handling (general)

If you hit a blocker that the 2-retry loop in 4d can't resolve, or that doesn't surface as a test failure:

1. Do not skip the task or work around it silently.
2. Tell the user what's blocking you and why.
3. If the blocker exposes a gap in the spec, name the gap.
4. If the blocker exposes a gap in context, name the concept file that should be created.
5. Ask how to proceed before continuing.

Avoid destructive shortcuts: don't delete test cases, weaken assertions, skip migrations, or use `--no-verify`. The right answer is almost always to surface the problem to the user.
