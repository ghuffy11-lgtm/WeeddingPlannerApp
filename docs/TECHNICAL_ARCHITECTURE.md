# Wedding Planner App - Technical Architecture

## 1. Technology Stack

### Frontend (Mobile)
| Technology | Purpose |
|------------|---------|
| Flutter 3.x | Cross-platform framework (iOS, Android) |
| Dart | Programming language |
| flutter_bloc | State management (BLoC pattern) |
| go_router | Navigation & deep linking |
| dio | HTTP client for API calls |
| get_it | Dependency injection |
| freezed | Immutable data classes & unions |
| hive | Local storage (offline caching) |
| firebase_messaging | Push notifications |
| cloud_firestore | Real-time chat |
| cached_network_image | Image caching |
| lottie | Micro-animations |
| flutter_localizations | i18n (English, Arabic, French, Spanish) |

### Frontend (Web - Admin & Support Panels)
| Technology | Purpose |
|------------|---------|
| Next.js 14 | React framework with SSR |
| TypeScript | Type-safe code |
| Tailwind CSS | Styling (matching mobile design system) |
| React Query | Server state management |
| Zustand | Client state management |
| React Hook Form | Form handling |
| Chatwoot SDK | Support chat integration |
| Chart.js | Dashboard charts |
| date-fns | Date formatting |

### Backend
| Technology | Purpose |
|------------|---------|
| Node.js + Express | REST API server |
| TypeScript | Type-safe backend code |
| PostgreSQL | Primary relational database |
| Redis | Caching, session management |
| Firebase | Real-time chat, push notifications |
| AWS S3 / Cloudinary | Media storage & optimization |
| Elasticsearch | Vendor search & filtering |

### Third-Party Services
| Service | Purpose |
|---------|---------|
| Stripe | Payment processing |
| Twilio | SMS notifications (invitations, reminders) |
| SendGrid | Email notifications |
| Google Maps API | Venue locations, directions |
| Firebase Auth | Authentication (social login) |

---

## 2. Project Structure (Flutter)

```
wedding_planner/
├── android/                    # Android native code
├── ios/                        # iOS native code
├── lib/
│   ├── main.dart              # App entry point
│   ├── app.dart               # MaterialApp configuration
│   │
│   ├── core/                  # Core utilities & constants
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_typography.dart
│   │   │   ├── app_spacing.dart
│   │   │   └── api_endpoints.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── dark_theme.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── formatters.dart
│   │   │   └── extensions.dart
│   │   ├── errors/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   └── network/
│   │       ├── api_client.dart
│   │       ├── interceptors.dart
│   │       └── network_info.dart
│   │
│   ├── config/                # App configuration
│   │   ├── routes.dart
│   │   ├── injection.dart     # Dependency injection setup
│   │   └── environment.dart
│   │
│   ├── l10n/                  # Localization
│   │   ├── app_en.arb
│   │   └── app_ar.arb
│   │
│   ├── features/              # Feature modules (Clean Architecture)
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       ├── pages/
│   │   │       └── widgets/
│   │   │
│   │   ├── onboarding/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── home/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── vendors/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── tasks/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── budget/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── guests/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── invitations/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── chat/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── profile/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   └── vendor_portal/     # Vendor-specific features
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │
│   └── shared/                # Shared components
│       ├── widgets/
│       │   ├── buttons/
│       │   │   ├── primary_button.dart
│       │   │   ├── secondary_button.dart
│       │   │   └── icon_button.dart
│       │   ├── cards/
│       │   │   ├── vendor_card.dart
│       │   │   ├── task_card.dart
│       │   │   └── stat_card.dart
│       │   ├── inputs/
│       │   │   ├── text_input.dart
│       │   │   ├── search_input.dart
│       │   │   └── date_picker.dart
│       │   ├── dialogs/
│       │   │   ├── bottom_sheet.dart
│       │   │   ├── alert_dialog.dart
│       │   │   └── loading_dialog.dart
│       │   ├── feedback/
│       │   │   ├── toast.dart
│       │   │   ├── empty_state.dart
│       │   │   └── error_state.dart
│       │   └── layout/
│       │       ├── app_bar.dart
│       │       ├── bottom_nav.dart
│       │       └── scaffold.dart
│       └── animations/
│           ├── confetti.dart
│           ├── pulse.dart
│           └── shimmer.dart
│
├── assets/
│   ├── images/
│   ├── icons/
│   ├── fonts/
│   │   ├── CormorantGaramond/
│   │   └── Inter/
│   └── animations/            # Lottie JSON files
│
├── test/                      # Unit & widget tests
│   ├── features/
│   └── shared/
│
├── integration_test/          # Integration tests
│
├── pubspec.yaml              # Dependencies
├── analysis_options.yaml     # Linting rules
└── README.md
```

---

## 3. Database Schema

### Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password_hash VARCHAR(255),
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('couple', 'vendor', 'guest')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);
```

### Weddings Table
```sql
CREATE TABLE weddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    partner1_name VARCHAR(100),
    partner2_name VARCHAR(100),
    wedding_date DATE,
    budget_total DECIMAL(12, 2),
    budget_spent DECIMAL(12, 2) DEFAULT 0,
    guest_count_expected INTEGER,
    style_preferences TEXT[], -- Array: ['romantic', 'modern', etc.]
    cultural_traditions TEXT[],
    region VARCHAR(50), -- For regional defaults (guest count, etc.)
    currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Vendors Table
```sql
CREATE TABLE vendors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    business_name VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL, -- photographer, caterer, florist, etc.
    description TEXT,
    location_city VARCHAR(100),
    location_country VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    price_range VARCHAR(10), -- $, $$, $$$, $$$$
    rating_avg DECIMAL(2, 1) DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    response_time_hours INTEGER, -- Average response time
    weddings_completed INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Vendor Packages Table
```sql
CREATE TABLE vendor_packages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    features JSONB, -- Array of included features
    duration_hours INTEGER,
    is_popular BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Bookings Table
```sql
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
    package_id UUID REFERENCES vendor_packages(id),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'confirmed', 'completed', 'cancelled')),
    booking_date DATE NOT NULL,
    total_amount DECIMAL(10, 2),
    deposit_amount DECIMAL(10, 2),
    deposit_paid BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Tasks Table
```sql
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    due_date DATE,
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP,
    priority VARCHAR(10) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    category VARCHAR(50), -- venue, attire, catering, etc.
    linked_vendor_id UUID REFERENCES vendors(id),
    months_before INTEGER, -- For template tasks
    is_custom BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Guests Table
```sql
CREATE TABLE guests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    group_name VARCHAR(50), -- family, friends, work, etc.
    rsvp_status VARCHAR(20) DEFAULT 'pending' CHECK (rsvp_status IN ('pending', 'accepted', 'declined')),
    plus_one_allowed BOOLEAN DEFAULT false,
    plus_one_name VARCHAR(200),
    meal_preference VARCHAR(50),
    dietary_restrictions TEXT,
    table_assignment VARCHAR(50),
    song_request VARCHAR(200),
    message_to_couple TEXT,
    responded_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Budget Items Table
```sql
CREATE TABLE budget_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL,
    description VARCHAR(200),
    estimated_amount DECIMAL(10, 2),
    actual_amount DECIMAL(10, 2),
    vendor_id UUID REFERENCES vendors(id),
    is_paid BOOLEAN DEFAULT false,
    paid_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Chat Messages Table (Firebase/PostgreSQL hybrid)
```sql
-- Metadata stored in PostgreSQL, actual messages in Firebase
CREATE TABLE chat_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
    firebase_chat_id VARCHAR(100) UNIQUE NOT NULL,
    last_message_at TIMESTAMP,
    unread_count_couple INTEGER DEFAULT 0,
    unread_count_vendor INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Reviews Table
```sql
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    is_verified BOOLEAN DEFAULT false, -- Verified after booking completion
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Invitations Table
```sql
CREATE TABLE invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    template_id VARCHAR(50),
    design_config JSONB, -- Colors, fonts, custom text
    rsvp_deadline DATE,
    sent_count INTEGER DEFAULT 0,
    opened_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 4. API Architecture

### Base URL
```
Production: https://api.weddingplanner.app/v1
Staging: https://staging-api.weddingplanner.app/v1
```

### Authentication
- JWT tokens with refresh token rotation
- Social login: Google, Apple, Facebook
- Phone OTP verification for Middle East markets

### API Endpoints

#### Auth
```
POST   /auth/register
POST   /auth/login
POST   /auth/refresh
POST   /auth/logout
POST   /auth/forgot-password
POST   /auth/verify-otp
POST   /auth/social/google
POST   /auth/social/apple
```

#### Weddings
```
GET    /weddings/me                    # Get current user's wedding
POST   /weddings                       # Create wedding
PUT    /weddings/:id                   # Update wedding details
GET    /weddings/:id/dashboard         # Dashboard data (countdown, stats)
```

#### Vendors
```
GET    /vendors                        # List with filters
GET    /vendors/categories             # All categories
GET    /vendors/:id                    # Vendor profile
GET    /vendors/:id/packages           # Vendor packages
GET    /vendors/:id/reviews            # Vendor reviews
GET    /vendors/:id/availability       # Check date availability
POST   /vendors/:id/favorite           # Add to favorites
DELETE /vendors/:id/favorite           # Remove from favorites
GET    /vendors/favorites              # List favorites
```

#### Bookings
```
POST   /bookings                       # Create booking request
GET    /bookings                       # List user's bookings
GET    /bookings/:id                   # Booking details
PUT    /bookings/:id                   # Update booking
DELETE /bookings/:id                   # Cancel booking
```

#### Tasks
```
GET    /tasks                          # List tasks
POST   /tasks                          # Create custom task
PUT    /tasks/:id                      # Update task
DELETE /tasks/:id                      # Delete task
POST   /tasks/:id/complete             # Mark complete
POST   /tasks/generate                 # Generate default tasks
```

#### Guests
```
GET    /guests                         # List guests
POST   /guests                         # Add guest
POST   /guests/import                  # Bulk import (CSV)
PUT    /guests/:id                     # Update guest
DELETE /guests/:id                     # Remove guest
GET    /guests/rsvp-stats              # RSVP statistics
```

#### Budget
```
GET    /budget                         # Budget overview
GET    /budget/items                   # List budget items
POST   /budget/items                   # Add budget item
PUT    /budget/items/:id               # Update item
DELETE /budget/items/:id               # Delete item
GET    /budget/recommendations         # AI recommendations
```

#### Invitations
```
GET    /invitations/templates          # List templates
POST   /invitations                    # Create invitation
PUT    /invitations/:id                # Update design
POST   /invitations/:id/send           # Send to guests
GET    /invitations/:id/analytics      # Open/RSVP stats
```

#### Chat (Firebase + API)
```
GET    /chat/conversations             # List conversations
POST   /chat/conversations             # Start conversation with vendor
GET    /chat/conversations/:id         # Get conversation metadata
```

#### Vendor Portal
```
GET    /vendor/dashboard               # Vendor dashboard stats
GET    /vendor/bookings                # Incoming booking requests
PUT    /vendor/bookings/:id/accept     # Accept booking
PUT    /vendor/bookings/:id/decline    # Decline booking
GET    /vendor/calendar                # Availability calendar
PUT    /vendor/calendar                # Update availability
GET    /vendor/analytics               # Performance analytics
```

---

## 5. State Management (BLoC)

### Example: VendorBloc

```dart
// Events
abstract class VendorEvent {}

class LoadVendors extends VendorEvent {
  final String? category;
  final VendorFilters? filters;
}

class LoadVendorDetail extends VendorEvent {
  final String vendorId;
}

class ToggleFavorite extends VendorEvent {
  final String vendorId;
}

// States
abstract class VendorState {}

class VendorInitial extends VendorState {}
class VendorLoading extends VendorState {}
class VendorsLoaded extends VendorState {
  final List<Vendor> vendors;
  final bool hasMore;
}
class VendorDetailLoaded extends VendorState {
  final VendorDetail vendor;
}
class VendorError extends VendorState {
  final String message;
}
```

---

## 6. Firebase Chat Structure

```javascript
// Firestore Collections
/chats/{chatId}
  - weddingId: string
  - vendorId: string
  - createdAt: timestamp
  - lastMessageAt: timestamp
  - lastMessage: string

/chats/{chatId}/messages/{messageId}
  - senderId: string
  - senderType: 'couple' | 'vendor'
  - text: string
  - type: 'text' | 'image' | 'file'
  - mediaUrl?: string
  - createdAt: timestamp
  - readAt?: timestamp          // For read receipts
  - deliveredAt?: timestamp     // For delivery status

/chats/{chatId}/typing/{odUserId}
  - isTyping: boolean
  - updatedAt: timestamp
```

### Message Retention Policy
- Messages retained for minimum 2 years
- Media files retained for 1 year after wedding date
- Users can export chat history

---

## 7. Security Considerations

### API Security
- HTTPS only
- JWT with short expiry (15 min) + refresh tokens (7 days)
- Rate limiting per endpoint
- Input validation & sanitization
- SQL injection prevention (parameterized queries)

### Data Privacy
- Guest lists encrypted at rest
- PII handling compliant with GDPR
- User data deletion on request
- Vendor access limited to booking-relevant info

### Payment Security
- PCI DSS compliance via Stripe
- No card data stored on servers
- Secure webhook verification

---

## 8. Performance Targets

| Metric | Target |
|--------|--------|
| App cold start | < 3 seconds |
| API response (p95) | < 500ms |
| Image load (cached) | < 100ms |
| Screen transition | 60fps |
| Offline data access | Instant |

---

## 9. Development Phases

### Phase 1 (MVP)
- Auth (email, social)
- Wedding setup & onboarding
- Home dashboard
- Vendor browsing & profiles
- Basic booking request
- Task checklist
- Guest list management
- Budget tracker
- Basic invitations & RSVP
- Chat with vendors

### Phase 2
- Payment processing
- Smart task generation
- Calendar integration
- Vendor comparison
- Automated reminders
- Collaborative planning

### Phase 2.5
- 2D venue layout designer
- Drag-and-drop tables
- Export layouts

### Phase 3
- AR venue visualization
- Smart seating algorithm
- Video invitations
- Vendor analytics

---

## 10. Environment Setup

### Required Tools
- Flutter SDK 3.16+
- Dart 3.2+
- Android Studio / VS Code
- Xcode (for iOS)
- Node.js 20+
- PostgreSQL 15+
- Redis 7+
- Firebase CLI

### Environment Variables
```env
# API
API_BASE_URL=
API_TIMEOUT=30000

# Firebase
FIREBASE_PROJECT_ID=
FIREBASE_API_KEY=
FIREBASE_MESSAGING_SENDER_ID=

# Stripe
STRIPE_PUBLISHABLE_KEY=

# Google Maps
GOOGLE_MAPS_API_KEY=

# Feature Flags
ENABLE_AR_FEATURES=false
ENABLE_PAYMENTS=false
```

---

## 11. Admin Panel Architecture

### Tech Stack
- Next.js 14 (React)
- TypeScript
- Tailwind CSS
- React Query for data fetching

### Project Structure
```
admin-panel/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── layout.tsx
│   │   ├── page.tsx            # Dashboard
│   │   ├── vendors/
│   │   │   ├── page.tsx        # Vendors list
│   │   │   ├── pending/        # Pending approvals
│   │   │   └── [id]/           # Vendor detail
│   │   ├── bookings/
│   │   ├── users/
│   │   ├── categories/
│   │   ├── reports/
│   │   └── settings/
│   ├── components/
│   │   ├── layout/
│   │   ├── ui/
│   │   └── charts/
│   ├── lib/
│   │   ├── api.ts
│   │   └── utils.ts
│   └── types/
├── public/
├── tailwind.config.js
└── package.json
```

### Admin API Endpoints
```
POST   /admin/auth/login           # Admin login
GET    /admin/dashboard            # Dashboard stats

# Vendor Management
GET    /admin/vendors              # All vendors
GET    /admin/vendors/pending      # Pending approval
GET    /admin/vendors/:id          # Vendor details
POST   /admin/vendors/:id/approve  # Approve with commission
POST   /admin/vendors/:id/reject   # Reject vendor
PUT    /admin/vendors/:id          # Update vendor (commission, status)
DELETE /admin/vendors/:id          # Remove vendor

# Category Management
GET    /admin/categories           # All categories
POST   /admin/categories           # Create category
PUT    /admin/categories/:id       # Update category
DELETE /admin/categories/:id       # Delete category

# Bookings & Users
GET    /admin/bookings             # All bookings
GET    /admin/users                # All users
GET    /admin/users/:id            # User details

# Reports
GET    /admin/reports/revenue      # Revenue report
GET    /admin/reports/bookings     # Booking stats
GET    /admin/reports/vendors      # Vendor performance

# Settings
GET    /admin/settings             # Platform settings
PUT    /admin/settings             # Update settings
```

### Vendor Approval Request Body
```json
{
  "vendor_id": "uuid",
  "commission_rate": 10.0,
  "contract_notes": "Standard 1-year agreement",
  "status": "approved"
}
```

---

## 12. Support Panel Architecture

### Tech Stack
- Next.js 14 (React)
- TypeScript
- Tailwind CSS
- Chatwoot SDK (embedded)

### Project Structure
```
support-panel/
├── src/
│   ├── app/
│   │   ├── layout.tsx
│   │   ├── page.tsx            # Chat inbox
│   │   └── conversation/[id]/  # Active conversation
│   ├── components/
│   │   ├── chat/
│   │   │   ├── ChatWindow.tsx
│   │   │   ├── MessageList.tsx
│   │   │   └── MessageInput.tsx
│   │   ├── sidebar/
│   │   │   ├── UserProfile.tsx
│   │   │   ├── BookingsList.tsx
│   │   │   └── PaymentHistory.tsx
│   │   └── actions/
│   │       ├── RefundButton.tsx
│   │       ├── CancelBookingButton.tsx
│   │       └── EscalateButton.tsx
│   ├── lib/
│   │   ├── chatwoot.ts
│   │   └── api.ts
│   └── types/
└── package.json
```

### Support API Endpoints
```
POST   /support/auth/login         # Support agent login
GET    /support/conversations      # Active conversations

# User Context (for sidebar)
GET    /support/users/:id          # User profile
GET    /support/users/:id/bookings # User's bookings
GET    /support/users/:id/payments # Payment history

# Actions
POST   /support/bookings/:id/refund       # Process refund
POST   /support/bookings/:id/cancel       # Cancel booking
PUT    /support/bookings/:id              # Modify booking
POST   /support/escalate                  # Escalate to admin
POST   /support/notes                     # Add internal note
```

### Chatwoot Integration
```javascript
// Initialize Chatwoot SDK
import { ChatwootWidget } from '@chatwoot/react-native-widget';

// Configuration
const chatwootConfig = {
  websiteToken: 'YOUR_WEBSITE_TOKEN',
  baseUrl: 'https://chat.yourdomain.com',
  locale: 'en',

  // Custom attributes for user context
  customAttributes: {
    userId: 'user_id',
    userType: 'couple', // or 'vendor'
    weddingDate: '2026-06-15',
    bookingsCount: 3
  }
};
```

---

## 13. Updated Database Schema

### Vendors Table (with Commission)
```sql
CREATE TABLE vendors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    business_name VARCHAR(200) NOT NULL,
    category_id UUID REFERENCES categories(id),
    description TEXT,
    location_city VARCHAR(100),
    location_country VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    price_range VARCHAR(10),
    rating_avg DECIMAL(2, 1) DEFAULT 0,
    review_count INTEGER DEFAULT 0,

    -- Approval & Commission
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'suspended')),
    commission_rate DECIMAL(4, 2) DEFAULT 10.00, -- Flexible per vendor
    contract_notes TEXT,
    approved_at TIMESTAMP,
    approved_by UUID REFERENCES admins(id),

    -- Verification
    is_verified BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    documents JSONB, -- {license_url, id_url}

    -- Stats
    response_time_hours INTEGER,
    weddings_completed INTEGER DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Categories Table (Admin Managed)
```sql
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100), -- Arabic
    name_fr VARCHAR(100), -- French
    name_es VARCHAR(100), -- Spanish
    icon VARCHAR(50),
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Admins Table
```sql
CREATE TABLE admins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'admin' CHECK (role IN ('admin', 'super_admin')),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Support Agents Table
```sql
CREATE TABLE support_agents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    chatwoot_agent_id INTEGER, -- Link to Chatwoot
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Support Tickets Table
```sql
CREATE TABLE support_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    agent_id UUID REFERENCES support_agents(id),
    chatwoot_conversation_id INTEGER,
    subject VARCHAR(200),
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'pending', 'resolved', 'escalated')),
    priority VARCHAR(10) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    escalated_to UUID REFERENCES admins(id),
    escalated_at TIMESTAMP,
    resolved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Support Actions Log
```sql
CREATE TABLE support_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID REFERENCES support_tickets(id),
    agent_id UUID REFERENCES support_agents(id),
    action_type VARCHAR(50), -- 'refund', 'cancel_booking', 'modify_booking', 'escalate'
    action_details JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Commission Transactions Table
```sql
CREATE TABLE commission_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID REFERENCES bookings(id),
    vendor_id UUID REFERENCES vendors(id),
    gross_amount DECIMAL(10, 2) NOT NULL,
    commission_rate DECIMAL(4, 2) NOT NULL,
    commission_amount DECIMAL(10, 2) NOT NULL,
    vendor_payout DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'refunded')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 14. Notification System

### Push Notifications (Firebase Cloud Messaging)
```javascript
// Notification Types
const notificationTypes = {
  // For Couples
  BOOKING_ACCEPTED: 'booking_accepted',
  BOOKING_DECLINED: 'booking_declined',
  NEW_MESSAGE: 'new_message',
  RSVP_RECEIVED: 'rsvp_received',
  PAYMENT_SUCCESS: 'payment_success',
  TASK_REMINDER: 'task_reminder',

  // For Vendors
  NEW_BOOKING_REQUEST: 'new_booking_request',
  BOOKING_CONFIRMED: 'booking_confirmed',
  PAYMENT_RECEIVED: 'payment_received',
  NEW_REVIEW: 'new_review',
  NEW_MESSAGE_VENDOR: 'new_message_vendor'
};
```

### Email Templates (SendGrid)
- Welcome email
- Booking confirmation
- Payment receipt
- Password reset
- RSVP notification
- Weekly summary

### SMS Triggers (Twilio)
- OTP verification
- Booking reminder (1 day before)
- Critical alerts
