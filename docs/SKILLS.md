# Skills & Troubleshooting Knowledge Base

> **Purpose:** This document captures all fixes, troubleshooting solutions, and learned patterns. Check here FIRST before investigating issues.

---

## MANDATORY: Before Making Changes

**READ THESE DOCUMENTS FIRST:**
1. `/docs/AGENT_WORKFLOW.md` - Required review process
2. `/docs/ERROR_TRACKER.md` - Active errors and their status
3. `/docs/API_ENDPOINT_MAPPING.md` - Correct API URLs

---

## Verification Status Legend

| Status | Meaning |
|--------|---------|
| FIXED | Legacy status (pre-Feb 13, 2026) |
| FIXED_UNVERIFIED | Code changed but not tested |
| FIXED_VERIFIED | Tested and confirmed working |
| REOPENED | Previously fixed, issue returned |

---

## Table of Contents
1. [Authentication & Routing](#authentication--routing)
2. [Navigation Issues](#navigation-issues)
3. [UI/UX Fixes](#uiux-fixes)
4. [State Management](#state-management)
5. [API Integration](#api-integration)
6. [Common Errors](#common-errors)
7. [Web Platform Issues](#web-platform-issues)
8. [Known API Gaps](#known-api-gaps)

---

## Authentication & Routing

### SKILL-001: Route Users Based on Type After Login
**Problem:** After login, all users go to `/home` regardless of user type (couple vs vendor).

**Root Cause:** `login_page.dart` line 76 had hardcoded `context.go(AppRoutes.home)`.

**Solution:**
```dart
// In login_page.dart BlocConsumer listener
if (state.isAuthenticated) {
  if (state.user?.userType == UserType.vendor) {
    context.go(AppRoutes.vendorHome);
  } else {
    context.go(AppRoutes.home);
  }
}
```

**Files Modified:**
- `lib/features/auth/presentation/pages/login_page.dart`

**Related:** Need to import `user.dart` for `UserType` enum.

---

### SKILL-002: Restrict Routes by User Type
**Problem:** Vendors can access couple routes (`/home`, `/tasks`, `/profile`) and vice versa.

**Solution:** Add redirect logic in `GoRouter` configuration:

```dart
// In routes.dart
const _coupleOnlyRoutes = [
  AppRoutes.home,
  AppRoutes.tasks,
  AppRoutes.profile,
  AppRoutes.guests,
  AppRoutes.budget,
  // ... etc
];

const _vendorOnlyRoutes = [
  AppRoutes.vendorHome,
  AppRoutes.vendorBookings,
  // ... etc
];

final GoRouter appRouter = GoRouter(
  redirect: (context, state) {
    final authBloc = getIt<AuthBloc>();
    final user = authBloc.state.user;
    final path = state.uri.path;

    if (user == null) return null;

    if (user.userType == UserType.vendor) {
      for (final route in _coupleOnlyRoutes) {
        if (path == route || path.startsWith('$route/')) {
          return AppRoutes.vendorHome;
        }
      }
    }

    if (user.userType == UserType.couple) {
      for (final route in _vendorOnlyRoutes) {
        if (path == route || path.startsWith('$route/')) {
          return AppRoutes.home;
        }
      }
    }

    return null;
  },
  // ... routes
);
```

**Files Modified:**
- `lib/config/routes.dart`

---

### SKILL-003: Vendor Onboarding After Registration
**Problem:** Vendors go directly to dashboard without setting up profile/categories.

**Solution:**
1. Create `vendor_onboarding_page.dart` with multi-step form
2. Add route `/vendor/onboarding`
3. Update `register_page.dart` to route vendors to onboarding

```dart
// In register_page.dart
if (state.isAuthenticated) {
  if (_selectedUserType == UserType.couple) {
    context.go(AppRoutes.onboarding);
  } else {
    context.go(AppRoutes.vendorOnboarding);  // Not vendorHome
  }
}
```

**Files Created:**
- `lib/features/vendor_app/presentation/pages/vendor_onboarding_page.dart`

**Files Modified:**
- `lib/config/routes.dart` (add route)
- `lib/features/auth/presentation/pages/register_page.dart`

---

## Navigation Issues

### SKILL-004: Click Handlers Not Working on Home Page
**Problem:** Featured vendors, trending themes, and "Set Date" card don't respond to taps.

**Solution:** Wrap widgets with `GestureDetector`:

```dart
// For _VendorCircle
class _VendorCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.vendors),
      child: // ... existing widget
    );
  }
}

// For _ThemeCard
class _ThemeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/vendors/search', extra: theme.title),
      child: // ... existing widget
    );
  }
}
```

**Files Modified:**
- `lib/features/home/presentation/pages/home_page.dart`

---

### SKILL-005: Wedding Date Picker Not Showing
**Problem:** "Set Wedding Date" button navigates to tasks page instead of showing date picker.

**Solution:** Replace navigation with inline date picker:

```dart
class _WeddingDateCard extends StatelessWidget {
  void _showDatePicker(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surfaceDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && context.mounted) {
      context.read<HomeBloc>().add(HomeWeddingUpdated(weddingDate: selectedDate));
    }
  }
}
```

**Files Modified:**
- `lib/features/home/presentation/pages/home_page.dart`

---

## UI/UX Fixes

### SKILL-006: Menu Styling Inconsistency (Vendor vs Couple)
**Problem:** Vendor bottom nav bar looks different from couple nav bar.

**Solution:** Both scaffolds should use same styling pattern:

```dart
// Both MainScaffold and VendorScaffold should use:
Container(
  decoration: BoxDecoration(
    color: AppColors.surfaceDark,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        offset: const Offset(0, -2),
        blurRadius: 8,
      ),
    ],
  ),
  child: SafeArea(
    child: SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [/* nav items */],
      ),
    ),
  ),
)
```

**Files to Check:**
- `lib/shared/widgets/layout/main_scaffold.dart`
- `lib/shared/widgets/layout/vendor_scaffold.dart`

---

### SKILL-007: Profile/Logout Not Accessible
**Problem:** After registration, profile tab not working or logout not available.

**Solution:** Ensure profile route is properly configured in shell route:

```dart
// In routes.dart ShellRoute
GoRoute(
  path: AppRoutes.profile,
  pageBuilder: (context, state) => NoTransitionPage(
    child: BlocProvider(
      create: (_) => getIt<HomeBloc>(),
      child: const ProfilePage(),
    ),
  ),
),
```

**Check:** Profile page should have logout functionality with `AuthLogoutRequested` event.

---

## State Management

### SKILL-008: Adding State Getters
**Problem:** Need to check loading state but no getter exists.

**Solution:** Add computed getters to state class:

```dart
// In vendor_state.dart
class VendorState extends Equatable {
  // ... fields

  // Add getters for common checks
  bool get isLoadingCategories => categoriesStatus == VendorStatus.loading;
  bool get isLoadingVendors => vendorsStatus == VendorStatus.loading;
  bool get hasError => vendorsStatus == VendorStatus.error;
}
```

**Files Modified:**
- `lib/features/vendors/presentation/bloc/vendor_state.dart`

---

### SKILL-009: BLoC Not Updating UI
**Problem:** State changes but UI doesn't rebuild.

**Checklist:**
1. Check `copyWith` method includes all fields
2. Check `props` list in Equatable includes all fields
3. Ensure using `emit()` not direct state assignment
4. Check BlocBuilder/BlocConsumer is using correct bloc type

```dart
// Common mistake - forgetting field in copyWith
FeatureState copyWith({
  FeatureStatus? status,
  List<Item>? items,
  String? errorMessage,  // Don't forget this!
}) {
  return FeatureState(
    status: status ?? this.status,
    items: items ?? this.items,
    errorMessage: errorMessage,  // Note: intentionally not using ??
  );
}

// props must include all fields
@override
List<Object?> get props => [status, items, errorMessage];
```

---

## API Integration

### SKILL-010: Handle 401 Unauthorized
**Problem:** Token expired, need to refresh and retry.

**Solution:** Auth interceptor in `injection.dart`:

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final authRepo = _getIt<AuthRepository>();
        final result = await authRepo.refreshToken();

        if (result.isRight()) {
          // Retry with new token
          final tokens = await localDataSource.getTokens();
          err.requestOptions.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        }
      } catch (_) {}
    }
    handler.next(err);
  }
}
```

---

### SKILL-011: Either Pattern for Error Handling
**Problem:** Need consistent error handling across repositories.

**Pattern:**
```dart
Future<Either<Failure, T>> safeApiCall<T>(Future<T> Function() call) async {
  try {
    final result = await call();
    return Right(result);
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      return Left(AuthFailure('Session expired'));
    }
    return Left(ServerFailure(e.message ?? 'Server error'));
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

---

## Common Errors

### SKILL-012: "type 'Null' is not a subtype of type 'String'"
**Cause:** JSON parsing with null value where non-null expected.

**Solution:**
```dart
// In model fromJson
factory Model.fromJson(Map<String, dynamic> json) {
  return Model(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',  // Provide default
    description: json['description'] as String?,  // Allow null
  );
}
```

---

### SKILL-013: "Navigator operation requested with a context that does not include a Navigator"
**Cause:** Using context before widget is mounted or after disposed.

**Solution:**
```dart
if (context.mounted) {
  context.go(AppRoutes.home);
}
```

---

### SKILL-014: "setState() called after dispose()"
**Cause:** Async operation completes after widget disposed.

**Solution:**
```dart
if (mounted) {
  setState(() {
    _isLoading = false;
  });
}
```

---

### SKILL-015: BlocProvider Not Found
**Cause:** Trying to read bloc that isn't provided in widget tree.

**Solution:** Ensure bloc is provided in route:
```dart
GoRoute(
  path: '/feature',
  builder: (context, state) => BlocProvider(
    create: (_) => getIt<FeatureBloc>(),
    child: const FeaturePage(),
  ),
),
```

Or wrap with MultiBlocProvider for multiple blocs:
```dart
builder: (context, state) => MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => getIt<BlocA>()),
    BlocProvider(create: (_) => getIt<BlocB>()),
  ],
  child: const Page(),
),
```

---

## Project Structure

### SKILL-016: Document Location Convention
**Problem:** Documentation placed in wrong folder (`wedding_planner/docs/` instead of `/docs/`).

**Correct Structure:**
```
/mnt/repo/WeeddingPlannerApp/
├── docs/                    # Technical docs (architecture, setup, API, design system, SKILLS)
├── PROJECT_MANAGEMENT/      # Project management (changelog, status, tasks, specs)
├── backend/                 # Node.js backend code
└── wedding_planner/         # Flutter app code ONLY (no docs here)
```

**Rule:** Never put documentation inside `wedding_planner/`. All docs go in root `/docs/` or `/PROJECT_MANAGEMENT/`.

**Files Affected:** All new documentation files.

---

### SKILL-017: Flutter Web Server Port
**Problem:** Port 8888 doesn't work for serving Flutter web app.

**Root Cause:** Port 8888 may be blocked or in use by other services.

**Solution:** Use port 8889 with Docker nginx container:

```bash
# Build web app
cd /mnt/repo/WeeddingPlannerApp/wedding_planner
docker run --rm -v "$(pwd)":/app -v "flutter_pub_cache:/root/.pub-cache" -w /app ghcr.io/cirruslabs/flutter:latest flutter build web --release

# Serve with nginx on port 8889
docker run -d --name wedding_planner_web_test \
  -v /mnt/repo/WeeddingPlannerApp/wedding_planner/build/web:/usr/share/nginx/html:ro \
  -p 8889:80 \
  nginx:alpine
```

**Access:** `http://<server-ip>:8889`

**To update after new build:**
```bash
docker restart wedding_planner_web_test
```

---

### SKILL-018: Flutter Web "No Internet Connection" Error
**Problem:** Flutter web app shows "No internet connection" when trying to login or make API calls.

**Root Cause:**
1. The backend API is not running, OR
2. The API URL is wrong (port conflict with other services), OR
3. The web app was built without the correct `--dart-define=API_BASE_URL`

**Solution:**

1. **Check if backend is running:**
```bash
curl http://10.1.13.98:3010/health
# Should return {"status":"ok",...}
```

2. **If not running, start the backend:**
```bash
cd /mnt/repo/WeeddingPlannerApp
docker compose up -d postgres redis api
```

3. **Note:** Default port 3000 conflicts with other apps. Wedding Planner API uses port **3010**.

4. **Rebuild web app with correct API URL:**
```bash
cd /mnt/repo/WeeddingPlannerApp/wedding_planner
docker run --rm -v "$(pwd)":/app -v "flutter_pub_cache:/root/.pub-cache" -w /app \
  ghcr.io/cirruslabs/flutter:latest \
  flutter build web --release --dart-define=API_BASE_URL=http://10.1.13.98:3010/api/v1
```

5. **Restart web server:**
```bash
docker restart wedding_planner_web_test
```

**Files Modified:**
- `docker-compose.yml` (changed API port from 3000 to 3010)
- `lib/config/injection.dart` (default API URL)

**Important URLs:**
- Backend API: `http://10.1.13.98:3010/api/v1`
- Flutter Web: `http://10.1.13.98:8889`

---

## How to Add New Skills

When fixing a problem:

1. **Identify the category** (Auth, Navigation, UI, State, API, Error)
2. **Create new SKILL-XXX entry** with:
   - Clear problem description
   - Root cause analysis
   - Solution with code snippet
   - Files modified/created
3. **Add to table of contents** if new category
4. **Commit with message** referencing skill ID

---

## Quick Lookup by Symptom

| Symptom | Likely Skill |
|---------|--------------|
| Wrong page after login | SKILL-001 |
| Can access wrong routes | SKILL-002 |
| Vendor has no onboarding | SKILL-003 |
| Button doesn't respond | SKILL-004 |
| Date picker not showing | SKILL-005 |
| Nav bar looks different | SKILL-006 |
| Can't logout | SKILL-007 |
| UI not updating | SKILL-009 |
| 401 errors | SKILL-010 |
| Null errors in JSON | SKILL-012 |
| Navigator errors | SKILL-013 |
| setState after dispose | SKILL-014 |
| BlocProvider not found | SKILL-015 |
| Docs in wrong folder | SKILL-016 |
| Web server port issue | SKILL-017 |
| Web app "No internet connection" | SKILL-018 |
| Service Worker API unavailable | SKILL-019 |
| Firebase OAuth domain not authorized | SKILL-020 |
| Vendor "Failed to update profile" | SKILL-021 |
| Vendor "Failed to create package" | SKILL-022 |
| "Failed to load vendors" on themes | SKILL-023 |
| Wedding date not saved after registration | SKILL-024 |
| Double /api/v1 in URL | SKILL-025 |
| API endpoints returning 404 | SKILL-026 |
| Couple onboarding not saving to API | SKILL-027 |
| Vendor onboarding not creating profile | SKILL-028 |
| 404 errors on guests/budget/tasks | SKILL-029 |
| Wrong API URLs in Flutter | SKILL-029 |
| 409 Conflict on wedding creation | SKILL-030 |
| Wedding already exists error | SKILL-030 |

---

## Web Platform Issues

### SKILL-019: Service Worker API Unavailable
**Problem:** Console shows "Service Worker API unavailable. The current context is NOT secure."

**Root Cause:** Flutter web service workers require HTTPS. When running on HTTP (not secure context), service workers are disabled.

**Impact:**
- No offline caching
- No PWA features
- Warning in console (not blocking)

**Solution:**
- For **development**: Ignore this warning - app still works
- For **production**: Deploy with HTTPS (SSL certificate required)

**Workaround:** None needed for development. The app functions without service workers.

---

### SKILL-020: Firebase OAuth Domain Not Authorized
**Problem:** Console shows "The current domain is not authorized for OAuth operations"

**Root Cause:** Firebase requires domains to be whitelisted for OAuth (Google Sign-In, etc.)

**Impact:**
- `signInWithPopup`, `signInWithRedirect` won't work
- Email/password auth still works

**Solution:**
1. Go to Firebase Console → Authentication → Settings
2. Click "Authorized domains" tab
3. Add your domain: `10.1.13.98` (or your server IP/domain)
4. For production, add your actual domain

**Files:** Firebase Console (external)

---

## Known API Gaps

> **Status:** These API endpoints are NOT YET IMPLEMENTED in the backend. The Flutter app expects them but they return 404/400.

### SKILL-021: Vendor "Failed to Update Profile" Error
**Problem:** Vendor onboarding fails with "Failed to update profile" on completing setup or editing profile.

**Root Cause:** Backend API endpoint not implemented or returning error.

**API Endpoints Needed:**
```
PUT /api/v1/vendors/profile
POST /api/v1/vendors/onboarding/complete
```

**Temporary Workaround:** Skip onboarding (data won't be saved)

**Status:** Backend implementation required

---

### SKILL-022: Vendor "Failed to Create Package" Error
**Problem:** Adding a new vendor package fails with "Failed to create package"

**Root Cause:** Backend API endpoint not implemented.

**API Endpoint Needed:**
```
POST /api/v1/vendors/packages
GET /api/v1/vendors/packages
PUT /api/v1/vendors/packages/:id
DELETE /api/v1/vendors/packages/:id
```

**Status:** Backend implementation required

---

### SKILL-023: "Failed to Load Vendors" on Trending Themes
**Problem:** Clicking trending themes on home page shows "Failed to load vendors"

**Console Errors:**
```
GET /api/v1/vendors/search 400 (Bad Request)
GET /api/v1/vendors/search/reviews 400 (Bad Request)
```

**Root Cause:** Search endpoint expects query parameters but receiving invalid format.

**API Endpoints to Fix:**
```
GET /api/v1/vendors/search?theme=:theme&category=:category
GET /api/v1/vendors/search/reviews
```

**Status:** Backend fix required - validate query parameters

---

### SKILL-024: Wedding Date Not Saved After Registration
**Problem:** After couple registration with wedding date selected, home page still shows "Select Wedding Date" card.

**Root Cause:** Wedding data from onboarding not being persisted or retrieved.

**Console Errors:**
```
GET /api/v1/weddings/me 404 (Not Found)
```

**API Endpoints Needed:**
```
POST /api/v1/weddings (create wedding during onboarding)
GET /api/v1/weddings/me (get current user's wedding)
PUT /api/v1/weddings/me (update wedding details)
```

**Status:** Backend implementation required

---

### SKILL-025: Double /api/v1 in Tasks URL
**Problem:** Tasks page makes request to `/api/v1/api/v1/tasks/stats` (double prefix)

**Console Error:**
```
GET http://10.1.13.98:3010/api/v1/api/v1/tasks/stats 404
```

**Root Cause:** Bug in Flutter code - base URL already includes `/api/v1` but endpoint also adds it.

**Solution:** Fix in `task_remote_datasource.dart`:
```dart
// WRONG
final response = await dio.get('/api/v1/tasks/stats');

// CORRECT
final response = await dio.get('/tasks/stats');
```

**Files Modified:**
- `lib/features/tasks/data/datasources/task_remote_datasource.dart`

**Status:** ✅ FIXED (Feb 10, 2026)

---

### SKILL-026: Multiple API Endpoints Returning 404
**Problem:** Home page and other features fail because backend endpoints don't exist.

**Missing Endpoints (404):**
```
GET /api/v1/weddings/me
GET /api/v1/weddings/me/budget/summary
GET /api/v1/weddings/me/tasks/stats
GET /api/v1/weddings/me/tasks
GET /api/v1/bookings
```

**Missing Endpoints (400 - Bad Request):**
```
GET /api/v1/vendors/search
GET /api/v1/vendors/search/reviews
```

**Impact:**
- Home dashboard shows errors/empty states
- Budget tracker non-functional
- Task management non-functional
- Vendor search non-functional

**Status:** Backend implementation required (Phase 1 incomplete)

**Priority Order:**
1. `GET /api/v1/weddings/me` - Critical for home page
2. `POST/GET /api/v1/vendors/packages` - Critical for vendor app
3. `GET /api/v1/vendors/search` - Critical for vendor discovery
4. Budget and Task endpoints - Medium priority

---

### SKILL-027: Couple Onboarding Not Saving to API
**Problem:** Couple onboarding flow collects data but doesn't save it to the backend API.

**Root Cause:** `onboarding_bloc.dart` had a TODO comment simulating success instead of calling the API.

**Solution:**
1. Added `createWedding` method to `HomeRemoteDataSource`:
```dart
Future<WeddingModel> createWedding(Map<String, dynamic> data) async {
  final response = await dio.post<Map<String, dynamic>>('/weddings', data: data);
  if (response.statusCode == 201 && response.data != null) {
    return WeddingModel.fromJson(response.data!['data'] as Map<String, dynamic>);
  }
  throw ServerException(message: 'Failed to create wedding', statusCode: response.statusCode);
}
```

2. Added `createWedding` to `HomeRepository` interface and implementation

3. Updated `OnboardingBloc` to inject `HomeRepository` and call API:
```dart
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final HomeRepository _homeRepository;

  OnboardingBloc({required HomeRepository homeRepository})
      : _homeRepository = homeRepository,
        super(const OnboardingState()) {
    // ... handlers
  }

  Future<void> _onSubmitted(...) async {
    final result = await _homeRepository.createWedding(
      weddingDate: state.data.hasWeddingDate ? state.data.weddingDate : null,
      budget: state.data.budget,
      currency: state.data.currency,
      guestCount: state.data.guestCount,
      styles: state.data.styles.map((s) => s.name).toList(),
      traditions: state.data.traditions.map((t) => t.name).toList(),
    );
    // Handle result
  }
}
```

4. Updated `OnboardingPage` to inject repository:
```dart
return BlocProvider(
  create: (_) => OnboardingBloc(homeRepository: getIt<HomeRepository>()),
  child: const _OnboardingView(),
);
```

**Files Modified:**
- `lib/features/home/data/datasources/home_remote_datasource.dart`
- `lib/features/home/domain/repositories/home_repository.dart`
- `lib/features/home/data/repositories/home_repository_impl.dart`
- `lib/features/onboarding/presentation/bloc/onboarding_bloc.dart`
- `lib/features/onboarding/presentation/pages/onboarding_page.dart`

**Status:** FIXED_UNVERIFIED (Feb 11, 2026) - Needs end-to-end testing

**Verification Needed:**
- [ ] Register new couple account
- [ ] Complete onboarding flow
- [ ] Check network tab - POST /weddings should succeed
- [ ] Verify wedding appears on home page

**Related Error:** See ERROR_TRACKER.md ERR-001 for 409 handling

---

### SKILL-028: Vendor Onboarding Not Creating Profile
**Problem:** Vendor onboarding tries to update profile that doesn't exist yet.

**Root Cause:**
- When a user registers as a vendor, only a user record is created (with `user_type: 'vendor'`)
- The vendor profile (vendors table) is NOT automatically created
- Vendor onboarding called `PUT /vendors/me` which requires an existing profile

**Solution:**
1. Added `RegisterVendorRequest` class to repository:
```dart
class RegisterVendorRequest {
  final String businessName;
  final String categoryId;
  final String? description;
  final String? city;
  final String? country;
  final String? priceRange;

  Map<String, dynamic> toJson() => {
    'businessName': businessName,
    'categoryId': categoryId,
    // ... optional fields
  };
}
```

2. Added `registerVendor` method to `VendorAppRepository` and datasource:
```dart
Future<VendorModel> registerVendor(RegisterVendorRequest request) async {
  final response = await dio.post('/vendors/register', data: request.toJson());
  return VendorModel.fromJson(response.data['data']);
}
```

3. Added `RegisterVendorProfile` event and handler to BLoC

4. Updated `VendorOnboardingPage` to use registration instead of update:
```dart
context.read<VendorPackagesBloc>().add(
  RegisterVendorProfile(
    RegisterVendorRequest(
      businessName: _businessNameController.text.trim(),
      categoryId: _selectedCategoryIds.first, // Backend requires single category
      description: _descriptionController.text.trim(),
      priceRange: _selectedPriceRange,
    ),
  ),
);
```

**Files Modified:**
- `lib/features/vendor_app/domain/repositories/vendor_app_repository.dart`
- `lib/features/vendor_app/data/repositories/vendor_app_repository_impl.dart`
- `lib/features/vendor_app/data/datasources/vendor_app_remote_datasource.dart`
- `lib/features/vendor_app/presentation/bloc/vendor_packages_event.dart`
- `lib/features/vendor_app/presentation/bloc/vendor_packages_bloc.dart`
- `lib/features/vendor_app/presentation/pages/vendor_onboarding_page.dart`

**Note:** Backend `registerAsVendor` endpoint only accepts a single `categoryId`, so if multiple categories are selected, only the first is used for registration.

**Status:** FIXED_UNVERIFIED (Feb 11, 2026) - Needs end-to-end testing

**Verification Needed:**
- [ ] Register new vendor account
- [ ] Complete vendor onboarding flow
- [ ] Check network tab - POST /vendors/register should succeed
- [ ] Verify vendor dashboard loads

**Related Error:** See ERROR_TRACKER.md ERR-002 for 500 error if categoryId is invalid

---

### SKILL-029: Flutter Datasources Using Wrong API URL Patterns
**Problem:** Flutter datasources were calling top-level URLs (`/guests`, `/budget`, `/tasks`) instead of wedding-scoped URLs (`/weddings/{id}/guests`, `/weddings/me/tasks`, etc.), causing 404 errors.

**Root Cause:** Backend uses wedding-scoped routes but Flutter datasources weren't updated to match.

**Solution:**

1. **For Tasks** - Use `/weddings/me/tasks` pattern (backend resolves wedding from auth token):
```dart
// In task_remote_datasource.dart
final response = await dio.get('/weddings/me/tasks', queryParameters: queryParams);
final response = await dio.get('/weddings/me/tasks/stats');
```

2. **For Guests/Budget** - Add weddingId parameter to all methods:
```dart
// In guest_remote_datasource.dart
Future<PaginatedGuests> getGuests(String weddingId, GuestFilter filter) async {
  final response = await dio.get('/weddings/$weddingId/guests', ...);
}

// In budget_remote_datasource.dart
Future<BudgetModel> getBudget(String weddingId) async {
  final response = await dio.get('/weddings/$weddingId/budget');
}
```

3. **Update Repository interfaces** - Add weddingId to method signatures
4. **Update BLoCs** - Store weddingId in state, add initialization event

**Usage in BLoC:**
```dart
// Initialize with wedding ID before loading data
context.read<GuestBloc>().add(InitializeGuests(weddingId));

// Get wedding ID from HomeRepository
final wedding = await homeRepository.getWedding();
if (wedding != null) {
  context.read<GuestBloc>().add(InitializeGuests(wedding.id));
}
```

**Files Modified:**
- `lib/features/tasks/data/datasources/task_remote_datasource.dart`
- `lib/features/guests/data/datasources/guest_remote_datasource.dart`
- `lib/features/guests/domain/repositories/guest_repository.dart`
- `lib/features/guests/data/repositories/guest_repository_impl.dart`
- `lib/features/guests/presentation/bloc/guest_bloc.dart`
- `lib/features/guests/presentation/bloc/guest_state.dart`
- `lib/features/guests/presentation/bloc/guest_event.dart`
- `lib/features/budget/data/datasources/budget_remote_datasource.dart`
- `lib/features/budget/domain/repositories/budget_repository.dart`
- `lib/features/budget/data/repositories/budget_repository_impl.dart`

**Status:** FIXED_UNVERIFIED (Feb 13, 2026)

**Related Error:** See ERROR_TRACKER.md ERR-004

---

### SKILL-030: Handling 409 Conflict in Wedding Creation
**Problem:** When user tries to create a wedding but already has one (e.g., page refresh during onboarding, navigating back and resubmitting), the API returns 409 Conflict which was shown as an error.

**Root Cause:** Backend correctly returns 409 when user already has a wedding, but Flutter treated this as an error instead of recognizing the wedding exists.

**Solution:**

1. **Add ConflictFailure class** (`lib/core/errors/failures.dart`):
```dart
/// Conflict failure (409) - resource already exists
class ConflictFailure extends Failure {
  const ConflictFailure({
    super.message = 'Resource already exists',
    super.code = 409,
  });
}
```

2. **Handle 409 in repository** (`home_repository_impl.dart`):
```dart
on ServerException catch (e) {
  // Handle 409 Conflict - wedding already exists
  if (e.statusCode == 409) {
    return Left(ConflictFailure(message: e.message));
  }
  return Left(ServerFailure(message: e.message, code: e.statusCode));
}
```

3. **Treat 409 as success in BLoC** (`onboarding_bloc.dart`):
```dart
result.fold(
  (failure) {
    // Handle 409 Conflict as success - wedding already exists
    if (failure is ConflictFailure) {
      emit(state.copyWith(
        currentStep: OnboardingStep.complete,
        isSubmitting: false,
        weddingAlreadyExists: true,
      ));
    } else {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      ));
    }
  },
  (wedding) { /* success */ },
);
```

**Files Modified:**
- `lib/core/errors/failures.dart` - Added ConflictFailure
- `lib/features/home/data/repositories/home_repository_impl.dart` - Handle 409
- `lib/features/onboarding/presentation/bloc/onboarding_bloc.dart` - Treat 409 as success
- `lib/features/onboarding/presentation/bloc/onboarding_state.dart` - Added weddingAlreadyExists

**Status:** FIXED_UNVERIFIED (Feb 13, 2026)

**Related Error:** See ERROR_TRACKER.md ERR-001
