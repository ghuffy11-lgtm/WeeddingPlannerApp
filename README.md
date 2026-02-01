# Wedding Planner App

A comprehensive wedding planning platform that connects couples with vendors, manages guest lists, budgets, tasks, and more.

## Overview

Wedding Planner App is a full-stack application consisting of:

- **Mobile App** (Flutter) - For couples and vendors
- **Backend API** (Node.js/Express/TypeScript) - RESTful API
- **Admin Panel** (Next.js) - For platform management
- **Support Panel** (Next.js) - For customer support team

## Features

### For Couples
- Wedding dashboard with countdown and progress tracking
- Vendor discovery with search, filters, and reviews
- Booking management with real-time chat
- Guest list and RSVP management
- Budget tracking and expense management
- Task checklist with reminders
- Digital invitation designer

### For Vendors
- Business profile and portfolio management
- Package creation and pricing
- Booking requests and calendar management
- Earnings dashboard with commission tracking
- Customer communication via chat

### For Admins
- Vendor approval with flexible commission rates
- Category management
- Platform analytics and reporting
- User management

## Tech Stack

| Component | Technology |
|-----------|------------|
| Mobile App | Flutter 3.x, BLoC, go_router |
| Backend API | Node.js, Express, TypeScript, Prisma |
| Database | PostgreSQL 15 |
| Cache | Redis 7 |
| Auth | JWT (Access + Refresh tokens) |
| Real-time | Firebase (Chat, Notifications) |
| Support Chat | Chatwoot |

## Project Structure

```
wedding-planner-app/
├── wedding_planner/          # Flutter mobile app
│   ├── lib/
│   │   ├── core/             # Design system, theme, constants
│   │   ├── config/           # Routes, dependency injection
│   │   ├── features/         # Feature modules (auth, home, etc.)
│   │   ├── shared/           # Shared widgets
│   │   └── l10n/             # Localization (EN, AR, FR, ES)
│   └── pubspec.yaml
│
├── backend/                  # Node.js API
│   ├── src/
│   │   ├── config/           # Database, Redis, JWT config
│   │   ├── controllers/      # Route handlers
│   │   ├── middleware/       # Auth, validation, error handling
│   │   ├── routes/           # API route definitions
│   │   ├── utils/            # Helpers and utilities
│   │   └── validators/       # Request validation schemas
│   ├── prisma/
│   │   └── schema.prisma     # Database schema
│   └── package.json
│
├── database/
│   └── init.sql              # Database initialization script
│
├── docs/                     # Documentation
│   ├── TECHNICAL_ARCHITECTURE.md
│   └── DEVELOPMENT_SETUP.md
│
├── PROJECT_MANAGEMENT/       # Project tracking
│   ├── MASTER_INSTRUCTIONS.md
│   ├── PROJECT_STATUS.md
│   ├── TASK_TRACKER.md
│   └── CHANGELOG.md
│
└── docker-compose.yml        # Docker services
```

## Getting Started

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (for mobile development)
- [Git](https://git-scm.com/)

### Quick Start with Docker

1. **Clone the repository**
   ```bash
   git clone git@github.com:ghuffy11-lgtm/WeeddingPlannerApp.git
   cd WeeddingPlannerApp
   ```

2. **Start all services**
   ```bash
   docker-compose up --build -d
   ```

3. **Verify services are running**
   ```bash
   docker-compose ps
   ```

### Access Points

| Service | URL |
|---------|-----|
| API | http://localhost:3000 |
| API Health Check | http://localhost:3000/health |
| Adminer (DB UI) | http://localhost:8080 |
| MailHog (Email) | http://localhost:8025 |

### Database Access (Adminer)

- **Server:** postgres
- **Username:** wedding_admin
- **Password:** wedding_secret_123
- **Database:** wedding_planner

## API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register` | Register new user |
| POST | `/api/v1/auth/login` | User login |
| POST | `/api/v1/auth/refresh` | Refresh access token |

### Categories
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/categories` | List all categories |
| GET | `/api/v1/categories/:id/vendors` | Get vendors by category |

### Vendors
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/vendors` | List/search vendors |
| GET | `/api/v1/vendors/:id` | Get vendor details |
| POST | `/api/v1/vendors/register` | Register as vendor |
| GET | `/api/v1/vendors/me/dashboard` | Vendor dashboard |

### Weddings
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/weddings/me` | Get my wedding |
| POST | `/api/v1/weddings` | Create wedding |
| GET | `/api/v1/weddings/:id/guests` | Get guest list |
| GET | `/api/v1/weddings/:id/budget` | Get budget items |
| GET | `/api/v1/weddings/:id/tasks` | Get tasks |

### Bookings
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/bookings` | Create booking |
| PUT | `/api/v1/bookings/:id/accept` | Vendor accepts |
| PUT | `/api/v1/bookings/:id/decline` | Vendor declines |
| PUT | `/api/v1/bookings/:id/complete` | Mark complete |

## Mobile App Development

```bash
# Navigate to Flutter project
cd wedding_planner

# Install dependencies
flutter pub get

# Generate code (Freezed, JSON)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on device/emulator
flutter run
```

## Environment Variables

Create a `.env` file in the `backend/` directory:

```env
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://wedding_admin:wedding_secret_123@localhost:5432/wedding_planner
REDIS_URL=redis://localhost:6379
JWT_SECRET=your_jwt_secret
JWT_REFRESH_SECRET=your_refresh_secret
```

## Supported Languages

- English (en)
- Arabic (ar) - RTL support
- French (fr)
- Spanish (es)

## Docker Commands

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f api

# Restart a service
docker-compose restart api

# Stop all services
docker-compose down

# Stop and remove data
docker-compose down -v
```

## Contributing

1. Read `PROJECT_MANAGEMENT/MASTER_INSTRUCTIONS.md`
2. Check `PROJECT_MANAGEMENT/TASK_TRACKER.md` for available tasks
3. Update `PROJECT_MANAGEMENT/CHANGELOG.md` after changes
4. Follow the existing code style and patterns

## License

This project is proprietary software. All rights reserved.

---

**Built with Claude AI assistance**
