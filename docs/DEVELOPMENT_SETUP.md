# Development Setup Guide

> How to set up and run the Wedding Planner App locally for development and testing.

---

## Overview

You will set up:

```
┌─────────────────────────────────────────────────────────────┐
│                    YOUR COMPUTER                            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              DOCKER (Backend Services)               │   │
│  │                                                      │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐            │   │
│  │  │PostgreSQL│ │  Redis   │ │  API     │            │   │
│  │  │ Database │ │  Cache   │ │  Server  │            │   │
│  │  │ :5432    │ │  :6379   │ │  :3000   │            │   │
│  │  └──────────┘ └──────────┘ └──────────┘            │   │
│  │                                                      │   │
│  │  ┌──────────┐ ┌──────────┐                         │   │
│  │  │ Adminer  │ │ Chatwoot │                         │   │
│  │  │ DB Admin │ │ (Chat)   │                         │   │
│  │  │ :8080    │ │ :3001    │                         │   │
│  │  └──────────┘ └──────────┘                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              FLUTTER (Mobile App)                    │   │
│  │                                                      │   │
│  │  Run on: Emulator / Physical Phone / Web Browser    │   │
│  │                                                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

### Install These First:

| Software | Version | Download Link |
|----------|---------|---------------|
| Docker Desktop | Latest | https://www.docker.com/products/docker-desktop |
| Flutter SDK | 3.16+ | https://docs.flutter.dev/get-started/install |
| Android Studio | Latest | https://developer.android.com/studio |
| VS Code | Latest | https://code.visualstudio.com |
| Git | Latest | https://git-scm.com |
| Node.js | 20+ | https://nodejs.org |

### VS Code Extensions (Recommended):
- Flutter
- Dart
- Docker
- PostgreSQL

---

## Step 1: Start Docker Services

### 1.1 Create Docker Compose File

Create this file in your project root:

**File:** `docker-compose.yml`

```yaml
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: wedding_planner_db
    restart: unless-stopped
    environment:
      POSTGRES_USER: wedding_admin
      POSTGRES_PASSWORD: wedding_secret_123
      POSTGRES_DB: wedding_planner
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - wedding_network

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: wedding_planner_redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - wedding_network

  # Adminer - Database Management UI
  adminer:
    image: adminer
    container_name: wedding_planner_adminer
    restart: unless-stopped
    ports:
      - "8080:8080"
    networks:
      - wedding_network
    depends_on:
      - postgres

  # Backend API (will be built later)
  # api:
  #   build: ./backend
  #   container_name: wedding_planner_api
  #   restart: unless-stopped
  #   ports:
  #     - "3000:3000"
  #   environment:
  #     DATABASE_URL: postgresql://wedding_admin:wedding_secret_123@postgres:5432/wedding_planner
  #     REDIS_URL: redis://redis:6379
  #     JWT_SECRET: your_jwt_secret_here
  #     NODE_ENV: development
  #   depends_on:
  #     - postgres
  #     - redis
  #   networks:
  #     - wedding_network

volumes:
  postgres_data:
  redis_data:

networks:
  wedding_network:
    driver: bridge
```

### 1.2 Create Database Init Script

Create folder and file:

**File:** `database/init.sql`

```sql
-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password_hash VARCHAR(255),
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('couple', 'vendor', 'guest')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Categories table (Admin managed)
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100),
    name_fr VARCHAR(100),
    name_es VARCHAR(100),
    icon VARCHAR(50),
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default categories
INSERT INTO categories (name, name_ar, name_fr, name_es, icon, display_order) VALUES
('Photography', 'التصوير', 'Photographie', 'Fotografía', 'camera', 1),
('Catering', 'الضيافة', 'Traiteur', 'Catering', 'restaurant', 2),
('Cake', 'الكيك', 'Gâteau', 'Pastel', 'cake', 3),
('Music & DJ', 'الموسيقى', 'Musique', 'Música', 'music_note', 4),
('Flowers', 'الزهور', 'Fleurs', 'Flores', 'local_florist', 5),
('Decor', 'الديكور', 'Décoration', 'Decoración', 'celebration', 6),
('Venue', 'القاعة', 'Lieu', 'Lugar', 'location_on', 7),
('Wedding Planner', 'منظم الزفاف', 'Planificateur', 'Planificador', 'event', 8);

-- Admins table
CREATE TABLE admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'admin',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vendors table
CREATE TABLE vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    business_name VARCHAR(200) NOT NULL,
    category_id UUID REFERENCES categories(id),
    description TEXT,
    location_city VARCHAR(100),
    location_country VARCHAR(100),
    price_range VARCHAR(10),
    rating_avg DECIMAL(2, 1) DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending',
    commission_rate DECIMAL(4, 2) DEFAULT 10.00,
    contract_notes TEXT,
    is_verified BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Weddings table
CREATE TABLE weddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    partner1_name VARCHAR(100),
    partner2_name VARCHAR(100),
    wedding_date DATE,
    budget_total DECIMAL(12, 2),
    budget_spent DECIMAL(12, 2) DEFAULT 0,
    guest_count_expected INTEGER,
    style_preferences TEXT[],
    cultural_traditions TEXT[],
    region VARCHAR(50),
    currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bookings table
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending',
    booking_date DATE NOT NULL,
    total_amount DECIMAL(10, 2),
    commission_rate DECIMAL(4, 2),
    commission_amount DECIMAL(10, 2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Guests table
CREATE TABLE guests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    group_name VARCHAR(50),
    rsvp_status VARCHAR(20) DEFAULT 'pending',
    plus_one_allowed BOOLEAN DEFAULT false,
    plus_one_name VARCHAR(200),
    meal_preference VARCHAR(50),
    dietary_restrictions TEXT,
    table_assignment VARCHAR(50),
    responded_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

PRINT 'Database initialized successfully!';
```

### 1.3 Start Docker

Open terminal in your project folder and run:

```bash
# Start all services
docker-compose up -d

# Check if running
docker-compose ps
```

You should see:
```
NAME                        STATUS
wedding_planner_db          running
wedding_planner_redis       running
wedding_planner_adminer     running
```

### 1.4 Verify Database

1. Open browser: http://localhost:8080
2. Login to Adminer:
   - System: PostgreSQL
   - Server: postgres
   - Username: wedding_admin
   - Password: wedding_secret_123
   - Database: wedding_planner

You should see the tables created.

---

## Step 2: Set Up Flutter App

### 2.1 Navigate to Flutter Project

```bash
cd wedding_planner
```

### 2.2 Install Dependencies

```bash
flutter pub get
```

### 2.3 Generate Code (Freezed, JSON)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2.4 Verify Setup

```bash
flutter doctor
```

Make sure you see checkmarks for:
- Flutter
- Android toolchain (or iOS if on Mac)
- VS Code or Android Studio

---

## Step 3: Run the Mobile App

### Option A: Android Emulator

1. Open Android Studio
2. Go to: Tools → Device Manager
3. Create a new virtual device (Pixel 6 recommended)
4. Start the emulator
5. In terminal:
   ```bash
   flutter run
   ```

### Option B: Physical Android Phone

1. Enable Developer Options on your phone:
   - Settings → About Phone → Tap "Build Number" 7 times
2. Enable USB Debugging:
   - Settings → Developer Options → USB Debugging → ON
3. Connect phone via USB
4. Run:
   ```bash
   flutter devices  # Check if phone is detected
   flutter run      # Run the app
   ```

### Option C: Web Browser (Quick Testing)

```bash
flutter run -d chrome
```

### Option D: iOS (Mac Only)

```bash
flutter run -d ios
```

---

## Step 4: Development Workflow

### Daily Workflow:

```bash
# 1. Start Docker services (if not running)
docker-compose up -d

# 2. Navigate to Flutter project
cd wedding_planner

# 3. Run the app
flutter run

# 4. Make changes - app will hot reload automatically
# Press 'r' for hot reload
# Press 'R' for hot restart
```

### Stopping Services:

```bash
# Stop Docker services
docker-compose down

# Stop and remove data (fresh start)
docker-compose down -v
```

---

## Step 5: Connect Flutter to Backend

### 5.1 Update API Base URL

Edit `lib/config/environment.dart`:

```dart
class Environment {
  // For Android Emulator
  static const String apiBaseUrl = 'http://10.0.2.2:3000/api/v1';

  // For iOS Simulator
  // static const String apiBaseUrl = 'http://localhost:3000/api/v1';

  // For Physical Device (use your computer's IP)
  // static const String apiBaseUrl = 'http://192.168.1.XXX:3000/api/v1';
}
```

### Finding Your Computer's IP:

**Windows:**
```bash
ipconfig
# Look for IPv4 Address
```

**Mac/Linux:**
```bash
ifconfig
# Look for inet under en0 or eth0
```

---

## Useful Docker Commands

| Command | What It Does |
|---------|--------------|
| `docker-compose up -d` | Start all services in background |
| `docker-compose down` | Stop all services |
| `docker-compose logs -f` | View logs (live) |
| `docker-compose logs postgres` | View database logs |
| `docker-compose restart api` | Restart just the API |
| `docker-compose down -v` | Stop and delete all data |
| `docker ps` | List running containers |
| `docker exec -it wedding_planner_db psql -U wedding_admin wedding_planner` | Access database directly |

---

## Useful Flutter Commands

| Command | What It Does |
|---------|--------------|
| `flutter run` | Run app on connected device |
| `flutter run -d chrome` | Run in Chrome browser |
| `flutter devices` | List available devices |
| `flutter clean` | Clear build cache |
| `flutter pub get` | Install dependencies |
| `flutter pub run build_runner build` | Generate code |
| `flutter test` | Run unit tests |
| `flutter build apk` | Build Android APK |

---

## Troubleshooting

### Docker Issues

**Problem:** Docker containers won't start
```bash
# Check what's using the ports
netstat -ano | findstr :5432
netstat -ano | findstr :6379

# Restart Docker Desktop
```

**Problem:** Database connection refused
```bash
# Check if postgres is running
docker-compose logs postgres

# Restart postgres
docker-compose restart postgres
```

### Flutter Issues

**Problem:** `flutter pub get` fails
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

**Problem:** Emulator not detected
```bash
# List all devices
flutter devices

# If empty, open Android Studio and start emulator manually
```

**Problem:** Build errors after code changes
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Network Issues (Phone Can't Reach API)

1. Make sure phone and computer are on same WiFi
2. Check firewall isn't blocking port 3000
3. Use your computer's actual IP (not localhost)

---

## Ports Reference

| Service | Port | URL |
|---------|------|-----|
| PostgreSQL | 5432 | - |
| Redis | 6379 | - |
| API Server | 3000 | http://localhost:3000 |
| Adminer (DB UI) | 8080 | http://localhost:8080 |
| Admin Panel | 3001 | http://localhost:3001 (later) |
| Support Panel | 3002 | http://localhost:3002 (later) |

---

## Next Steps

After setup is complete:

1. [ ] Backend API needs to be built (Phase 1 tasks P1-140 to P1-149)
2. [ ] Firebase project needs to be created for chat/notifications
3. [ ] Start building Flutter screens (Phase 1 mobile tasks)

---

**Last Updated:** January 30, 2026
