# Wedding Planner App - Master Instructions

> **This document is the single source of truth for all AI agents working on this project.**
> Read this FIRST before doing any work.

---

## Project Overview

**Project Name:** Wedding Planner & Vendor Marketplace
**Platform:** Mobile App (Flutter) + Web Admin + Web Support Panel
**Target Markets:** Kuwait, Middle East, Global

---

## System Components (5 Parts)

| # | Component | Type | Technology | Users |
|---|-----------|------|------------|-------|
| 1 | Couple App | Mobile | Flutter | Couples planning wedding |
| 2 | Vendor App | Mobile | Flutter | Photographers, caterers, etc. |
| 3 | Admin Panel | Web | React/Next.js | Platform owner |
| 4 | Support Panel | Web | React + Chatwoot | Customer support team |
| 5 | Guest Page | Web | React/Next.js | Wedding guests (RSVP) |

**Backend:** Node.js + Express + PostgreSQL + Firebase

---

## Key Business Rules

### Commission System
- Commission is **PER VENDOR**, not fixed platform-wide
- Admin sets commission % when approving each vendor
- Commission can be edited later
- Example: Vendor A = 10%, Vendor B = 8%, Vendor C = 12%

### Vendor Onboarding Flow
1. Vendor signs up on mobile app
2. Submits documents (license, ID, portfolio)
3. Admin reviews on Admin Panel
4. Admin sets commission rate
5. Admin approves or rejects
6. Vendor gets notified

### Money Flow
1. Couple pays full amount
2. Platform keeps commission (e.g., 10%)
3. Vendor receives remainder (e.g., 90%)

---

## User Types & Permissions

| User Type | Can Do |
|-----------|--------|
| **Couple** | Browse vendors, book services, manage guests, send invitations, chat with vendors, contact support |
| **Vendor** | Create profile, add packages, accept/decline bookings, chat with couples, view earnings, contact support |
| **Admin** | Approve vendors, set commission, manage categories, view all bookings/payments, handle escalations |
| **Support** | View user data, view bookings/payments, chat with users, process refunds, escalate to admin |
| **Guest** | View invitation, RSVP, see event details |

---

## Design System Summary

### Colors
- Primary: Rose Gold (#D4A59A)
- Background: Blush Rose (#F4E4E1)
- Cards: Soft Ivory (#FEFAF7)
- Success: Sage Green (#7BAF6F)
- Error: Soft Red (#D78A8A)

### Fonts
- Headings: Cormorant Garamond (serif)
- Body: Inter (sans-serif)

### Spacing
- Base unit: 4px
- Standard padding: 16px

---

## Supported Languages
1. English (en)
2. Arabic (ar) - RTL support required
3. French (fr)
4. Spanish (es)

---

## Phases Overview

| Phase | Focus | Status |
|-------|-------|--------|
| Phase 1 (MVP) | Core app + Admin basics | Not Started |
| Phase 2 | Payments + Smart features | Not Started |
| Phase 2.5 | 2D Venue Layout Designer | Not Started |
| Phase 3 | AR Features + Analytics | Not Started |

---

## Important Documents

| Document | Location | Purpose |
|----------|----------|---------|
| Master Instructions | `PROJECT_MANAGEMENT/MASTER_INSTRUCTIONS.md` | This file - read first |
| Project Status | `PROJECT_MANAGEMENT/PROJECT_STATUS.md` | Current progress |
| Task Tracker | `PROJECT_MANAGEMENT/TASK_TRACKER.md` | All tasks by phase |
| Session Log | `PROJECT_MANAGEMENT/SESSION_LOG.md` | History of all sessions |
| Feature Specs | `PROJECT_MANAGEMENT/FEATURE_SPECS.md` | Detailed feature requirements |
| Changelog | `PROJECT_MANAGEMENT/CHANGELOG.md` | All changes made |
| Technical Architecture | `docs/TECHNICAL_ARCHITECTURE.md` | Tech stack & database |
| UI/UX Design | `Wedding_Planner_Application.md` | Original design document |

---

## Instructions for AI Agents

> **IMPORTANT: Every AI agent MUST follow these documentation rules.**
> Failure to document will cause confusion and lost progress.

---

### STEP 1: Before Starting Any Work

1. **Read these files in order:**
   ```
   1. PROJECT_MANAGEMENT/MASTER_INSTRUCTIONS.md  (this file)
   2. PROJECT_MANAGEMENT/PROJECT_STATUS.md       (current progress)
   3. PROJECT_MANAGEMENT/TASK_TRACKER.md         (find your task)
   4. PROJECT_MANAGEMENT/FEATURE_SPECS.md        (feature details)
   ```

2. **Identify your task:**
   - Find the task ID assigned to you (e.g., P1-030)
   - Read the task description
   - Check if task has dependencies (blocked by other tasks)

3. **Understand the context:**
   - Read SESSION_LOG.md to see previous decisions
   - Check CHANGELOG.md to see recent changes

---

### STEP 2: When Starting a Task

**You MUST update TASK_TRACKER.md:**

1. Find your task in the file
2. Change status from `[ ]` to `[~]` (in progress)
3. Add your name to "Assigned To" column

**Example:**
```
BEFORE:
| P1-030 | Countdown card widget | - | [ ] | - |

AFTER:
| P1-030 | Countdown card widget | Cursor | [~] | Started Jan 31 |
```

---

### STEP 3: While Working

1. **Follow the coding standards** (see section below)
2. **If you make a decision**, write it down to add to SESSION_LOG.md later
3. **If you find a problem**, note it to report later
4. **If you need clarification**, STOP and ask before guessing

---

### STEP 4: After Completing Work

**You MUST update these 3 files:**

#### A) Update TASK_TRACKER.md
Change status from `[~]` to `[x]` (completed)

```
BEFORE:
| P1-030 | Countdown card widget | Cursor | [~] | Started Jan 31 |

AFTER:
| P1-030 | Countdown card widget | Cursor | [x] | Completed Jan 31 |
```

#### B) Update CHANGELOG.md
Add entry with today's date:

```markdown
## January 31, 2026

### Added
- Created countdown card widget (`lib/features/home/presentation/widgets/countdown_card.dart`)
- Added countdown BLoC for timer logic
- Created unit tests for countdown calculation

### Notes
- Used `flutter_timer_countdown` package for smooth animation
- Countdown updates every second when app is in foreground
```

#### C) Update SESSION_LOG.md (if needed)
Add notes about decisions, problems, or important info:

```markdown
## Work Session - January 31, 2026

### Agent: Cursor
### Task: P1-030 Countdown Card Widget

### Decisions Made:
- Used gradient background matching design spec
- Timer pauses when app goes to background (saves battery)

### Problems Found:
- None

### Questions for Project Owner:
- Should countdown show hours/minutes when less than 1 day remaining?
```

---

### STEP 5: If You Cannot Complete a Task

**Update TASK_TRACKER.md with blocker:**

```
| P1-030 | Countdown card widget | Cursor | [!] | BLOCKED: Need API endpoint first |
```

**Document the blocker in SESSION_LOG.md:**
```markdown
### Blockers:
- Task P1-030 blocked because API endpoint `/weddings/me` not yet created
- Need task P1-140 completed first
```

---

### Documentation Templates

#### For CHANGELOG.md Entry:
```markdown
## [DATE]

### Added
- [New files/features created]

### Modified
- [Files/features changed]

### Fixed
- [Bugs fixed]

### Removed
- [Files/features deleted]

### Technical Notes
- [Any technical decisions or package choices]
```

#### For SESSION_LOG.md Entry:
```markdown
## Work Session - [DATE]

### Agent: [Your Name - Claude/Cursor/Lovable/etc.]
### Task(s): [Task IDs worked on]
### Duration: [Approximate time spent]

### Work Completed:
- [List what was done]

### Decisions Made:
- [Any choices you made and why]

### Problems/Blockers:
- [Issues encountered]

### Questions for Project Owner:
- [Anything that needs clarification]

### Files Created/Modified:
- [List of files]
```

#### For Reporting a Bug:
```markdown
### Bug Found
- **Location:** [File path and line number]
- **Description:** [What's wrong]
- **Steps to Reproduce:** [How to see the bug]
- **Suggested Fix:** [If you know how to fix it]
```

---

### What To Document (Checklist)

Always document these:

- [ ] Task started (update TASK_TRACKER.md)
- [ ] Task completed (update TASK_TRACKER.md)
- [ ] Files created (add to CHANGELOG.md)
- [ ] Files modified (add to CHANGELOG.md)
- [ ] New packages added (add to CHANGELOG.md)
- [ ] Design decisions made (add to SESSION_LOG.md)
- [ ] Problems encountered (add to SESSION_LOG.md)
- [ ] Questions that need answers (add to SESSION_LOG.md)
- [ ] Bugs found (add to SESSION_LOG.md)
- [ ] Dependencies discovered (update TASK_TRACKER.md blockedBy)

---

### What NOT To Do

- ❌ Don't start work without reading the instructions
- ❌ Don't change architecture decisions without documenting why
- ❌ Don't skip updating the tracking files
- ❌ Don't guess if something is unclear - ASK
- ❌ Don't work on a task that's blocked by another task
- ❌ Don't create new files outside the defined structure
- ❌ Don't use different state management (only BLoC)
- ❌ Don't use different navigation (only go_router)
- ❌ Don't add packages without documenting in CHANGELOG.md

---

## Coding Standards

### Flutter/Dart
- Use `flutter_bloc` for state management
- Use `go_router` for navigation
- Use `freezed` for data classes
- Follow Clean Architecture (data/domain/presentation layers)
- File naming: `snake_case.dart`
- Class naming: `PascalCase`

### Backend (Node.js)
- Use TypeScript
- Use Express.js
- Use Prisma or TypeORM for database
- RESTful API design
- JWT authentication

### Web (Admin/Support Panel)
- Use React or Next.js
- Use TypeScript
- Use Tailwind CSS for styling
- Follow the same color scheme as mobile app

---

## API Naming Convention

```
GET    /api/v1/vendors          - List vendors
GET    /api/v1/vendors/:id      - Get vendor details
POST   /api/v1/vendors          - Create vendor
PUT    /api/v1/vendors/:id      - Update vendor
DELETE /api/v1/vendors/:id      - Delete vendor
```

---

## Database Naming Convention

- Tables: `snake_case` plural (e.g., `vendors`, `bookings`)
- Columns: `snake_case` (e.g., `created_at`, `commission_rate`)
- Primary keys: `id` (UUID)
- Foreign keys: `table_name_id` (e.g., `vendor_id`)

---

## Git Branch Strategy

```
main                 - Production ready code
├── develop          - Development branch
    ├── feature/auth - Feature branches
    ├── feature/vendors
    ├── feature/bookings
    └── bugfix/xxx   - Bug fixes
```

---

## Contact & Escalation

- Project Owner: [User]
- Lead AI: Claude (manages project, creates specs)
- Development: Cursor, Lovable, or other AI agents

---

## Quick Reference - What Each Component Does

### Couple App (Mobile)
- Onboarding & profile setup
- Browse & search vendors
- View vendor profiles & packages
- Book vendors
- Chat with vendors
- Manage guest list
- Track budget
- Create & send invitations
- View RSVPs
- Contact support

### Vendor App (Mobile)
- Sign up & submit for approval
- Create business profile
- Add service packages
- Set availability calendar
- Accept/decline booking requests
- Chat with couples
- View earnings & bookings
- Receive notifications
- Contact support

### Admin Panel (Web)
- Dashboard (stats overview)
- Approve/reject vendors (set commission)
- Manage service categories
- View all bookings
- Track commission earnings
- Manage users
- Handle escalated issues
- Generate reports
- System settings

### Support Panel (Web)
- View incoming chats
- See user's full profile & bookings
- See payment history
- Process refunds
- Cancel/modify bookings
- Escalate to admin
- Automated responses (chatbot)

### Guest Page (Web)
- View wedding invitation
- RSVP (accept/decline)
- Select meal preference
- Add plus-one details
- See event details & directions
- Add to calendar

---

---

## Quick Reference Card for AI Agents

### Files You MUST Update

| When | Update This File |
|------|------------------|
| Starting a task | TASK_TRACKER.md (mark `[~]`) |
| Finishing a task | TASK_TRACKER.md (mark `[x]`) |
| Creating/changing files | CHANGELOG.md |
| Making decisions | SESSION_LOG.md |
| Finding problems | SESSION_LOG.md |
| Task is blocked | TASK_TRACKER.md (mark `[!]`) |

### Status Symbols for TASK_TRACKER.md

| Symbol | Meaning |
|--------|---------|
| `[ ]` | Not started |
| `[~]` | In progress |
| `[x]` | Completed |
| `[!]` | Blocked |
| `[?]` | Needs clarification |

### Minimum Documentation Per Task

```
1. START: Update TASK_TRACKER.md → [ ] to [~]
2. FINISH: Update TASK_TRACKER.md → [~] to [x]
3. FINISH: Add CHANGELOG.md entry
4. IF ISSUES: Add SESSION_LOG.md entry
```

### File Locations Quick Reference

```
PROJECT_MANAGEMENT/
├── MASTER_INSTRUCTIONS.md   ← You are here (read first)
├── PROJECT_STATUS.md        ← Overall progress
├── TASK_TRACKER.md          ← All tasks (update this!)
├── SESSION_LOG.md           ← Decisions & issues
├── FEATURE_SPECS.md         ← Feature details
└── CHANGELOG.md             ← What changed (update this!)

docs/
└── TECHNICAL_ARCHITECTURE.md ← Tech stack & database

wedding_planner/
└── lib/                      ← Flutter code goes here
```

### Emergency Contacts

If you're stuck or confused:
1. Re-read MASTER_INSTRUCTIONS.md
2. Check SESSION_LOG.md for similar past issues
3. Mark task as `[?]` and document your question
4. STOP and wait for project owner's guidance

---

**Last Updated:** January 30, 2026
**Version:** 1.1
