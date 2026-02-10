# Wedding Planner App - Flutter Design System & Architecture

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Design System](#design-system)
4. [State Management](#state-management)
5. [Folder Structure](#folder-structure)
6. [Component Library](#component-library)
7. [Navigation & Routing](#navigation--routing)
8. [API Integration](#api-integration)
9. [Code Patterns & Examples](#code-patterns--examples)
10. [Naming Conventions](#naming-conventions)

---

## Project Overview

**App Name:** Wedding Planner
**Platform:** Flutter (iOS, Android, Web)
**Theme:** Dark glassmorphism design
**Target Users:** Couples planning weddings & Vendors offering services

### Key Features
- **Couple App:** Home dashboard, task management, vendor discovery, bookings, guest management, budget tracking, chat
- **Vendor App:** Dashboard, booking management, package management, availability, earnings, profile

---

## Architecture

### Clean Architecture with Feature-First Structure

```
lib/
├── config/                 # App configuration (routes, injection, themes)
├── core/                   # Shared core utilities
│   ├── constants/          # App-wide constants (colors, typography, spacing)
│   ├── errors/             # Error handling (failures, exceptions)
│   └── utils/              # Utility functions
├── features/               # Feature modules (each self-contained)
│   └── [feature_name]/
│       ├── data/           # Data layer
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/         # Domain layer
│       │   ├── entities/
│       │   └── repositories/
│       └── presentation/   # Presentation layer
│           ├── bloc/
│           ├── pages/
│           └── widgets/
├── shared/                 # Shared widgets and utilities
│   └── widgets/
│       ├── buttons/
│       ├── inputs/
│       ├── feedback/
│       └── layout/
└── l10n/                   # Localization files
```

---

## Design System

### Color Palette

```dart
// File: lib/core/constants/app_colors.dart

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFFE91E63);        // Pink/Rose
  static const Color primaryLight = Color(0xFFFF6090);
  static const Color primaryDark = Color(0xFFB0003A);

  // Accent Colors
  static const Color accent = Color(0xFF00BCD4);         // Cyan
  static const Color accentPurple = Color(0xFF9C27B0);   // Purple
  static const Color accentCyan = Color(0xFF00BCD4);     // Cyan

  // Background Colors (Dark Theme)
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color surfaceDark = Color(0xFF1A1A1A);

  // Glass Effect Colors
  static const Color glassBackground = Color(0x1AFFFFFF);  // 10% white
  static const Color glassBorder = Color(0x33FFFFFF);      // 20% white

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);      // White
  static const Color textSecondary = Color(0xB3FFFFFF);    // 70% white
  static const Color textTertiary = Color(0x80FFFFFF);     // 50% white

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Utility
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color divider = Color(0x1AFFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

### Typography

```dart
// File: lib/core/constants/app_typography.dart

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';  // Or system default

  // Hero/Display
  static const TextStyle hero = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
  );

  // Buttons
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // Special
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  static const TextStyle countdown = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle countdownUnit = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 2,
    color: AppColors.textSecondary,
  );
}
```

### Spacing

```dart
// File: lib/core/constants/app_spacing.dart

class AppSpacing {
  AppSpacing._();

  static const double micro = 4.0;
  static const double small = 8.0;
  static const double base = 12.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 100.0;
}
```

---

## State Management

### BLoC Pattern

Every feature uses **BLoC (Business Logic Component)** with three files:
- `[feature]_bloc.dart` - Business logic
- `[feature]_event.dart` - Input events
- `[feature]_state.dart` - Output states

#### Event Pattern

```dart
// File: [feature]_event.dart

import 'package:equatable/equatable.dart';

abstract class FeatureEvent extends Equatable {
  const FeatureEvent();

  @override
  List<Object?> get props => [];
}

class FeatureLoadRequested extends FeatureEvent {
  const FeatureLoadRequested();
}

class FeatureItemSelected extends FeatureEvent {
  final String itemId;

  const FeatureItemSelected(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class FeatureRefreshRequested extends FeatureEvent {
  const FeatureRefreshRequested();
}
```

#### State Pattern

```dart
// File: [feature]_state.dart

import 'package:equatable/equatable.dart';

enum FeatureStatus {
  initial,
  loading,
  loaded,
  error,
}

class FeatureState extends Equatable {
  final FeatureStatus status;
  final List<Item> items;
  final String? errorMessage;
  final bool isRefreshing;

  const FeatureState({
    this.status = FeatureStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.isRefreshing = false,
  });

  bool get isLoading => status == FeatureStatus.loading;
  bool get hasError => status == FeatureStatus.error;
  bool get isLoaded => status == FeatureStatus.loaded;

  FeatureState copyWith({
    FeatureStatus? status,
    List<Item>? items,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return FeatureState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, isRefreshing];
}
```

#### BLoC Pattern

```dart
// File: [feature]_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '[feature]_event.dart';
import '[feature]_state.dart';

class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final FeatureRepository repository;

  FeatureBloc({required this.repository}) : super(const FeatureState()) {
    on<FeatureLoadRequested>(_onLoadRequested);
    on<FeatureRefreshRequested>(_onRefreshRequested);
    on<FeatureItemSelected>(_onItemSelected);
  }

  Future<void> _onLoadRequested(
    FeatureLoadRequested event,
    Emitter<FeatureState> emit,
  ) async {
    emit(state.copyWith(status: FeatureStatus.loading));

    final result = await repository.getItems();

    result.fold(
      (failure) => emit(state.copyWith(
        status: FeatureStatus.error,
        errorMessage: failure.message,
      )),
      (items) => emit(state.copyWith(
        status: FeatureStatus.loaded,
        items: items,
      )),
    );
  }

  // ... other handlers
}
```

---

## Component Library

### Glass Card (Glassmorphism)

```dart
// File: lib/shared/widgets/glass_card.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.glassBackground,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.glassBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Icon(
              icon,
              color: AppColors.textPrimary,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double? height;

  const GlassButton({
    super.key,
    required this.child,
    required this.onTap,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.glassBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class BackgroundGlow extends StatelessWidget {
  final Color color;
  final Alignment alignment;
  final double size;

  const BackgroundGlow({
    super.key,
    required this.color,
    required this.alignment,
    this.size = 300,
  });

  @override
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
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### Primary Button

```dart
// File: lib/shared/widgets/buttons/primary_button.dart

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: (isLoading || isDisabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Text(text, style: AppTypography.buttonMedium),
      ),
    );
  }
}
```

### App Text Field

```dart
// File: lib/shared/widgets/inputs/app_text_field.dart

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final void Function(String)? onSubmitted;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              validator: validator,
              maxLines: maxLines,
              onFieldSubmitted: onSubmitted,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: AppColors.glassBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

### Error State Widget

```dart
// File: lib/shared/widgets/feedback/error_state.dart

class ErrorState extends StatelessWidget {
  final String title;
  final String? description;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryButtonTap;
  final IconData icon;

  const ErrorState({
    super.key,
    required this.title,
    this.description,
    this.primaryButtonText,
    this.onPrimaryButtonTap,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (primaryButtonText != null && onPrimaryButtonTap != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                text: primaryButtonText!,
                onPressed: onPrimaryButtonTap!,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Empty State Widget

```dart
// File: lib/shared/widgets/feedback/empty_state.dart

class EmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.h4.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## Navigation & Routing

### Using GoRouter

```dart
// File: lib/config/routes.dart

import 'package:go_router/go_router.dart';

class AppRoutes {
  AppRoutes._();

  // Auth Routes
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';

  // Couple Routes
  static const String home = '/home';
  static const String tasks = '/tasks';
  static const String vendors = '/vendors';
  static const String chat = '/chat';
  static const String profile = '/profile';

  // Vendor Routes
  static const String vendorHome = '/vendor';
  static const String vendorBookings = '/vendor/bookings';
  static const String vendorProfile = '/vendor/profile';
}

// Navigation usage in widgets:
// context.go(AppRoutes.home);        // Replace current route
// context.push(AppRoutes.profile);   // Push on top
// context.pop();                     // Go back
```

### Shell Routes (Bottom Navigation)

The app uses `ShellRoute` for bottom navigation:

```dart
ShellRoute(
  builder: (context, state, child) => MainScaffold(child: child),
  routes: [
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (context, state) => NoTransitionPage(
        child: BlocProvider(
          create: (_) => getIt<HomeBloc>(),
          child: const HomePage(),
        ),
      ),
    ),
    // ... other routes
  ],
),
```

---

## API Integration

### Repository Pattern with Either

```dart
// File: lib/core/errors/failures.dart

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
```

### Repository Interface

```dart
// File: lib/features/[feature]/domain/repositories/[feature]_repository.dart

import 'package:dartz/dartz.dart';

abstract class FeatureRepository {
  Future<Either<Failure, List<Item>>> getItems();
  Future<Either<Failure, Item>> getItemById(String id);
  Future<Either<Failure, Item>> createItem(CreateItemRequest request);
  Future<Either<Failure, Item>> updateItem(String id, UpdateItemRequest request);
  Future<Either<Failure, void>> deleteItem(String id);
}
```

### Repository Implementation

```dart
// File: lib/features/[feature]/data/repositories/[feature]_repository_impl.dart

class FeatureRepositoryImpl implements FeatureRepository {
  final FeatureRemoteDataSource remoteDataSource;

  FeatureRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Item>>> getItems() async {
    try {
      final models = await remoteDataSource.getItems();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

### Data Source

```dart
// File: lib/features/[feature]/data/datasources/[feature]_remote_datasource.dart

abstract class FeatureRemoteDataSource {
  Future<List<ItemModel>> getItems();
  Future<ItemModel> getItemById(String id);
}

class FeatureRemoteDataSourceImpl implements FeatureRemoteDataSource {
  final Dio dio;

  FeatureRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ItemModel>> getItems() async {
    final response = await dio.get('/items');
    final data = response.data['data'] as List;
    return data.map((json) => ItemModel.fromJson(json)).toList();
  }
}
```

### Model with fromJson/toJson

```dart
// File: lib/features/[feature]/data/models/[feature]_model.dart

class ItemModel {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  const ItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };

  Item toEntity() => Item(
    id: id,
    name: name,
    description: description,
    createdAt: createdAt,
  );
}
```

---

## Code Patterns & Examples

### Page Structure Template

```dart
// Standard page structure

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/feedback/error_state.dart';
import '../bloc/feature_bloc.dart';
import '../bloc/feature_event.dart';
import '../bloc/feature_state.dart';

class FeaturePage extends StatefulWidget {
  const FeaturePage({super.key});

  @override
  State<FeaturePage> createState() => _FeaturePageState();
}

class _FeaturePageState extends State<FeaturePage> {
  @override
  void initState() {
    super.initState();
    context.read<FeatureBloc>().add(const FeatureLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocBuilder<FeatureBloc, FeatureState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const _LoadingState();
          }

          if (state.hasError) {
            return ErrorState(
              title: 'Something went wrong',
              description: state.errorMessage,
              primaryButtonText: 'Retry',
              onPrimaryButtonTap: () {
                context.read<FeatureBloc>().add(const FeatureLoadRequested());
              },
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceDark,
            onRefresh: () async {
              context.read<FeatureBloc>().add(const FeatureRefreshRequested());
            },
            child: Stack(
              children: [
                // Background glows
                const BackgroundGlow(
                  color: AppColors.accentPurple,
                  alignment: Alignment(-1.5, -0.5),
                  size: 400,
                ),
                const BackgroundGlow(
                  color: AppColors.accentCyan,
                  alignment: Alignment(1.5, 0.8),
                  size: 350,
                ),

                // Content
                CustomScrollView(
                  slivers: [
                    _buildAppBar(context),
                    SliverToBoxAdapter(
                      child: _buildContent(context, state),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.8),
      surfaceTintColor: Colors.transparent,
      pinned: true,
      title: Text(
        'Feature Title',
        style: AppTypography.h3.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, FeatureState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content here
          const SizedBox(height: 100), // Bottom padding for nav
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
```

### List Item Card Pattern

```dart
class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;

  const ItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            // Leading icon/image
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.item,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Trailing
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Dialog Pattern

```dart
void _showConfirmDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Confirm Action',
        style: AppTypography.h4.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        'Are you sure you want to proceed?',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            'Cancel',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            // Perform action
          },
          child: Text(
            'Confirm',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    ),
  );
}
```

### Bottom Sheet Pattern

```dart
void _showOptionsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surfaceDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Options',
            style: AppTypography.h4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildOption(
            icon: Icons.edit,
            label: 'Edit',
            onTap: () {
              Navigator.pop(ctx);
              // Handle edit
            },
          ),
          _buildOption(
            icon: Icons.delete,
            label: 'Delete',
            color: AppColors.error,
            onTap: () {
              Navigator.pop(ctx);
              // Handle delete
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

Widget _buildOption({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  Color? color,
}) {
  return ListTile(
    onTap: onTap,
    leading: Icon(icon, color: color ?? AppColors.textPrimary),
    title: Text(
      label,
      style: AppTypography.labelLarge.copyWith(
        color: color ?? AppColors.textPrimary,
      ),
    ),
  );
}
```

---

## Naming Conventions

### Files
- `snake_case.dart` for all Dart files
- Feature folders: `feature_name/`
- BLoC files: `feature_bloc.dart`, `feature_event.dart`, `feature_state.dart`
- Page files: `feature_page.dart`, `feature_detail_page.dart`
- Widget files: `feature_card.dart`, `feature_list_item.dart`

### Classes
- `PascalCase` for classes: `FeatureBloc`, `FeaturePage`
- `PascalCase` for enums: `FeatureStatus`
- Private classes prefixed with underscore: `_PrivateWidget`

### Variables & Functions
- `camelCase` for variables: `isLoading`, `itemCount`
- `camelCase` for functions: `loadData()`, `onItemTapped()`
- Private members prefixed with underscore: `_controller`

### Constants
- `camelCase` for constants: `AppColors.primary`, `AppSpacing.large`

### Events
- Past tense or action-based: `FeatureLoadRequested`, `FeatureItemSelected`

### States
- Noun-based: `FeatureState`, `FeatureStatus`

---

## Dependency Injection

Using `get_it` for DI:

```dart
// File: lib/config/injection.dart

import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Data sources
  getIt.registerLazySingleton<FeatureRemoteDataSource>(
    () => FeatureRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Repositories
  getIt.registerLazySingleton<FeatureRepository>(
    () => FeatureRepositoryImpl(
      remoteDataSource: getIt<FeatureRemoteDataSource>(),
    ),
  );

  // BLoCs
  getIt.registerFactory<FeatureBloc>(
    () => FeatureBloc(repository: getIt<FeatureRepository>()),
  );
}
```

---

## Key Dependencies

```yaml
# pubspec.yaml key dependencies

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  go_router: ^12.1.1
  get_it: ^7.6.4
  dio: ^5.3.3
  dartz: ^0.10.1
  equatable: ^2.0.5
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
```

---

## Quick Reference

### Common Widget Usage

```dart
// Background with glows
Stack(
  children: [
    const BackgroundGlow(color: AppColors.accentPurple, alignment: Alignment(-1, -0.5), size: 400),
    const BackgroundGlow(color: AppColors.primary, alignment: Alignment(1, 0.8), size: 350),
    // Your content
  ],
)

// Glass card
GlassCard(
  padding: const EdgeInsets.all(16),
  child: Text('Content'),
)

// Primary button
PrimaryButton(
  text: 'Submit',
  onPressed: () {},
  isLoading: state.isLoading,
)

// Text field
AppTextField(
  label: 'Email',
  hint: 'Enter your email',
  controller: _emailController,
  validator: (value) => value?.isEmpty == true ? 'Required' : null,
)
```

### Common Patterns

```dart
// BLoC Consumer for listening + building
BlocConsumer<FeatureBloc, FeatureState>(
  listener: (context, state) {
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
  },
  builder: (context, state) {
    return YourWidget();
  },
)

// BLoC Builder for building only
BlocBuilder<FeatureBloc, FeatureState>(
  builder: (context, state) {
    if (state.isLoading) return const CircularProgressIndicator();
    return YourWidget();
  },
)

// BLoC Listener for side effects only
BlocListener<FeatureBloc, FeatureState>(
  listener: (context, state) {
    if (state.isSuccess) context.pop();
  },
  child: YourWidget(),
)

// Dispatch event
context.read<FeatureBloc>().add(const FeatureLoadRequested());

// Navigate
context.go(AppRoutes.home);      // Replace
context.push(AppRoutes.detail);  // Push
context.pop();                   // Back
```

---

## Notes for Implementation

1. **Always use dark theme** - `AppColors.backgroundDark` as scaffold background
2. **Always add glassmorphism effects** - Use `BackdropFilter` and `ClipRRect`
3. **Always add background glows** - At least 2 `BackgroundGlow` widgets per page
4. **Use consistent spacing** - Only use values from `AppSpacing`
5. **Use consistent typography** - Only use styles from `AppTypography`
6. **Handle all states** - Loading, error, empty, and success states
7. **Add pull-to-refresh** - For list screens
8. **Add bottom padding** - 100px at bottom of scrollable content for nav bar
9. **Test on multiple screen sizes** - Especially for responsive layouts
