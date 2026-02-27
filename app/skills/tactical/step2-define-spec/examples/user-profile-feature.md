# Spec: User Profile Page

> Spec ID: 2026-02-25-user-profile
> Status: Draft
> Date: 2026-02-25

## Goal

Allow users to view and edit their personal profile information (display name, bio, avatar, timezone) from a dedicated settings page, improving personalization and account management.

## User Stories

### Story 1: View Profile

**As a** logged-in user,
**I want to** see my current profile information on a dedicated page,
**So that** I can verify my account details are correct.

**Acceptance Criteria:**
- **Given** I am logged in, **When** I navigate to `/settings/profile`, **Then** I see my display name, email, bio, timezone, and avatar
- **Given** I am not logged in, **When** I navigate to `/settings/profile`, **Then** I am redirected to the login page

### Story 2: Edit Profile Fields

**As a** logged-in user,
**I want to** edit my display name, bio, and timezone,
**So that** I can keep my profile information up to date.

**Acceptance Criteria:**
- **Given** I am on my profile page, **When** I modify fields and click Save, **Then** my changes persist after page reload
- **Given** I am editing, **When** the save fails, **Then** I see an inline error and my form state is preserved

### Story 3: Upload Avatar

**As a** logged-in user,
**I want to** upload a profile photo,
**So that** other users can recognize me in the activity feed.

**Acceptance Criteria:**
- **Given** I click the avatar area, **When** I select a JPEG or PNG under 5MB, **Then** I see a preview and can save it
- **Given** I select an invalid file, **When** the file is over 5MB or not JPEG/PNG, **Then** I see a validation error before upload

## Requirements

### Functional Requirements

| ID     | Requirement                                                              | Priority |
| ------ | ------------------------------------------------------------------------ | -------- |
| FR-001 | System MUST display user's display name, email, bio, timezone, and avatar | Must     |
| FR-002 | System MUST allow editing display name, bio, and timezone                 | Must     |
| FR-003 | System MUST support avatar upload (JPEG/PNG, max 5MB) with preview       | Must     |
| FR-004 | System MUST show inline errors when save fails                           | Must     |
| FR-005 | System SHOULD display email as read-only                                 | Should   |
| FR-006 | System SHOULD show a success toast after saving                          | Should   |
| FR-007 | System MAY provide a timezone dropdown with common timezones             | May      |

### Non-Functional Requirements

| ID      | Requirement                                                       | Priority |
| ------- | ----------------------------------------------------------------- | -------- |
| NFR-001 | System MUST require authentication to access the profile page     | Must     |
| NFR-002 | System MUST render responsively on mobile devices                 | Must     |
| NFR-003 | System SHOULD load profile data within 500ms                     | Should   |

## Technical Approach

Use the existing settings page shell at `src/pages/settings/` as the layout wrapper. Build the profile form as a new component within this shell. Extend the S3 upload service for avatar-specific validation (file type, size, dimensions).

### Existing Code to Reuse

- `src/middleware/auth.ts`: Authentication middleware for route protection
- `src/services/upload.ts`: S3 presigned URL upload service — extend for avatar validation
- `src/pages/settings/`: Settings page shell and layout
- `src/components/ui/`: Shared form components (inputs, buttons, toasts)

### New Components

- `src/pages/settings/profile.tsx`: Profile page component
- `src/components/avatar-upload.tsx`: Avatar upload with preview
- `src/api/profile.ts`: Profile API endpoints (GET/PATCH)

## Success Criteria

- [ ] User can view all profile fields on `/settings/profile`
- [ ] User can edit display name, bio, and timezone and changes persist
- [ ] Avatar upload works with preview and validation
- [ ] Inline errors display on save failure
- [ ] Page is mobile responsive
- [ ] Unauthenticated users are redirected to login

## Out of Scope

- Password change flow
- Account deletion
- Billing information
- Notification preferences
- Avatar cropping/editing tool
