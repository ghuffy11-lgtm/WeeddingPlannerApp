# Wedding Planner App - Documentation

## Quick Links

| Document | Description |
|----------|-------------|
| [Design System](./FLUTTER_DESIGN_SYSTEM.md) | Colors, typography, components, patterns |
| [API Integration](./API_INTEGRATION.md) | Backend endpoints, request/response formats |
| [Features Checklist](./FEATURES_CHECKLIST.md) | Feature status, priorities, entity definitions |

---

## For AI Assistants Building Components

When asked to build Flutter components for this wedding planner app, use these documents:

### 1. Read the Design System First
- Understand the dark glassmorphism theme
- Use only colors from `AppColors`
- Use only typography from `AppTypography`
- Use only spacing from `AppSpacing`
- Follow the BLoC pattern exactly

### 2. Check the Features Checklist
- See what features exist vs need building
- Understand entity structures
- Follow the folder organization

### 3. Reference API Integration
- Use correct endpoint paths
- Handle responses properly
- Implement error handling

---

## Project Summary

**Wedding Planner** is a dual-app Flutter application:

1. **Couple App** - For engaged couples to:
   - Plan their wedding (date, venue, budget)
   - Manage tasks and checklist
   - Discover and book vendors
   - Track guests and RSVPs
   - Manage budget and expenses
   - Chat with vendors

2. **Vendor App** - For service providers to:
   - Manage their business profile
   - Handle booking requests
   - Create service packages
   - Track earnings
   - Manage availability

---

## Design Philosophy

- **Dark Theme Only** - `#0D0D0D` background
- **Glassmorphism** - Frosted glass effects with blur
- **Gradient Accents** - Pink/purple primary colors
- **Background Glows** - Colored orbs for depth
- **Minimal & Clean** - Focus on content

---

## Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter | Cross-platform UI |
| flutter_bloc | State management |
| go_router | Navigation |
| get_it | Dependency injection |
| dio | HTTP client |
| dartz | Functional programming (Either) |
| Firebase | Chat (Firestore) |

---

## Key Patterns

### State Management
```
Event → BLoC → State
```

### Data Flow
```
UI → BLoC → Repository → DataSource → API
```

### Error Handling
```dart
Either<Failure, Success>
```

### Navigation
```dart
context.go('/route');     // Replace
context.push('/route');   // Push
context.pop();            // Back
```

---

## Important Notes

1. **Always use dark theme colors** - Never use white backgrounds
2. **Always add glass effects** - Use `BackdropFilter` and `ClipRRect`
3. **Always add background glows** - 2-3 `BackgroundGlow` widgets per page
4. **Always handle states** - Loading, error, empty, success
5. **Always follow BLoC pattern** - Separate event/state/bloc files
6. **Always use repository pattern** - Never call API directly from BLoC
7. **Always add bottom padding** - 100px for bottom nav overlap
