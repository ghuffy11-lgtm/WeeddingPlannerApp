# AI Builder Quick Start Guide

## IMPORTANT: Check SKILLS.md First!

Before troubleshooting ANY issue, check [SKILLS.md](./SKILLS.md) - it contains solutions to common problems.

After fixing ANY issue, ADD it to SKILLS.md with:
- Problem description
- Root cause
- Solution code
- Files modified

---

## TL;DR - Build Flutter components matching this spec

---

## Theme: Dark Glassmorphism

```dart
// ALWAYS use these colors
backgroundColor: Color(0xFF0D0D0D),  // Page background
surfaceColor: Color(0xFF1A1A1A),     // Cards, dialogs
glassBackground: Color(0x1AFFFFFF),  // 10% white - glass fill
glassBorder: Color(0x33FFFFFF),      // 20% white - glass border
primary: Color(0xFFE91E63),          // Pink - buttons, accents
accent: Color(0xFF00BCD4),           // Cyan - secondary accent
accentPurple: Color(0xFF9C27B0),     // Purple - glows
textPrimary: Color(0xFFFFFFFF),      // White
textSecondary: Color(0xB3FFFFFF),    // 70% white
textTertiary: Color(0x80FFFFFF),     // 50% white
```

---

## Required Page Structure

Every page MUST have:

```dart
Scaffold(
  backgroundColor: Color(0xFF0D0D0D),
  body: Stack(
    children: [
      // 1. Background glows (REQUIRED - at least 2)
      BackgroundGlow(color: Color(0xFF9C27B0), alignment: Alignment(-1, -0.5), size: 400),
      BackgroundGlow(color: Color(0xFF00BCD4), alignment: Alignment(1, 0.8), size: 350),

      // 2. Content
      CustomScrollView(
        slivers: [
          // Frosted app bar
          SliverAppBar(
            backgroundColor: Color(0xFF0D0D0D).withOpacity(0.8),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(color: Colors.transparent),
              ),
            ),
            title: Text('Title', style: TextStyle(color: Colors.white)),
          ),

          // Content with bottom padding for nav bar
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Your content
                SizedBox(height: 100), // REQUIRED - nav bar spacing
              ],
            ),
          ),
        ],
      ),
    ],
  ),
)
```

---

## Glass Card Component

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0x1AFFFFFF),  // Glass background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0x33FFFFFF)),  // Glass border
      ),
      child: YourContent(),
    ),
  ),
)
```

---

## Background Glow Component

```dart
class BackgroundGlow extends StatelessWidget {
  final Color color;
  final Alignment alignment;
  final double size;

  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## BLoC Pattern (MUST follow)

### 1. Event File
```dart
// feature_event.dart
abstract class FeatureEvent extends Equatable {
  const FeatureEvent();
  @override
  List<Object?> get props => [];
}

class LoadFeature extends FeatureEvent {
  const LoadFeature();
}

class RefreshFeature extends FeatureEvent {
  const RefreshFeature();
}
```

### 2. State File
```dart
// feature_state.dart
enum FeatureStatus { initial, loading, loaded, error }

class FeatureState extends Equatable {
  final FeatureStatus status;
  final List<Item> items;
  final String? error;

  const FeatureState({
    this.status = FeatureStatus.initial,
    this.items = const [],
    this.error,
  });

  bool get isLoading => status == FeatureStatus.loading;
  bool get hasError => status == FeatureStatus.error;

  FeatureState copyWith({...}) => FeatureState(...);

  @override
  List<Object?> get props => [status, items, error];
}
```

### 3. BLoC File
```dart
// feature_bloc.dart
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final FeatureRepository repository;

  FeatureBloc({required this.repository}) : super(const FeatureState()) {
    on<LoadFeature>(_onLoad);
  }

  Future<void> _onLoad(LoadFeature event, Emitter<FeatureState> emit) async {
    emit(state.copyWith(status: FeatureStatus.loading));

    final result = await repository.getItems();

    result.fold(
      (failure) => emit(state.copyWith(
        status: FeatureStatus.error,
        error: failure.message,
      )),
      (items) => emit(state.copyWith(
        status: FeatureStatus.loaded,
        items: items,
      )),
    );
  }
}
```

---

## Repository Pattern

```dart
// Abstract repository
abstract class FeatureRepository {
  Future<Either<Failure, List<Item>>> getItems();
}

// Implementation
class FeatureRepositoryImpl implements FeatureRepository {
  final FeatureDataSource dataSource;

  @override
  Future<Either<Failure, List<Item>>> getItems() async {
    try {
      final result = await dataSource.getItems();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

---

## Typography Sizes

```dart
hero: 32px, w700      // Page titles
h1: 28px, w700        // Section titles
h2: 24px, w600        // Card titles
h3: 20px, w600        // App bar titles
h4: 18px, w600        // Subtitles
bodyLarge: 16px, w400
bodyMedium: 14px, w400
bodySmall: 12px, w400
labelLarge: 14px, w500
labelMedium: 12px, w500
```

---

## Spacing Values

```dart
micro: 4
small: 8
base: 12
medium: 16
large: 24
xl: 32
xxl: 48

radiusSmall: 8
radiusMedium: 12
radiusLarge: 16
radiusXL: 24
```

---

## Button Styles

### Primary Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFFE91E63),
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text('Button'),
)
```

### Glass Button
```dart
GestureDetector(
  onTap: () {},
  child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0x33FFFFFF)),
        ),
        child: Text('Glass Button', style: TextStyle(color: Colors.white)),
      ),
    ),
  ),
)
```

---

## Input Field Style

```dart
TextFormField(
  style: TextStyle(color: Colors.white),
  decoration: InputDecoration(
    labelText: 'Label',
    hintText: 'Hint',
    labelStyle: TextStyle(color: Color(0xB3FFFFFF)),
    hintStyle: TextStyle(color: Color(0x80FFFFFF)),
    filled: true,
    fillColor: Color(0x1AFFFFFF),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0x33FFFFFF)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0x33FFFFFF)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFFE91E63), width: 2),
    ),
  ),
)
```

---

## Dialog Style

```dart
showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    backgroundColor: Color(0xFF1A1A1A),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    title: Text('Title', style: TextStyle(color: Colors.white)),
    content: Text('Content', style: TextStyle(color: Color(0xB3FFFFFF))),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: Text('Cancel', style: TextStyle(color: Color(0xB3FFFFFF))),
      ),
      TextButton(
        onPressed: () {},
        child: Text('Confirm', style: TextStyle(color: Color(0xFFE91E63))),
      ),
    ],
  ),
);
```

---

## List Item Card Pattern

```dart
Container(
  margin: EdgeInsets.only(bottom: 12),
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Color(0xFF1A1A1A),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Color(0x33FFFFFF)),
  ),
  child: Row(
    children: [
      // Leading icon
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Color(0xFFE91E63).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.item, color: Color(0xFFE91E63)),
      ),
      SizedBox(width: 16),
      // Content
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            Text('Subtitle', style: TextStyle(color: Color(0x80FFFFFF), fontSize: 12)),
          ],
        ),
      ),
      // Trailing
      Icon(Icons.chevron_right, color: Color(0x80FFFFFF)),
    ],
  ),
)
```

---

## File Naming

```
lib/features/[feature_name]/
├── data/
│   ├── datasources/[feature]_remote_datasource.dart
│   ├── models/[feature]_model.dart
│   └── repositories/[feature]_repository_impl.dart
├── domain/
│   ├── entities/[feature].dart
│   └── repositories/[feature]_repository.dart
└── presentation/
    ├── bloc/
    │   ├── [feature]_bloc.dart
    │   ├── [feature]_event.dart
    │   └── [feature]_state.dart
    ├── pages/
    │   ├── [feature]_page.dart
    │   └── [feature]_detail_page.dart
    └── widgets/
        └── [feature]_card.dart
```

---

## Navigation

```dart
// Replace current route
context.go('/home');

// Push new route (can go back)
context.push('/details/123');

// Go back
context.pop();

// Pass data
context.push('/details', extra: myObject);

// Receive data
final data = GoRouterState.of(context).extra as MyObject;
```

---

## State Handling in UI

```dart
BlocBuilder<FeatureBloc, FeatureState>(
  builder: (context, state) {
    // Loading
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Color(0xFFE91E63)),
      );
    }

    // Error
    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Color(0xFFF44336), size: 64),
            SizedBox(height: 16),
            Text('Something went wrong', style: TextStyle(color: Colors.white)),
            SizedBox(height: 8),
            Text(state.error ?? '', style: TextStyle(color: Color(0xB3FFFFFF))),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<FeatureBloc>().add(LoadFeature()),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty
    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, color: Color(0x80FFFFFF), size: 64),
            SizedBox(height: 16),
            Text('No items yet', style: TextStyle(color: Color(0xB3FFFFFF))),
          ],
        ),
      );
    }

    // Success - show list
    return ListView.builder(
      itemCount: state.items.length,
      itemBuilder: (context, index) => ItemCard(item: state.items[index]),
    );
  },
)
```

---

## Checklist Before Submitting Code

- [ ] Uses dark background (`0xFF0D0D0D`)
- [ ] Has at least 2 `BackgroundGlow` widgets
- [ ] Uses glass effects where appropriate
- [ ] Has 100px bottom padding for nav bar
- [ ] Follows BLoC pattern (event/state/bloc files)
- [ ] Uses `Either<Failure, T>` for error handling
- [ ] Handles loading, error, empty states
- [ ] Uses correct color values (not hardcoded)
- [ ] Uses correct spacing values
- [ ] Uses correct typography styles
- [ ] Has pull-to-refresh for lists
- [ ] Has proper form validation
- [ ] Uses `context.go/push/pop` for navigation

## Checklist After Fixing Issues

- [ ] **Added fix to SKILLS.md** with problem, cause, solution
- [ ] Used SKILL-XXX numbering format
- [ ] Included code snippet
- [ ] Listed files modified
