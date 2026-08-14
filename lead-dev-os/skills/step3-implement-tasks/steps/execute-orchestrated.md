# Orchestrated execution

*Applies to mode A, and mode H before the checkpoint.*

The main conversation acts as an orchestrator: each group is executed by a fresh executor subagent, verified by the verification pair, then committed by the orchestrator. This keeps the main context small regardless of how many groups the feature has — group 6 gets the same quality of attention as group 1.

Work through the approved execution schedule wave by wave:

1. **Parallel dispatch — one executor subagent per group in the current wave**, all in a single tool-call batch (`subagent_type: "general-purpose"`), using the prompt template below. Each executor starts with a fresh context and reads everything it needs from disk — never assume it inherits knowledge from this conversation. Dispatch a wave only when every group it depends on has been committed. If anything since planning has cast doubt on a wave's independence (a plan amended mid-run, drift reported by an earlier executor), re-check the two wave conditions — no dependency, disjoint file sets — and serialize when in doubt.

2. **Verify — trust but verify.** When an executor returns, run the group's verification command from `plans/group-<N>.md` yourself. Do not take the executor's report at face value.

3. **Dispatch the verification pair** — implementation-reviewer and test-verifier in parallel, per [../shared/verification-agents.md](../shared/verification-agents.md). On blocking findings, run that file's bounded fix cycle (redispatch an executor scoped to the findings; max 2 rounds). Advisory findings go into the group report.

4. **Review the diff** briefly yourself for scope creep, deleted tests, or weakened assertions — the reviewer checks this too, but the orchestrator owns the commit.

5. **Commit.** Executors never commit — the orchestrator commits after verifying. When groups ran in parallel, stage each group's files separately (use the plan's "File operations" list) so each group still gets its own atomic commit. Commit message: what the group shipped (not how), referencing the spec folder name. Don't sweep up unrelated changes — if the user has uncommitted edits outside this group's scope, ask before staging anything.

6. **Report and continue:**
   - Group N complete
   - Tests written / passing
   - Verification verdicts (reviewer, test-verifier) + advisory findings
   - Concept files created or updated
   - Next wave queued

   Then dispatch the next wave. In H mode, when the checkpoint group is reached, switch to direct execution with L behavior.

If an executor reports a blocker, plan-invalidating drift, or exhausted retries, stop and apply the error-handling rules — surface it to the user; don't redispatch blindly.

## Executor prompt template

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
