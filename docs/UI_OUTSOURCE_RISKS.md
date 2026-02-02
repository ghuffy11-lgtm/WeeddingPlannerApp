# Potential Issues with Outsourcing UI to AI Tools

> **Tools:** Bolt.ai, Google Stitch, v0.dev, etc.
> **Risk Level:** Medium to High depending on approach

---

## Summary of Risks

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| Architecture mismatch | HIGH | Very High | Manual refactoring required |
| State management conflict | HIGH | Very High | Rewrite to use BLoC |
| Design system ignored | MEDIUM | High | Manual style updates |
| Navigation incompatibility | MEDIUM | High | Rewrite navigation |
| Duplicate code | MEDIUM | High | Delete and merge |
| No localization | MEDIUM | Very High | Add translation keys |
| No RTL support | HIGH | Very High | Manual RTL fixes |
| Poor code quality | LOW | Medium | Linting and refactor |

---

## Detailed Issues & Solutions

### 1. Architecture Mismatch

**Problem:**
Our app uses Clean Architecture:
```
lib/features/vendors/
├── domain/          # Entities, Repository interfaces
├── data/            # Models, DataSources, Repository impl
└── presentation/    # BLoC, Pages, Widgets
```

AI tools generate flat structures:
```
lib/
├── screens/
├── widgets/
└── models/
```

**Impact:**
- Generated code won't fit our folder structure
- Mixing concerns (UI + business logic + data)
- Hard to maintain long-term

**Solution:**
1. Ask AI to generate ONLY the widget/UI code
2. Manually move files to correct folders
3. Remove any business logic from generated code

**Time to fix:** 2-4 hours per feature

---

### 2. State Management Conflict

**Problem:**
We use `flutter_bloc`. AI tools typically generate:
- `setState()` (basic, doesn't scale)
- `Provider` (different pattern)
- `Riverpod` (different pattern)
- `GetX` (different pattern)

**Example - AI Generated:**
```dart
class VendorListPage extends StatefulWidget {
  @override
  _VendorListPageState createState() => _VendorListPageState();
}

class _VendorListPageState extends State<VendorListPage> {
  List<Vendor> vendors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVendors(); // Direct API call in widget!
  }

  void fetchVendors() async {
    final response = await http.get(...); // HTTP in UI layer!
    setState(() {
      vendors = ...;
      isLoading = false;
    });
  }
}
```

**What we need:**
```dart
class VendorListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorBloc, VendorState>(
      builder: (context, state) {
        if (state.isLoading) return LoadingWidget();
        return ListView.builder(
          itemCount: state.vendors.length,
          itemBuilder: (_, i) => VendorCard(vendor: state.vendors[i]),
        );
      },
    );
  }
}
```

**Solution:**
1. Extract ONLY the UI widgets (VendorCard, etc.)
2. Discard all state management code
3. Wrap with BlocBuilder/BlocProvider
4. Connect to our existing BLoC

**Time to fix:** 3-6 hours per feature

---

### 3. Design System Ignored

**Problem:**
AI tools use their own colors/fonts:
```dart
// AI Generated
Container(
  color: Color(0xFF6200EE), // Material purple, not our Rose Gold!
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16), // No typography system
  ),
)
```

**What we need:**
```dart
Container(
  color: AppColors.roseGold,
  child: Text(
    'Hello',
    style: AppTypography.bodyLarge,
  ),
)
```

**Solution:**
1. Find-and-replace colors with AppColors constants
2. Replace TextStyle with AppTypography
3. Replace padding values with AppSpacing

**Time to fix:** 1-2 hours per screen

---

### 4. Navigation Incompatibility

**Problem:**
We use `go_router`. AI tools might use:
```dart
// AI Generated
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => VendorDetailPage()),
);
```

**What we need:**
```dart
context.push('/vendors/${vendor.id}');
// or
context.go(AppRoutes.vendorDetail);
```

**Solution:**
1. Replace all Navigator calls with go_router
2. Update route parameters
3. Handle route arguments properly

**Time to fix:** 30 min - 1 hour per feature

---

### 5. No Localization (i18n)

**Problem:**
AI generates hardcoded strings:
```dart
Text('Book Now')
Text('Add to Favorites')
Text('Loading...')
```

**What we need:**
```dart
Text(AppLocalizations.of(context)!.bookNow)
Text(context.l10n.addToFavorites)
```

**Impact:**
- App won't work in Arabic, French, Spanish
- All strings need manual extraction

**Solution:**
1. Extract all strings to ARB files
2. Replace with localization calls
3. Add translations for all 4 languages

**Time to fix:** 2-4 hours per feature

---

### 6. No RTL (Right-to-Left) Support

**Problem:**
AI tools don't consider Arabic layout:
```dart
Row(
  children: [
    Icon(Icons.arrow_back), // Should flip in RTL!
    Padding(
      padding: EdgeInsets.only(left: 16), // Should be "start" not "left"
    ),
  ],
)
```

**What we need:**
```dart
Row(
  children: [
    Icon(Icons.arrow_back), // Automatically flips with Directionality
    Padding(
      padding: EdgeInsetsDirectional.only(start: 16), // RTL-aware
    ),
  ],
)
```

**Issues to fix:**
- `EdgeInsets.left/right` → `EdgeInsetsDirectional.start/end`
- `Alignment.centerLeft` → `AlignmentDirectional.centerStart`
- `TextAlign.left` → `TextAlign.start`
- Custom icons that should flip

**Time to fix:** 1-2 hours per screen

---

### 7. Duplicate/Conflicting Widgets

**Problem:**
AI might create widgets we already have:
- Their `CustomButton` vs our `PrimaryButton`
- Their `LoadingSpinner` vs our `LoadingState`
- Their `ErrorMessage` vs our `ErrorState`

**Solution:**
1. Inventory generated widgets
2. Map to existing widgets
3. Replace or delete duplicates

**Time to fix:** 1 hour

---

### 8. Dependency Injection Missing

**Problem:**
AI tools don't know about GetIt:
```dart
// AI Generated
class VendorService {
  final http = HttpClient(); // Creates its own instance
}
```

**What we need:**
```dart
// Already registered in injection.dart
final vendorRepo = getIt<VendorRepository>();
```

**Solution:**
- Remove any service/repository classes AI creates
- Use our existing DI setup

---

## Recommended Approach

### Option A: Use AI for Inspiration Only (SAFEST)
1. Generate UI in Bolt.ai/Stitch
2. Screenshot the designs
3. Manually recreate in our codebase
4. **Pros:** Full control, clean code
5. **Cons:** Slower, more work

### Option B: Use AI for Widget Code Only (BALANCED)
1. Generate individual widgets (cards, forms, lists)
2. Copy ONLY the `build()` method content
3. Wrap in our architecture
4. **Pros:** Faster than manual
5. **Cons:** Still needs significant editing

### Option C: Full Screen Generation (RISKY)
1. Generate complete screens
2. Refactor everything
3. **Pros:** Fastest initial output
4. **Cons:** Most time spent fixing issues

---

## Integration Checklist

After receiving AI-generated code, verify:

- [ ] Files in correct folder structure
- [ ] Uses `AppColors` not hardcoded colors
- [ ] Uses `AppTypography` not inline TextStyle
- [ ] Uses `AppSpacing` not hardcoded padding
- [ ] Uses `BlocBuilder`/`BlocProvider` for state
- [ ] Uses `go_router` for navigation
- [ ] Uses `getIt` for dependencies
- [ ] Strings extracted for localization
- [ ] RTL-compatible (EdgeInsetsDirectional, etc.)
- [ ] No duplicate widgets
- [ ] Passes `flutter analyze`
- [ ] Works on both Android and iOS

---

## Time Estimates

| Task | AI Generation | Integration/Fixes | Total |
|------|---------------|-------------------|-------|
| Vendor Browsing (4 screens) | 30 min | 8-12 hours | ~12 hours |
| Booking Flow (4 screens) | 30 min | 6-10 hours | ~10 hours |
| Guest Management (3 screens) | 20 min | 4-6 hours | ~6 hours |
| Budget Tracker (3 screens) | 20 min | 4-6 hours | ~6 hours |
| Task List (2 screens) | 15 min | 3-4 hours | ~4 hours |
| **Total** | **~2 hours** | **25-40 hours** | **~35 hours** |

**Note:** Building from scratch with our architecture might take similar time but result in cleaner code.

---

## Recommendation

**For your situation, I recommend Option B:**

1. Use AI tools to generate individual **widgets** (not full screens):
   - VendorCard
   - PackageCard
   - ReviewCard
   - GuestCard
   - BudgetCategoryChart

2. Build the **pages** yourself using our architecture

3. This gives you:
   - Fast UI prototyping
   - Clean architecture
   - Easier maintenance
   - Less refactoring

---

## Questions to Ask Before Starting

1. Can the AI tool export Flutter/Dart code? (Some only export React)
2. Can you specify a design system/colors?
3. Can you provide component constraints?
4. What's the code structure it generates?
5. Does it support custom fonts?
