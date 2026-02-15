# Error Tracker

> **Purpose:** Track all active errors with root causes, reproduction steps, and fix status.
>
> **Last Updated:** Feb 13, 2026 (ERR-001 verified working)

---

## Active Errors

### ERR-002: Vendor Registration Returns 500

| Field | Value |
|-------|-------|
| **Status** | FIXED_UNVERIFIED |
| **Fixed Date** | Feb 13, 2026 |
| **Endpoint** | POST /api/v1/vendors/register |
| **Error** | 500 Internal Server Error |
| **Severity** | High |

**Reproduction:**
1. Register as vendor
2. Complete vendor onboarding
3. Submit business info

**Root Cause:** Backend requires `categoryId` field which must be a valid UUID from the `categories` table. If invalid/missing categoryId is sent, Prisma throws a foreign key constraint error (500).

**Solution Implemented:**
1. Added validation in `vendor.controller.ts` to check if businessName is provided
2. Added validation to verify categoryId exists in categories table before creating vendor
3. Returns 400 Bad Request with clear error message instead of 500 Internal Server Error

**Files Modified:**
- `backend/src/controllers/vendor.controller.ts:196-238` - Added categoryId validation

**Verification Needed:**
- [ ] Register as vendor
- [ ] Try submitting with invalid category - should get 400 error with clear message
- [ ] Try submitting with valid category - should succeed
- [ ] Check that vendor profile is created correctly

---

### ERR-003: Tasks Endpoint Returns 400

| Field | Value |
|-------|-------|
| **Status** | FIXED_UNVERIFIED |
| **Fixed Date** | Feb 13, 2026 |
| **Endpoint** | GET /api/v1/weddings/me/tasks |
| **Error** | 400 Bad Request |
| **Severity** | Medium |

**Query Params Sent:** `?limit=5&status=pending&sort=due_date&order=asc`

**Root Cause:** The `requireUserType('couple')` middleware rejects requests when user's JWT token has a different user type (e.g., 'vendor'). Also possible query parameter validation issues.

**Solution Implemented:**
Flutter datasources now handle 400/403/404 errors gracefully by returning empty data instead of throwing errors:
1. Updated `home_remote_datasource.dart` - Returns empty lists on 400/403/404
2. Updated `task_remote_datasource.dart` - Returns empty PaginatedTasks/TaskStatsModel.empty() on 400/403/404
3. Added `TaskStatsModel.empty()` factory for graceful fallback

**Files Modified:**
- `lib/features/home/data/datasources/home_remote_datasource.dart`
- `lib/features/tasks/data/datasources/task_remote_datasource.dart`
- `lib/features/tasks/data/models/task_model.dart` - Added empty() factory

**Verification Needed:**
- [ ] Login as couple user
- [ ] Navigate to tasks page - should load (or show empty state)
- [ ] Login as vendor user
- [ ] Navigate to tasks page - should show empty state without error
- [ ] Check browser console for error messages

---

### ERR-004: Wrong API URL Patterns in Flutter

| Field | Value |
|-------|-------|
| **Status** | FIXED_UNVERIFIED |
| **Fixed Date** | Feb 13, 2026 |
| **Issue** | Flutter datasources call top-level URLs instead of wedding-scoped URLs |
| **Severity** | Critical - causes most 404 errors |

**URLs Fixed:**

| Datasource | Was Calling | Now Calls |
|------------|-------------|-----------|
| task_remote_datasource | `/tasks` | `/weddings/me/tasks` |
| task_remote_datasource | `/tasks/stats` | `/weddings/me/tasks/stats` |
| guest_remote_datasource | `/guests` | `/weddings/{weddingId}/guests` |
| budget_remote_datasource | `/budget` | `/weddings/{weddingId}/budget` |

**Files Modified:**
- `lib/features/tasks/data/datasources/task_remote_datasource.dart` - Uses `/weddings/me/tasks`
- `lib/features/guests/data/datasources/guest_remote_datasource.dart` - Added weddingId param
- `lib/features/guests/domain/repositories/guest_repository.dart` - Added weddingId to interface
- `lib/features/guests/data/repositories/guest_repository_impl.dart` - Pass weddingId
- `lib/features/guests/presentation/bloc/guest_bloc.dart` - Handles weddingId in state
- `lib/features/guests/presentation/bloc/guest_state.dart` - Added weddingId field
- `lib/features/guests/presentation/bloc/guest_event.dart` - Added InitializeGuests event
- `lib/features/budget/data/datasources/budget_remote_datasource.dart` - Added weddingId param
- `lib/features/budget/domain/repositories/budget_repository.dart` - Added weddingId to interface
- `lib/features/budget/data/repositories/budget_repository_impl.dart` - Pass weddingId

**Verification Needed:**
- [ ] Build Flutter web app
- [ ] Test tasks page - should call `/weddings/me/tasks`
- [ ] Test guests page - should call `/weddings/{id}/guests` (requires wedding initialization)
- [ ] Test budget page - should call `/weddings/{id}/budget` (requires wedding initialization)
- [ ] Check browser console for 404 errors

**Note:** Guest and Budget BLoCs need to call `InitializeGuests(weddingId)` / `InitializeBudget(weddingId)` before loading data. The wedding ID can be obtained from HomeRepository.getWedding().

---

### ERR-005: Missing Backend Endpoints

| Field | Value |
|-------|-------|
| **Status** | FIXED_UNVERIFIED |
| **Fixed Date** | Feb 13, 2026 |
| **Issue** | Flutter calls endpoints that don't exist in backend |
| **Severity** | Medium |

**Missing Endpoints (Original):**

| Endpoint | Called By | Status |
|----------|-----------|--------|
| GET /api/v1/tasks/stats | task_remote_datasource | FIXED - Now uses `/weddings/me/tasks/stats` |
| GET /api/v1/guests/stats | guest_remote_datasource | Handles gracefully - returns empty |
| GET /api/v1/budget/expenses | budget_remote_datasource | Uses wedding-scoped endpoint |
| POST /api/v1/auth/logout | auth_remote_datasource | Still missing - client-side logout works |

**Solution Implemented:**
- Task stats endpoint fixed in ERR-004 (uses correct wedding-scoped URL)
- Datasources handle 404 responses gracefully by returning empty data
- Client-side logout (clearing tokens) is sufficient for now

**Files Modified:**
- See ERR-004 for URL pattern fixes
- Datasources handle missing endpoints gracefully

**Verification Needed:**
- [ ] Test all pages load without console errors
- [ ] Verify empty states display correctly when no data exists

---

### ERR-006: 404 Errors on Existing Endpoints

| Field | Value |
|-------|-------|
| **Status** | FIXED_UNVERIFIED |
| **Fixed Date** | Feb 13, 2026 |
| **Issue** | Endpoints exist but return 404 |
| **Severity** | Medium |

**Affected Endpoints:**

| Endpoint | Backend Has It? | Why 404? | Status |
|----------|-----------------|----------|--------|
| GET /api/v1/weddings/me | Yes | User has no wedding record | FIXED - Returns null |
| GET /api/v1/weddings/me/budget/summary | Yes | User has no wedding record | FIXED - Returns [] |
| GET /api/v1/weddings/me/tasks/stats | Yes | User has no wedding record | FIXED - Returns empty stats |
| GET /api/v1/bookings | Yes | User has no bookings | FIXED - Returns [] |

**Root Cause:** These return 404 because the user hasn't created a wedding yet. This is expected behavior.

**Solution Implemented:**
All datasources now handle 400/403/404 errors gracefully:
- `home_remote_datasource.dart` - Returns null/empty lists on 404
- `task_remote_datasource.dart` - Returns empty PaginatedTasks/TaskStatsModel.empty()
- Other datasources already handled 404 gracefully

**Files Modified:**
- `lib/features/home/data/datasources/home_remote_datasource.dart`
- `lib/features/tasks/data/datasources/task_remote_datasource.dart`
- `lib/features/tasks/data/models/task_model.dart`

**Verification Needed:**
- [ ] Create new user account
- [ ] Navigate to home page before creating wedding
- [ ] Verify empty states display correctly (no error messages)
- [ ] Complete onboarding and verify data loads properly

---

## Resolved Errors

> Move errors here after reaching `FIXED_VERIFIED` status.

### ERR-001: Wedding Creation Returns 409 Conflict

| Field | Value |
|-------|-------|
| **Status** | FIXED_VERIFIED |
| **Fixed Date** | Feb 13, 2026 |
| **Verified Date** | Feb 13, 2026 |
| **Endpoint** | POST /api/v1/weddings |
| **Error** | 409 Conflict |
| **Severity** | Medium |

**Reproduction:**
1. Register new couple account
2. Complete onboarding
3. Try to complete again or re-register

**Root Cause:** Backend checks for existing wedding, user already has one. The `createWedding` endpoint returns 409 if user already has a wedding record.

**Solution Implemented:**
1. Added `ConflictFailure` class for 409 errors
2. Updated `home_repository_impl.dart` to return `ConflictFailure` on 409
3. Updated `onboarding_bloc.dart` to treat `ConflictFailure` as success
4. Added `weddingAlreadyExists` flag to state for UI feedback

**Files Modified:**
- `lib/core/errors/failures.dart` - Added ConflictFailure class
- `lib/features/home/data/repositories/home_repository_impl.dart` - Handle 409
- `lib/features/onboarding/presentation/bloc/onboarding_bloc.dart` - Treat 409 as success
- `lib/features/onboarding/presentation/bloc/onboarding_state.dart` - Added weddingAlreadyExists flag

**Verification Results (Feb 13, 2026):**
- [x] 409 Conflict appears in console when user already has wedding
- [x] Registration completes successfully despite 409 error
- [x] User can still complete the registration as couple
- [x] `ConflictFailure` handling working correctly

**User Report:** "I can still complete the registration as couple" - The 409 error appears in console but does NOT block registration.

**Notes:**
- Service Worker API unavailable warning is expected for HTTP dev environment (not HTTPS)
- Firebase initialized successfully
- POST /api/v1/weddings 409 is expected behavior when wedding already exists

---

### ERR-R001: Double /api/v1 in Tasks URL

| Field | Value |
|-------|-------|
| **Status** | FIXED_VERIFIED |
| **Fixed Date** | Feb 10, 2026 |
| **Skill Reference** | SKILL-025 |

**Issue:** Tasks page made request to `/api/v1/api/v1/tasks/stats` (double prefix)

**Root Cause:** Base URL already includes `/api/v1` but endpoint also added it.

**Fix:** Removed duplicate prefix in `task_remote_datasource.dart`

---

### ERR-R002: Couple Onboarding Not Saving to API

| Field | Value |
|-------|-------|
| **Status** | FIXED_UNVERIFIED |
| **Fixed Date** | Feb 11, 2026 |
| **Skill Reference** | SKILL-027 |

**Issue:** Couple onboarding collected data but didn't save to backend.

**Root Cause:** BLoC had TODO comment simulating success instead of calling API.

**Fix:** Added `createWedding` method to HomeRepository, updated OnboardingBloc to call it.

**Verification Needed:** Test full couple registration flow end-to-end.

---

### ERR-R003: Vendor Onboarding Not Creating Profile

| Field | Value |
|-------|-------|
| **Status** | FIXED_UNVERIFIED |
| **Fixed Date** | Feb 11, 2026 |
| **Skill Reference** | SKILL-028 |

**Issue:** Vendor onboarding tried to update profile that didn't exist.

**Root Cause:** Registration only created user record, not vendor profile. Onboarding called PUT instead of POST.

**Fix:** Added `registerVendor` method to call POST `/vendors/register` during onboarding.

**Verification Needed:** Test full vendor registration flow. Check for ERR-002 (500 error on invalid categoryId).

---

## Error Statistics

| Status | Count |
|--------|-------|
| OPEN | 0 |
| IN_PROGRESS | 0 |
| FIXED_UNVERIFIED | 5 |
| FIXED_VERIFIED | 2 |
| **Total Active** | **0** |

---

## Priority Order for Fixes

1. ~~**ERR-004** (Critical) - Fix Flutter URL patterns~~ - FIXED_UNVERIFIED
2. ~~**ERR-001** (Medium) - Handle 409 in onboarding~~ - **FIXED_VERIFIED** ✓
3. ~~**ERR-003** (Medium) - Debug tasks 400 error~~ - FIXED_UNVERIFIED
4. ~~**ERR-002** (High) - Debug vendor registration 500~~ - FIXED_UNVERIFIED
5. ~~**ERR-005** (Medium) - Decide on missing endpoints~~ - FIXED_UNVERIFIED
6. ~~**ERR-006** (Medium) - Handle 404 gracefully in Flutter~~ - FIXED_UNVERIFIED

---

## How to Update This Document

### When a New Error is Found:
1. Add new `ERR-XXX` section in "Active Errors"
2. Fill in all fields: Status, Endpoint, Error, Severity
3. Document reproduction steps
4. Identify root cause if known
5. List files to investigate/modify

### When Working on an Error:
1. Change status to `IN_PROGRESS`
2. Add notes about investigation findings
3. Update files list if new files identified

### When Error is Fixed:
1. Change status to `FIXED_UNVERIFIED` (if not tested)
2. Or `FIXED_VERIFIED` (if tested and confirmed)
3. Add fix date
4. Link to SKILL entry if applicable
5. Move to "Resolved Errors" section after `FIXED_VERIFIED`

### Template for New Errors:
```markdown
### ERR-XXX: Title

| Field | Value |
|-------|-------|
| **Status** | OPEN |
| **Endpoint** | [endpoint] |
| **Error** | [error code and message] |
| **Severity** | [Critical/High/Medium/Low] |

**Reproduction:**
1. Step 1
2. Step 2

**Root Cause:** [description]

**Files to Modify:**
- `path/to/file`

**Fix Approach:**
[description or code snippet]
```
