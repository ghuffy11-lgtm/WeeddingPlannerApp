# API Endpoint Mapping

> **Purpose:** Definitive reference for what API endpoints exist in the backend and what URLs Flutter should call.
>
> **Last Updated:** Feb 13, 2026

---

## Backend Routes (What Actually Exists)

### Auth Routes (`/api/v1/auth`)

| Method | Path | Description | Status |
|--------|------|-------------|--------|
| POST | /register | Create account | Exists |
| POST | /login | Login | Exists |
| POST | /refresh | Refresh token | Exists |
| POST | /forgot-password | Request reset | Exists |
| POST | /reset-password | Reset password | Exists |
| POST | /verify-email | Verify email | Exists |
| ~~POST~~ | ~~/logout~~ | Logout | **MISSING** |

---

### Wedding Routes (`/api/v1/weddings`)

| Method | Path | Description | Status |
|--------|------|-------------|--------|
| GET | /me | Get current user's wedding | Exists |
| POST | / | Create wedding | Exists |
| PUT | /:id | Update wedding | Exists |
| GET | /:id/guests | Get wedding guests | Exists |
| POST | /:id/guests | Add guest | Exists |
| PUT | /:id/guests/:guestId | Update guest | Exists |
| DELETE | /:id/guests/:guestId | Delete guest | Exists |
| GET | /:id/budget | Get budget items | Exists |
| POST | /:id/budget | Add budget item | Exists |
| GET | /:id/tasks | Get tasks | Exists |
| POST | /:id/tasks | Add task | Exists |
| PUT | /:id/tasks/:taskId | Update task | Exists |
| DELETE | /:id/tasks/:taskId | Delete task | Exists |
| GET | /me/tasks | Get user's tasks | Exists |
| GET | /me/tasks/stats | Get task stats | Exists |
| GET | /me/budget/summary | Get budget summary | Exists |

---

### Booking Routes (`/api/v1/bookings`)

| Method | Path | Description | Status |
|--------|------|-------------|--------|
| GET | / | List bookings | Exists |
| POST | / | Create booking | Exists |
| GET | /my-bookings | User's bookings | Exists |
| GET | /:id | Get booking details | Exists |
| PUT | /:id | Update booking | Exists |
| DELETE | /:id | Cancel booking | Exists |

---

### Vendor Routes (`/api/v1/vendors`)

| Method | Path | Description | Status |
|--------|------|-------------|--------|
| GET | / | List vendors | Exists |
| GET | /search | Search vendors | Exists |
| POST | /register | Register as vendor | Exists |
| GET | /me | Get current vendor profile | Exists |
| PUT | /me | Update vendor profile | Exists |
| GET | /me/dashboard | Vendor dashboard | Exists |
| GET | /me/bookings | Vendor's bookings | Exists |
| GET | /:id | Get vendor by ID | Exists |
| GET | /:id/packages | Get vendor packages | Exists |
| POST | /me/packages | Create package | Exists |
| PUT | /me/packages/:id | Update package | Exists |
| DELETE | /me/packages/:id | Delete package | Exists |

---

### Category Routes (`/api/v1/categories`)

| Method | Path | Description | Status |
|--------|------|-------------|--------|
| GET | / | List all categories | Exists |
| GET | /:id | Get category by ID | Exists |

---

## Flutter Datasource URL Corrections

### Critical: These URLs Are WRONG in Flutter

| Datasource File | Current (Wrong) | Correct | Notes |
|-----------------|-----------------|---------|-------|
| `guest_remote_datasource.dart` | `/guests` | `/weddings/{weddingId}/guests` | Need wedding ID |
| `guest_remote_datasource.dart` | `/guests/stats` | N/A | Endpoint doesn't exist |
| `budget_remote_datasource.dart` | `/budget` | `/weddings/{weddingId}/budget` | Need wedding ID |
| `budget_remote_datasource.dart` | `/budget/expenses` | N/A | Endpoint doesn't exist |
| `budget_remote_datasource.dart` | `/budget/expenses/overdue` | N/A | Endpoint doesn't exist |
| `budget_remote_datasource.dart` | `/budget/expenses/upcoming` | N/A | Endpoint doesn't exist |
| `task_remote_datasource.dart` | `/tasks` | `/weddings/{weddingId}/tasks` OR `/weddings/me/tasks` | Use /me for current user |
| `task_remote_datasource.dart` | `/tasks/stats` | `/weddings/me/tasks/stats` | Fixed - SKILL-025 |
| `auth_remote_datasource.dart` | `/auth/logout` | N/A | Endpoint doesn't exist |

---

## URL Pattern Reference

### For Couple Users (Wedding-Scoped Data)

```
# Get current user's wedding
GET /api/v1/weddings/me

# Create wedding (during onboarding)
POST /api/v1/weddings

# Wedding-scoped resources (requires wedding ID)
GET  /api/v1/weddings/{weddingId}/guests
POST /api/v1/weddings/{weddingId}/guests
GET  /api/v1/weddings/{weddingId}/budget
POST /api/v1/weddings/{weddingId}/budget
GET  /api/v1/weddings/{weddingId}/tasks
POST /api/v1/weddings/{weddingId}/tasks

# Current user shortcuts (no wedding ID needed)
GET /api/v1/weddings/me/tasks
GET /api/v1/weddings/me/tasks/stats
GET /api/v1/weddings/me/budget/summary
```

### For Vendor Users

```
# Register as vendor (during onboarding)
POST /api/v1/vendors/register

# Get/update vendor profile
GET /api/v1/vendors/me
PUT /api/v1/vendors/me

# Vendor packages
GET  /api/v1/vendors/me/packages
POST /api/v1/vendors/me/packages
PUT  /api/v1/vendors/me/packages/{packageId}
DELETE /api/v1/vendors/me/packages/{packageId}

# Vendor dashboard & bookings
GET /api/v1/vendors/me/dashboard
GET /api/v1/vendors/me/bookings
```

### For Public/Shared

```
# Search vendors (public)
GET /api/v1/vendors/search?category={}&location={}&priceRange={}

# List categories (public)
GET /api/v1/categories

# Auth (public)
POST /api/v1/auth/register
POST /api/v1/auth/login
POST /api/v1/auth/refresh
```

---

## How to Get Wedding ID in Flutter

The wedding ID is needed for most couple-scoped endpoints. Here's how to get it:

### Option 1: Use /me Endpoints (Recommended)
```dart
// Backend resolves wedding from auth token
final response = await dio.get('/weddings/me/tasks');
```

### Option 2: Fetch Wedding First, Then Use ID
```dart
// Get wedding ID
final weddingResponse = await dio.get('/weddings/me');
final weddingId = weddingResponse.data['data']['id'];

// Use wedding ID in subsequent requests
final guestsResponse = await dio.get('/weddings/$weddingId/guests');
```

### Option 3: Store Wedding ID After Onboarding
```dart
// During onboarding, save wedding ID
final createResponse = await dio.post('/weddings', data: weddingData);
final weddingId = createResponse.data['data']['id'];
await localDataSource.saveWeddingId(weddingId);

// Later, retrieve from local storage
final weddingId = await localDataSource.getWeddingId();
```

---

## Error Responses

### 404 Not Found
- **Cause:** Resource doesn't exist OR user doesn't have access
- **Common:** `/weddings/me` returns 404 if user hasn't created wedding yet
- **Handle:** Show "No wedding yet" message, not error

### 409 Conflict
- **Cause:** Resource already exists
- **Common:** `POST /weddings` returns 409 if user already has wedding
- **Handle:** Redirect to home (wedding exists)

### 400 Bad Request
- **Cause:** Invalid request body or query parameters
- **Common:** Missing required fields, invalid UUID format
- **Handle:** Show validation error to user

### 500 Internal Server Error
- **Cause:** Backend bug or database constraint violation
- **Common:** Invalid foreign key (categoryId in vendor registration)
- **Handle:** Log error, show generic error message

---

## Endpoints That Need Implementation

These endpoints are called by Flutter but don't exist in backend:

| Endpoint | Priority | Notes |
|----------|----------|-------|
| POST /api/v1/auth/logout | Low | Can be client-side only (clear tokens) |
| GET /api/v1/guests/stats | Low | Can calculate client-side from guests list |
| GET /api/v1/budget/expenses/* | Medium | Need to decide on budget tracking approach |

---

## Quick Reference: Datasource to Endpoint

| Flutter Feature | Datasource | Primary Endpoints |
|-----------------|------------|-------------------|
| Auth | auth_remote_datasource | /auth/login, /auth/register, /auth/refresh |
| Home | home_remote_datasource | /weddings/me, /weddings |
| Guests | guest_remote_datasource | /weddings/{id}/guests |
| Budget | budget_remote_datasource | /weddings/{id}/budget, /weddings/me/budget/summary |
| Tasks | task_remote_datasource | /weddings/me/tasks, /weddings/me/tasks/stats |
| Vendors | vendor_remote_datasource | /vendors, /vendors/search, /categories |
| Vendor App | vendor_app_remote_datasource | /vendors/me, /vendors/register, /vendors/me/packages |
| Bookings | booking_remote_datasource | /bookings, /bookings/my-bookings |
