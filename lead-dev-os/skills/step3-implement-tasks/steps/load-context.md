# Load spec context

1. **Find the spec folder.** Look for the most recent `lead-dev-os/specs/YYYY-MM-DD-*/` directory, or ask the user which spec to implement.

2. **Read these files in order:**
   - `tasks.md` — the task breakdown (your work plan)
   - `spec.md` — the specification (your requirements)
   - `planning/requirements.md` — original requirements and Q&A context (if present)

3. **Identify the incomplete task groups** (groups with unchecked tasks) and their `Dependencies:` headers.

4. **Note the Execution Waves subsection** of `tasks.md`'s Execution Order, if present — it is `/lead-dev-os:step2-scope-tasks`'s proposal for which groups can run in parallel. Treat it as a starting point, to be validated against the actual plans before any parallel dispatch.
