# Product Mission

## Mission Statement
TaskFlow helps small development teams plan, track, and ship software projects without the overhead of enterprise project management tools.

## Vision
TaskFlow becomes the default project tracker for teams of 2-15 developers who want opinionated workflows over infinite configurability. In two years, teams choose TaskFlow because it makes the right way to manage work the easiest way — reducing planning overhead so developers spend more time building.

## Problem Statement
Small dev teams struggle with project management tools that are either too simple (sticky notes, spreadsheets) or too complex (Jira, Monday.com). Simple tools lack visibility into blockers and progress; enterprise tools require a dedicated admin and impose ceremony that slows small teams down. Teams need a tool that fits naturally into a developer workflow — integrated with Git, opinionated about task states, and lightweight enough that updating status is faster than ignoring it.

## Target Users

### Persona 1: Team Lead (Sam)
- **Role:** Technical lead managing 4-8 developers on a SaaS product
- **Pain points:** Spends 30 minutes/day updating Jira; loses track of who's blocked on what; sprint planning takes half a day
- **Goals:** Know at a glance what shipped this week, what's blocked, and what's next; spend <5 minutes/day on project management overhead

### Persona 2: Individual Contributor (Jordan)
- **Role:** Full-stack developer who ships features and fixes bugs
- **Pain points:** Forgets to update ticket status; finds the board confusing with too many columns; hates context-switching to update project tools
- **Goals:** See their own work queue clearly; update status without leaving the terminal or IDE; get notified only about things that actually block them

## Differentiation
- **Git-native**: Task state transitions triggered by branch names and PR events — no manual status updates
- **Opinionated workflow**: Fixed 5-state pipeline (Backlog → Ready → In Progress → Review → Done) — no custom columns or workflows to configure
- **Developer-first UI**: CLI and API as first-class citizens, web board is a read-only view
- **No admin required**: Self-serve team setup in under 2 minutes

## Technology Stack

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Language | Python 3.12 | Team expertise, strong async support, rich ecosystem |
| Framework | FastAPI | High performance, automatic OpenAPI docs, async-native |
| Database | PostgreSQL 16 | Reliable, strong JSON support for flexible metadata, team familiarity |
| Infrastructure | AWS (ECS Fargate + RDS) | Managed containers, no server maintenance, easy scaling |
| Frontend | React 18 + TypeScript | Component reuse, strong typing, large talent pool |
| Real-time | WebSockets via FastAPI | Native support, no additional infrastructure needed |

## Success Metrics
- 6-month: 50 active teams using TaskFlow weekly; median task update time under 10 seconds; 95th percentile API latency under 200ms
- 2-year: 1,000 active teams; Git integration adopted by 80% of teams; positive NPS (>30) from team leads

## Minimum Viable Feature Set
1. Team creation and member invitations (email-based)
2. Task CRUD with the 5-state pipeline (Backlog → Ready → In Progress → Review → Done)
3. Board view showing all tasks grouped by state
4. GitHub webhook integration — auto-move tasks on branch push and PR merge
5. Personal "My Work" view filtered to the logged-in user
6. Basic notifications (assigned to you, task blocked, PR merged)
