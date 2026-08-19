# Orchestrated execution

*Applies to mode A, and mode H before the checkpoint.*

The main conversation acts as an orchestrator: each group is executed by a fresh executor subagent, verified by the verification pair, then **committed by the orchestrator before the wave can close**. This keeps the main context small regardless of how many groups the feature has — group 6 gets the same quality of attention as group 1.

## The commit invariant

Read this before dispatching anything and hold it for the whole run. Committing is not the bookkeeping at the end of a group — it is the step that makes the group exist.

- **A group is not complete until its commit exists.** Executors never commit; the orchestrator does. A group whose work sits uncommitted in the working tree is an unfinished group, however green its tests are.
- **Commit each group the moment it passes verification** — not at the end of the wave, not at the end of the run, not when the user asks. Deferred commits are lost commits: the run gets interrupted, the context fills, or a later group edits the same file, and the group boundary is gone for good.
- **Never batch groups into one commit**, and never let a group's changes ride along in another group's commit.
- **Never dispatch a wave while the previous wave's work is uncommitted.** `git status --porcelain` gates both ends of every wave (below).
- **Never `git add -A`, `git add .`, or `git commit -a` in a parallel wave** — they sweep up the sibling groups still in flight. Never `--no-verify`.

There is no mode of this workflow in which the orchestrator hands committing back to the user. In A mode nobody is watching; an uncommitted tree at the end of the run is a failed run.

## Before each wave — establish a clean baseline

Run `git status --porcelain`. **It must be empty before a wave is dispatched.**

- If it is empty: every path that turns up dirty from here on was produced by this wave's executors, and attribution is unambiguous.
- If it is not empty: this is the only place the "don't sweep up unrelated changes" rule applies. Show the user the dirty paths and ask whether to commit them, stash them, or carry them as out-of-scope. If they are carried, record that exact path list once as the **run baseline** and treat those paths as invisible for the rest of the run — never stage them, and subtract them from every later `git status` check instead of re-asking each wave.

Never start a wave from a tree you cannot account for. Attribution after the fact is guesswork, and guesswork is what makes an orchestrator defer the commit.

## Wave loop

Work through the approved execution schedule wave by wave. Dispatch a wave only when every group it depends on has been **committed** (not merely finished).

1. **Parallel dispatch — one executor subagent per group in the current wave**, all in a single tool-call batch (`subagent_type: "general-purpose"`), using the prompt template below. When the wave holds 2+ groups, append the **parallel-wave addendum** (below the prompt template) to each executor's prompt — the plans' "File operations" lists are disjoint, but `tasks.md` and `agents-context/` are shared by every group, so concurrent executors must not write them. Each executor starts with a fresh context and reads everything it needs from disk — never assume it inherits knowledge from this conversation. If anything since planning has cast doubt on a wave's independence (a plan amended mid-run, drift reported by an earlier executor), re-check the two wave conditions — no dependency, disjoint file sets — and serialize when in doubt.

2. **Verify — trust but verify.** When an executor returns, run the group's verification command from `plans/group-<N>.md` yourself. Do not take the executor's report at face value.

3. **Dispatch the verification pair** — implementation-reviewer and test-verifier in parallel, per [../shared/verification-agents.md](../shared/verification-agents.md). On blocking findings, run that file's bounded fix cycle (redispatch an executor scoped to the findings; max 2 rounds). Advisory findings go into the group report.

4. **Review the diff** briefly yourself for scope creep, deleted tests, or weakened assertions — the reviewer checks this too, but the orchestrator owns the commit. Scope the diff to the group's paths: `git diff HEAD -- <group N paths>`.

5. **Commit — immediately, before touching the next group.** Follow the [commit procedure](#commit-procedure) below. Do not queue the commit, do not move on to a sibling group's verification first, and do not proceed at all if the commit fails: a failed commit is a blocker, and blockers stop the run.

6. **Report the group**, including its commit receipt:
   - Group N complete — **committed as `<sha>` `<subject>`**
   - Tests written / passing
   - Verification verdicts (reviewer, test-verifier) + advisory findings
   - Concept files created or updated
   - Next group / next wave queued

   Steps 2–6 run per group. In a parallel wave, run them for each returned executor in turn, so each group is committed before the next one is processed.

7. **Close the wave.** After the last group in the wave is committed, run `git status --porcelain` again. It must be empty (or equal to the run baseline). See [unclaimed paths](#unclaimed-paths) if it isn't. Only then dispatch the next wave. In H mode, when the checkpoint group is reached, switch to direct execution with L behavior.

If an executor reports a blocker, plan-invalidating drift, or exhausted retries, stop and apply the error-handling rules — surface it to the user; don't redispatch blindly. Groups already committed stay committed; report where the run stopped.

## Commit procedure

### Solo-group wave

The wave started from a clean baseline and only one executor ran, so the entire diff is that group's work. Stage it whole (excluding any run-baseline paths), then commit:

```bash
git add -A                       # or: git add -- <paths>, if a run baseline is being carried
git status --short               # confirm nothing baseline-owned got staged
git commit -m "<message>"
git log -1 --oneline             # receipt for the group report
```

### Parallel wave

The tree holds every group in the wave at once, so staging must be explicit — `git add` takes whole files, and there is no partial-credit staging that would make a mixed file safe.

1. **Apply the group's bookkeeping yourself** from `plans/group-<N>-updates.md`: check off its completed tasks in `tasks.md`, create/update the proposed concept files, and keep `agents-context/README.md` in sync. Executors in a parallel wave never write these, so they are the orchestrator's edits.

2. **Stage exactly this group's paths** — the "Files changed" manifest from `plans/group-<N>-updates.md` (which supersedes the plan's "File operations" list; executors create files the plan didn't predict), plus the bookkeeping files you just edited, plus `plans/group-<N>-updates.md` and `plans/group-<N>.md` itself if the executor amended it:

   ```bash
   git add -- <path> <path> ...
   git diff --cached --name-only    # must equal the intended list, nothing more
   ```

3. **Commit**, then take the receipt:

   ```bash
   git commit -m "<message>"
   git log -1 --oneline
   ```

`git status` will still show the sibling groups' work after this commit. That is expected and is **not** a reason to withhold the commit — those paths belong to groups that have not been processed yet, and they are accounted for by the wave-close check.

### If two groups touched the same file

The wave conditions were supposed to prevent this, so treat it as a scheduling failure, not a staging puzzle. Do not guess which hunks belong to whom and do not `git add -p` your way out of it. Commit the group that owns the file per `tasks.md`'s file-ownership rules (its change lands whole), then tell the user which file was contended and which group's edits rode along in the other group's commit, so the schedule can be fixed for the next run.

### Commit message

What the group shipped, not how, referencing the spec folder name and group number — e.g. `feat(website): retire the waitlist funnel` with a body naming `Group 2 of <spec-folder>`. Follow the project's commit conventions from `agents-context/` when it has them.

### Unclaimed paths

At wave close, any path still dirty that no group's manifest claimed was produced by an executor and nearly always belongs to the group that just committed (a test fixture, an amended plan file, a helper the plan didn't list). Do not delete it and do not let it drift into the next group's commit:

- If it clearly belongs to the group whose commit is still `HEAD`: `git add -- <path> && git commit --amend --no-edit`.
- Otherwise: stop and ask the user before the next wave. An unattributable file in the tree means the wave's file sets were not actually disjoint.

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

Do NOT commit and do NOT stage anything — the orchestrator commits after
verifying your work. Leave your changes in the working tree.

Final report (structured):
- Files changed — EXHAUSTIVE list of every repo-relative path you
  created, modified, or deleted, one per line, marked create/modify/
  delete. Include test files, fixtures, snapshots, generated files, and
  any amendment you made to plans/group-<N>.md. The orchestrator stages
  exactly this list; a path you omit does not get committed.
- Tests written / passing (counts and file paths)
- Concept files created or updated
- Plan drift found and how the plan was amended (if any)
- Blockers or open questions (if any)
```

## Parallel-wave addendum

Append to the executor prompt only when the wave holds 2+ groups:

```
Parallel-wave addendum — this group runs concurrently with other groups
in the same working tree:

- Do NOT modify tasks.md or any file under agents-context/ — they are
  shared with the other groups' executors, and concurrent writes clobber
  each other. This overrides steps 5 and 6 above.
- Do NOT run any git command that changes state — no add, commit, stash,
  checkout, restore, or clean. Other groups' uncommitted work is in this
  tree and you would destroy it. Read-only git (status, diff, log) is
  fine.
- Instead, write <spec-path>/plans/group-<N>-updates.md with three
  sections:
  1. Completed tasks — the task numbers from Group N to check off in
     tasks.md
  2. Context updates — each concept file to create or update, with its
     full proposed content, plus the agents-context/README.md entries to
     add or refresh (index entry, Load-When Cheatsheet, cross-references)
  3. Files changed — the same exhaustive path list as your final report,
     one repo-relative path per line. This is what the orchestrator
     stages; anything missing from it will not be committed. Include
     plans/group-<N>-updates.md itself and plans/group-<N>.md if you
     amended it.

The orchestrator applies this file and commits it together with your
group's changes.
```
