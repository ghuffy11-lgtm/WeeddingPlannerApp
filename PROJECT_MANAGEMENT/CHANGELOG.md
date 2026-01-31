# Changelog

> All notable changes to this project will be documented in this file.
> Format: [Date] - [Change Type] - [Description]

---

## January 31, 2026 (Session 2)

### Added
- **Backend API Project** (`backend/`)
  - Complete Node.js/Express/TypeScript API structure
  - Prisma ORM with schema matching database
  - JWT authentication with access/refresh tokens
  - Redis caching integration
  - Error handling middleware
  - Request validation with Zod

- **API Routes & Controllers**
  - Auth: register, login, refresh token, forgot/reset password, email verification
  - Users: profile CRUD, password change
  - Categories: list, get, get vendors by category
  - Vendors: list, get, packages, reviews, portfolio, dashboard, registration
  - Weddings: CRUD, guests, budget items, tasks management
  - Bookings: create, accept/decline, complete, reviews

- **Backend Configuration**
  - `package.json` with all dependencies
  - `tsconfig.json` for TypeScript
  - `prisma/schema.prisma` with complete database model
  - `.env` and `.env.example` for environment variables
  - `Dockerfile` for containerization
  - `.gitignore` for backend

- **Docker Updates**
  - Enabled API service in `docker-compose.yml`
  - Added health check for API container

---

## January 30, 2026 (Session 1 - Part 3)

### Added
- **Docker Development Environment**
  - Created `docker-compose.yml` with PostgreSQL, Redis, Adminer, MailHog
  - Created `database/init.sql` with complete database schema
  - Added 15 default vendor categories (with translations)
  - Added default admin user

- **Development Setup Guide**
  - Created `docs/DEVELOPMENT_SETUP.md` with step-by-step instructions
  - Includes Docker commands, Flutter setup, troubleshooting
  - Network configuration for mobile testing

---

## January 30, 2026 (Session 1 - Part 2)

### Added
- **AI Agent Documentation System**
  - Created `AI_AGENTS_START_HERE.md` in project root - entry point for all AI agents
  - Added detailed documentation instructions to MASTER_INSTRUCTIONS.md
  - Added templates for CHANGELOG, SESSION_LOG entries
  - Added Quick Reference Card for AI agents
  - Added documentation checklist

- **Admin Panel Architecture** (in TECHNICAL_ARCHITECTURE.md)
  - Project structure for Next.js admin panel
  - Admin API endpoints
  - Vendor approval with flexible commission

- **Support Panel Architecture** (in TECHNICAL_ARCHITECTURE.md)
  - Project structure for support panel
  - Chatwoot integration details
  - Support API endpoints

- **New Database Tables** (in TECHNICAL_ARCHITECTURE.md)
  - `categories` - Admin-managed service categories
  - `admins` - Admin users
  - `support_agents` - Support team users
  - `support_tickets` - Support ticket tracking
  - `support_actions` - Action log for support
  - `commission_transactions` - Commission tracking

- **Updated Vendors Table**
  - Added `commission_rate` (flexible per vendor)
  - Added `contract_notes`
  - Added `approved_by`, `approved_at`
  - Added `status` (pending/approved/rejected/suspended)

### Modified
- Updated MASTER_INSTRUCTIONS.md with comprehensive AI agent guidelines
- Updated version to 1.1

---

## January 30, 2026 (Session 1 - Part 1)

### Added
- **Project Documentation**
  - Created `Wedding_Planner_Application.md` - Complete UI/UX design document
  - Created `docs/TECHNICAL_ARCHITECTURE.md` - Technical specifications
  - Created `PROJECT_MANAGEMENT/MASTER_INSTRUCTIONS.md` - Instructions for AI agents
  - Created `PROJECT_MANAGEMENT/PROJECT_STATUS.md` - Project progress tracking
  - Created `PROJECT_MANAGEMENT/TASK_TRACKER.md` - All tasks by phase
  - Created `PROJECT_MANAGEMENT/SESSION_LOG.md` - Session history
  - Created `PROJECT_MANAGEMENT/CHANGELOG.md` - This file
  - Created `PROJECT_MANAGEMENT/FEATURE_SPECS.md` - Feature specifications

- **Flutter Project Setup** (`wedding_planner/`)
  - Initialized Flutter project structure
  - Created `pubspec.yaml` with all dependencies
  - Created `analysis_options.yaml` with linting rules
  - Created `README.md` for the Flutter project

- **Core Module**
  - `lib/core/constants/app_colors.dart` - Color palette
  - `lib/core/constants/app_typography.dart` - Font styles
  - `lib/core/constants/app_spacing.dart` - Spacing system
  - `lib/core/constants/app_shadows.dart` - Shadow/elevation system
  - `lib/core/theme/app_theme.dart` - Material theme configuration
  - `lib/core/errors/failures.dart` - Failure classes for error handling
  - `lib/core/errors/exceptions.dart` - Exception classes

- **Configuration**
  - `lib/config/routes.dart` - Navigation routes using go_router
  - `lib/config/injection.dart` - Dependency injection setup

- **Shared Widgets**
  - `lib/shared/widgets/buttons/primary_button.dart`
  - `lib/shared/widgets/buttons/secondary_button.dart`
  - `lib/shared/widgets/cards/stat_card.dart`
  - `lib/shared/widgets/cards/vendor_card.dart`
  - `lib/shared/widgets/inputs/app_text_field.dart`
  - `lib/shared/widgets/feedback/empty_state.dart`
  - `lib/shared/widgets/feedback/error_state.dart`
  - `lib/shared/widgets/layout/main_scaffold.dart`

- **Localization**
  - `lib/l10n/app_en.arb` - English translations
  - `lib/l10n/app_ar.arb` - Arabic translations (RTL)
  - `lib/l10n/app_fr.arb` - French translations
  - `lib/l10n/app_es.arb` - Spanish translations
  - `lib/l10n/generated/app_localizations.dart` - Localization delegate

- **Feature Structure (Example)**
  - `lib/features/auth/domain/entities/user.dart` - User entity
  - `lib/features/auth/domain/repositories/auth_repository.dart` - Auth repository interface

- **Assets Structure**
  - Created placeholder directories for images, icons, animations, fonts

### Modified
- **Wedding_Planner_Application.md**
  - Updated guest count to be region-adaptive
  - Added Phase 2.5 (2D venue layout designer)
  - Added chat message retention requirements (2 years)
  - Added read receipts and typing indicator requirements

- **app.dart**
  - Added French (fr) and Spanish (es) to supported locales

- **app_localizations.dart**
  - Added French and Spanish to supported languages

### Decisions Documented
- Mobile framework: Flutter
- State management: BLoC pattern
- Navigation: go_router
- Admin Panel: Web-based (React/Next.js)
- Support Chat: Chatwoot integration
- Commission model: Flexible per-vendor percentage
- Supported languages: English, Arabic, French, Spanish

---

## Template for Future Entries

```
## [Date]

### Added
- Feature/file added

### Modified
- Feature/file modified

### Removed
- Feature/file removed

### Fixed
- Bug fixed

### Decisions
- Important decision made
```
