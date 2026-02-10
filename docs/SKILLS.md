# Skills & Troubleshooting Knowledge Base

> **Purpose:** This document captures all fixes, troubleshooting solutions, and learned patterns. Check here FIRST before investigating issues.

---

## Table of Contents
1. [Authentication & Routing](#authentication--routing)
2. [Navigation Issues](#navigation-issues)
3. [UI/UX Fixes](#uiux-fixes)
4. [State Management](#state-management)
5. [API Integration](#api-integration)
6. [Common Errors](#common-errors)

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
