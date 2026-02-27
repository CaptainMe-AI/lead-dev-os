# Product Roadmap

> Last updated: 2026-02-27
> Based on: [product-mission.md](../../agents-context/concepts/product-mission.md)

## Phase 1: Foundation
**Goal:** Core data model, auth, and basic task management — enough for internal dogfooding
**Target:** Weeks 1-4

| Priority | Feature | Description | Dependencies |
|----------|---------|-------------|--------------|
| P0 | User authentication | Email/password signup and login with JWT sessions | None |
| P0 | Team creation | Create a team, invite members by email, accept invitations | Auth |
| P0 | Task CRUD | Create, read, update, delete tasks with title, description, assignee, and state | Teams |
| P0 | 5-state pipeline | Enforce Backlog → Ready → In Progress → Review → Done transitions | Task CRUD |
| P1 | Database schema & migrations | PostgreSQL schema with Alembic migrations for users, teams, tasks | None |

## Phase 2: Core Experience
**Goal:** Board view, personal dashboard, and Git integration — usable by early adopter teams
**Target:** Weeks 5-8

| Priority | Feature | Description | Dependencies |
|----------|---------|-------------|--------------|
| P0 | Board view | Kanban-style board showing tasks grouped by pipeline state | Phase 1 |
| P0 | My Work view | Personal dashboard filtered to tasks assigned to the logged-in user | Phase 1 |
| P0 | GitHub webhook integration | Auto-move tasks on branch push (→ In Progress) and PR merge (→ Done) | Phase 1 |
| P1 | Task detail panel | Slide-over panel with full task details, activity log, and comments | Board view |
| P1 | Basic notifications | In-app notifications for assignment, blocked status, and PR events | GitHub integration |

## Phase 3: Growth & Polish
**Goal:** CLI, real-time updates, and team management — ready for public launch
**Target:** Weeks 9-14

| Priority | Feature | Description | Dependencies |
|----------|---------|-------------|--------------|
| P0 | CLI tool | Command-line interface for task CRUD and status updates | Phase 2 API |
| P1 | Real-time board | WebSocket-driven live updates on the board view | Board view |
| P1 | Team settings | Manage members, roles (admin/member), and team preferences | Phase 1 |
| P1 | Activity feed | Chronological feed of all task state changes, comments, and Git events | Phase 2 |
| P2 | Keyboard shortcuts | Navigate and manage tasks without leaving the keyboard | Board view |
| P2 | Dark mode | System-aware dark theme for the web UI | None |

## Future Considerations
- **GitLab / Bitbucket integration**: Extend webhook support beyond GitHub
- **Slack integration**: Post task updates to a team channel
- **Recurring tasks**: Auto-create tasks on a schedule (e.g., weekly deploys)
- **Public API & webhooks**: Allow third-party integrations
- **Mobile app**: React Native companion for on-the-go updates
- **Analytics dashboard**: Cycle time, throughput, and bottleneck reports

## Priority Legend
- **P0:** Must have — blocks release
- **P1:** Should have — significant value
- **P2:** Nice to have — enhances experience
