# Spec Requirements: User Profile Page

## Initial Description

> Build a user profile page where users can view and edit their personal information, avatar, and account settings.

## Requirements Discussion

### First Round Questions

**Q1:** What is explicitly in and out of scope for this profile page?
**Answer:** In scope: display name, email, avatar upload, bio, and timezone. Out of scope: password changes (separate flow), billing info, and notification preferences.

**Q2:** How will users navigate to their profile? What's the entry point?
**Answer:** Avatar icon in the top-right nav bar opens a dropdown with "My Profile" link. Direct URL at `/settings/profile`.

**Q3:** What data does the profile feature create, read, update, or delete?
**Answer:** Reads user record from the database. Updates display name, bio, timezone, and avatar. Avatar images are stored in S3. No delete — users can clear fields but not delete their account from here.

**Q4:** What happens with edge cases — empty states, errors, large uploads?
**Answer:** Avatar uploads capped at 5MB, JPEG/PNG only. Show current values as defaults in edit mode. If save fails, show inline error and preserve form state.

**Q5:** Does this touch other features or external services?
**Answer:** Uses the existing auth middleware for authentication. Avatar upload goes to S3 via the existing file upload service. Display name changes should propagate to the activity feed.

**Q6:** How will we know this feature is "done"?
**Answer:** User can view and edit all profile fields. Avatar upload works with preview. Changes persist after page reload. Mobile responsive.

**Q7:** I found these existing patterns that may be relevant: `agents-context/concepts/auth-system.md` references the auth middleware at `src/middleware/auth.ts`, and `agents-context/concepts/file-uploads.md` references the S3 upload service at `src/services/upload.ts`. Should we reuse these?
**Answer:** Yes, reuse both. The upload service already handles S3 presigned URLs — extend it for avatar-specific validation (dimensions, file type).

**Q8:** Do you have any mockups or wireframes? Drop them into `lead-dev-os/specs/2026-02-25-user-profile/planning/visuals/`.
**Answer:** Added `profile-mockup.png` to the visuals folder.

### Existing Code to Reference

**From Concept Files:**
- Concept: `auth-system.md` — Related source: `src/middleware/auth.ts`
- Relevance: Profile page requires authenticated access; reuse auth middleware

- Concept: `file-uploads.md` — Related source: `src/services/upload.ts`
- Relevance: Avatar upload can extend existing S3 upload service

**From User Input:**
- Feature: Settings layout — Path: `src/pages/settings/`
- Components to potentially reuse: Settings page shell, form components

### Follow-up Questions

**Follow-up 1:** The mockup shows a cropping tool for avatars — is that in scope for v1, or can we use a simple file picker?
**Answer:** Simple file picker for v1. Cropping is a nice-to-have for later.

## Visual Assets

### Files Provided
- `profile-mockup.png`: High-fidelity mockup showing profile view and edit modes side by side

### Visual Insights
- Two-column layout: avatar and key info on the left, form fields on the right
- Edit mode uses inline editing (no separate page)
- Avatar has a hover overlay with "Change" text
- Fidelity level: high-fidelity mockup

## Requirements Summary

### Must Have
- Display and edit: display name, email (read-only), bio, timezone
- Avatar upload with 5MB limit, JPEG/PNG only, with preview
- Authenticated access via existing auth middleware
- Inline error handling on save failure
- Mobile responsive layout

### Should Have
- Avatar hover overlay for change action
- Timezone dropdown with common timezones
- Success toast on save

### Reusability Opportunities
- Auth middleware at `src/middleware/auth.ts`
- S3 upload service at `src/services/upload.ts` — extend for avatar validation
- Settings page shell at `src/pages/settings/`
- Form components from shared UI library

### Out of Scope
- Password changes
- Account deletion
- Billing information
- Notification preferences
- Avatar cropping tool

---

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
