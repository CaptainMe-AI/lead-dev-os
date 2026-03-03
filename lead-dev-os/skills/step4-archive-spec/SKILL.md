---
name: step4-archive-spec
description: Archive a completed spec — moves it to specs-archived and blocks agent access.
disable-model-invocation: true
allowed-tools: Bash, Read, Write
---

# Step 4: Archive Spec

Archive a completed spec so it doesn't get accidentally loaded by the agent in future sessions.

## Instructions

You are a project maintenance assistant. After a feature has been fully implemented via `/lead-dev-os:step3-implement-tasks`, archive the completed spec to keep the workspace clean and prevent the agent from loading stale specifications.

### Phase 1: Select Spec

1. **List specs.** Look for directories matching `lead-dev-os/specs/YYYY-MM-DD-*/` in the project root.

2. **If no specs exist**, inform the user: "No specs found in `lead-dev-os/specs/`. Nothing to archive." and stop.

3. **If one spec exists**, show its name and ask: **"Archive this spec? (yes / no)"**

4. **If multiple specs exist**, list them sorted by date prefix (newest first) and ask: **"Which spec would you like to archive?"**

### Phase 2: Archive Spec

1. **Create the archive directory** `lead-dev-os/specs-archived/` if it doesn't exist.

2. **Move the selected spec folder** from `lead-dev-os/specs/` to `lead-dev-os/specs-archived/`.

3. **Verify the move** — confirm the spec folder exists in `specs-archived/` and is no longer in `specs/`.

### Phase 3: Update Settings

Run the bundled settings script to add a deny rule that blocks agent access to archived specs:

```bash
bash <skill-path>/scripts/update-settings.sh "$(pwd)"
```

This adds `"Read(/lead-dev-os/specs-archived/**)"` to the deny array in `.claude/settings.json`. The script is idempotent — it skips if the rule already exists.

Report the script output to the user.

### Phase 4: Commit

Stage and commit all changes with a descriptive message:

```
archive spec: <spec-folder-name>
```

Where `<spec-folder-name>` is the name of the archived spec directory (e.g., `2026-01-15-auth-flow`).

### Phase 5: Summary

Report to the user:
- Which spec was archived and where it now lives
- Whether the deny rule was added or already existed
- The commit hash

Suggest that the user can run `/lead-dev-os:step1-write-spec` to start a new feature.
