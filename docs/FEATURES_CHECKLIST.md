# Wedding Planner - Features Checklist

## Overview

This document tracks all features, their current status, and implementation requirements.

---

## User Types

| User Type | Description | Home Route |
|-----------|-------------|------------|
| **Couple** | Engaged couples planning their wedding | `/home` |
| **Vendor** | Service providers (photographers, caterers, etc.) | `/vendor` |

---

## Authentication Features

| Feature | Status | Route | Notes |
|---------|--------|-------|-------|
| Splash Screen | ✅ Done | `/` | Auto-redirects based on auth state |
| Welcome Screen | ✅ Done | `/welcome` | Entry point for new users |
| Login | ✅ Done | `/login` | Email/password + social |
| Register | ✅ Done | `/register` | Choose couple/vendor type |
| Forgot Password | 🔲 Placeholder | `/forgot-password` | Needs implementation |
| Couple Onboarding | ✅ Done | `/onboarding` | 6-step wedding setup |
| Vendor Onboarding | ✅ Done | `/vendor/onboarding` | Business profile setup |

---

## Couple App Features

### Navigation (Bottom Bar)
| Tab | Icon | Route | Status |
|-----|------|-------|--------|
| Home | `home` | `/home` | ✅ Done |
| Tasks | `checklist` | `/tasks` | ✅ Done |
| Vendors | `search` | `/vendors` | ✅ Done |
| Chat | `chat_bubble` | `/chat` | ✅ Done |
| Profile | `person` | `/profile` | ✅ Done |

### Home Dashboard (`/home`)
| Component | Status | Description |
|-----------|--------|-------------|
| Hero Section | ✅ Done | Background image with CTA |
| Wedding Countdown | ✅ Done | Days until wedding (if date set) |
| Trending Themes | ✅ Done | Horizontal carousel, clickable |
| Set Wedding Date CTA | ✅ Done | Shows date picker dialog |
| Featured Vendors | ✅ Done | Horizontal carousel, clickable |
| Pull to Refresh | ✅ Done | Refreshes wedding data |

### Task Management (`/tasks`)
| Feature | Status | Description |
|---------|--------|-------------|
| Task List | ✅ Done | Grouped by status |
| Task Detail | ✅ Done | `/tasks/:id` |
| Add Task | ✅ Done | `/tasks/add` |
| Edit Task | ✅ Done | `/tasks/edit/:id` |
| Complete Task | ✅ Done | Toggle completion |
| Delete Task | ✅ Done | With confirmation |
| Filter by Category | 🔲 TODO | Category chips |
| Filter by Status | 🔲 TODO | Tab bar |
| Search Tasks | 🔲 TODO | Search bar |

### Vendor Discovery (`/vendors`)
| Feature | Status | Description |
|---------|--------|-------------|
| Categories Grid | ✅ Done | Browse by category |
| Vendor List | ✅ Done | `/vendors/category/:id` |
| Vendor Search | ✅ Done | `/vendors/search` |
| Vendor Detail | ✅ Done | `/vendors/:id` |
| Vendor Packages | ✅ Done | Shown on detail page |
| Vendor Portfolio | ✅ Done | Photo gallery |
| Vendor Reviews | ✅ Done | With pagination |
| Filter Panel | 🔲 TODO | Price, rating, location |
| Add to Favorites | 🔲 TODO | Heart icon |
| Contact Vendor | ✅ Done | Phone, email, website |
| Book Vendor | ✅ Done | `/vendors/:id/book` |

### Bookings (`/bookings`)
| Feature | Status | Description |
|---------|--------|-------------|
| Bookings List | ✅ Done | All couple bookings |
| Booking Detail | ✅ Done | `/bookings/:id` |
| Create Booking | ✅ Done | From vendor page |
| Cancel Booking | ✅ Done | With confirmation |
| Booking Status | ✅ Done | Pending/Confirmed/etc |

### Guest Management (`/guests`)
| Feature | Status | Description |
|---------|--------|-------------|
| Guest List | ✅ Done | With summary stats |
| Guest Detail | ✅ Done | `/guests/:id` |
| Add Guest | ✅ Done | `/guests/add` |
| Edit Guest | ✅ Done | `/guests/:id/edit` |
| Delete Guest | ✅ Done | With confirmation |
| RSVP Status | ✅ Done | Pending/Confirmed/Declined |
| Filter by RSVP | 🔲 TODO | Tab bar |
| Filter by Group | 🔲 TODO | Family/Friends/etc |
| Bulk Import | 🔲 TODO | CSV upload |
| Send Invitation | 🔲 TODO | Email/SMS |

### Budget Tracking (`/budget`)
| Feature | Status | Description |
|---------|--------|-------------|
| Budget Overview | ✅ Done | Total/Spent/Remaining |
| Category Breakdown | ✅ Done | Chart + list |
| Expense List | ✅ Done | All expenses |
| Expense Detail | ✅ Done | `/budget/expense/:id` |
| Add Expense | ✅ Done | `/budget/add` |
| Edit Expense | ✅ Done | `/budget/expense/:id/edit` |
| Delete Expense | ✅ Done | With confirmation |
| Edit Total Budget | 🔲 TODO | Modal |
| Receipt Upload | 🔲 TODO | Camera/Gallery |

### Chat (`/chat`)
| Feature | Status | Description |
|---------|--------|-------------|
| Conversations List | ✅ Done | All chats |
| Chat Page | ✅ Done | `/chat/:id` |
| Send Message | ✅ Done | Text messages |
| Real-time Updates | ✅ Done | Firebase |
| Unread Count | ✅ Done | Badge on nav |
| Send Image | 🔲 TODO | Photo upload |
| Send File | 🔲 TODO | Document upload |
| Start Chat with Vendor | 🔲 TODO | From vendor page |

### Profile (`/profile`)
| Feature | Status | Description |
|---------|--------|-------------|
| User Info | ✅ Done | Email, account type |
| Wedding Summary | ✅ Done | Date, budget, guests |
| Quick Actions | ✅ Done | Links to features |
| Settings | 🔲 Placeholder | App preferences |
| Help & Support | 🔲 Placeholder | Contact info |
| Logout | ✅ Done | With confirmation |
| Edit Profile | 🔲 TODO | Name, photo |
| Change Password | 🔲 TODO | Form |

### Additional Features (Not Started)
| Feature | Route | Description |
|---------|-------|-------------|
| Invitations | `/invitations` | Digital invitation design |
| Invitation Editor | `/invitations/editor` | Template customization |
| RSVP Dashboard | `/invitations/rsvp` | Track responses |
| Seating Chart | `/seating` | Table arrangement |

---

## Vendor App Features

### Navigation (Bottom Bar)
| Tab | Icon | Route | Status |
|-----|------|-------|--------|
| Dashboard | `dashboard` | `/vendor` | ✅ Done |
| Bookings | `book` | `/vendor/bookings` | ✅ Done |
| Calendar | `calendar_month` | `/vendor/availability` | ✅ Done |
| Profile | `person` | `/vendor/profile` | ✅ Done |

### Dashboard (`/vendor`)
| Component | Status | Description |
|-----------|--------|-------------|
| Stats Cards | ✅ Done | Bookings, earnings, rating |
| Pending Requests | ✅ Done | Quick access |
| Recent Bookings | ✅ Done | Latest activity |
| Earnings Summary | ✅ Done | This month |

### Booking Management
| Feature | Status | Route | Description |
|---------|--------|-------|-------------|
| All Bookings | ✅ Done | `/vendor/bookings` | List with filters |
| Booking Requests | ✅ Done | `/vendor/requests` | Pending requests |
| Booking Detail | ✅ Done | `/vendor/bookings/:id` | Full details |
| Accept Booking | ✅ Done | Action button |
| Decline Booking | ✅ Done | With reason |
| Complete Booking | ✅ Done | Mark as done |
| Filter by Status | 🔲 TODO | Tab bar |
| Filter by Date | 🔲 TODO | Date range |

### Package Management
| Feature | Status | Route | Description |
|---------|--------|-------|-------------|
| Packages List | ✅ Done | `/vendor/packages` | All packages |
| Add Package | ✅ Done | `/vendor/packages/add` | Create new |
| Edit Package | ✅ Done | `/vendor/packages/:id/edit` | Modify existing |
| Delete Package | ✅ Done | With confirmation |
| Mark as Popular | ✅ Done | Toggle |

### Availability Calendar (`/vendor/availability`)
| Feature | Status | Description |
|---------|--------|-------------|
| Calendar View | ✅ Done | Month view |
| Booked Dates | ✅ Done | Highlighted |
| Block Dates | 🔲 TODO | Manual blocking |
| Unblock Dates | 🔲 TODO | Remove blocks |

### Earnings (`/vendor/earnings`)
| Feature | Status | Description |
|---------|--------|-------------|
| Total Earnings | ✅ Done | All time |
| Period Earnings | ✅ Done | Month/Year |
| Chart | ✅ Done | Earnings trend |
| Transactions | ✅ Done | Payment list |
| Filter by Period | 🔲 TODO | Dropdown |
| Export Report | 🔲 TODO | PDF/CSV |

### Vendor Profile (`/vendor/profile`)
| Feature | Status | Description |
|---------|--------|-------------|
| Business Info | ✅ Done | Name, category, location |
| Stats Display | ✅ Done | Rating, reviews, price |
| Edit Profile | ✅ Done | Bottom sheet form |
| Portfolio | 🔲 Placeholder | Photo gallery |
| Reviews | 🔲 Placeholder | Customer reviews |
| Settings | 🔲 Placeholder | Preferences |
| Logout | ✅ Done | With confirmation |

### Missing Vendor Features
| Feature | Description | Priority |
|---------|-------------|----------|
| Category Selection | Select/change business categories | High |
| Portfolio Upload | Add work samples | High |
| Review Responses | Reply to customer reviews | Medium |
| Analytics Dashboard | Detailed business metrics | Low |
| Push Notifications | Booking alerts | Medium |

---

## Shared Features

| Feature | Status | Description |
|---------|--------|-------------|
| Dark Theme | ✅ Done | App-wide |
| Glassmorphism UI | ✅ Done | Consistent design |
| Pull to Refresh | ✅ Done | Most list screens |
| Loading States | ✅ Done | Skeleton/spinner |
| Error States | ✅ Done | Retry button |
| Empty States | ✅ Done | Helpful messages |
| Form Validation | ✅ Done | Real-time feedback |
| Offline Mode | 🔲 TODO | Cached data |
| Push Notifications | 🔲 TODO | FCM integration |
| Localization | 🔲 Partial | en, ar, es, fr |
| Deep Links | 🔲 TODO | App links |

---

## Priority Implementation Order

### Phase 1 - Core Fixes (Current)
1. ✅ Login routing based on user type
2. ✅ Vendor onboarding with category selection
3. ✅ Home page click handlers
4. ✅ Vendor route restrictions

### Phase 2 - Essential Missing Features
1. 🔲 Forgot password flow
2. 🔲 Edit couple profile
3. 🔲 Vendor portfolio management
4. 🔲 Chat image/file upload
5. 🔲 Filters for all list screens

### Phase 3 - Enhanced Features
1. 🔲 Invitations feature
2. 🔲 Seating chart
3. 🔲 Push notifications
4. 🔲 Offline mode
5. 🔲 Analytics dashboard

### Phase 4 - Polish
1. 🔲 Animations and transitions
2. 🔲 Performance optimization
3. 🔲 Accessibility improvements
4. 🔲 Complete localization
5. 🔲 App store preparation

---

## File Locations

### Couple Features
```
lib/features/
├── auth/           # Login, Register, Onboarding
├── home/           # Dashboard
├── tasks/          # Task management
├── vendors/        # Vendor discovery (couple view)
├── booking/        # Booking management (couple view)
├── guests/         # Guest management
├── budget/         # Budget tracking
├── chat/           # Messaging
├── profile/        # Couple profile
└── onboarding/     # Couple onboarding flow
```

### Vendor Features
```
lib/features/
└── vendor_app/     # All vendor features
    ├── data/
    ├── domain/
    └── presentation/
        ├── bloc/
        ├── pages/
        │   ├── vendor_home_page.dart
        │   ├── vendor_onboarding_page.dart
        │   ├── vendor_bookings_page.dart
        │   ├── booking_requests_page.dart
        │   ├── vendor_booking_detail_page.dart
        │   ├── packages_page.dart
        │   ├── add_edit_package_page.dart
        │   ├── availability_page.dart
        │   ├── earnings_page.dart
        │   └── vendor_profile_page.dart
        └── widgets/
```

---

## Entity Definitions

### User
```dart
class User {
  final String id;
  final String email;
  final String? phone;
  final UserType userType;  // couple, vendor, guest
  final DateTime createdAt;
  final bool isActive;
}
```

### Wedding
```dart
class Wedding {
  final String id;
  final String? partnerOneName;
  final String? partnerTwoName;
  final DateTime? weddingDate;
  final String? venueName;
  final double totalBudget;
  final int? guestCountExpected;
  final List<String>? stylePreferences;
  final List<String>? traditions;

  String get coupleDisplayName;
  int? get daysUntilWedding;
  String? get styleDisplay;
}
```

### Vendor
```dart
class Vendor {
  final String id;
  final String businessName;
  final String? description;
  final String? locationCity;
  final String? locationCountry;
  final String? priceRange;
  final double ratingAvg;
  final int reviewCount;
  final bool isVerified;
  final bool isFeatured;
  final String? thumbnail;
  final String? phone;
  final String? email;
  final String? website;
  final Category? category;
  final List<VendorPackage> packages;
  final List<PortfolioItem> portfolio;
}
```

### VendorPackage
```dart
class VendorPackage {
  final String id;
  final String vendorId;
  final String name;
  final String? description;
  final double price;
  final List<String> features;
  final int? durationHours;
  final bool isPopular;
}
```

### Task
```dart
class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskStatus status;     // pending, in_progress, completed
  final TaskPriority priority; // high, medium, low
  final TaskCategory category;
  final String? assignedTo;
}
```

### Guest
```dart
class Guest {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final RsvpStatus rsvpStatus;  // pending, confirmed, declined, maybe
  final GuestGroup group;       // family, friends, work, other
  final String? side;           // partner_one, partner_two, both
  final bool plusOne;
  final String? plusOneName;
  final List<String>? dietaryRestrictions;
  final int? tableNumber;
}
```

### Expense
```dart
class Expense {
  final String id;
  final ExpenseCategory category;
  final String? vendorName;
  final String description;
  final double amount;
  final ExpenseStatus status;  // paid, pending, cancelled
  final DateTime? dueDate;
  final DateTime? paidDate;
}
```

### Booking
```dart
class Booking {
  final String id;
  final String vendorId;
  final Vendor? vendor;
  final String? packageId;
  final VendorPackage? package;
  final DateTime eventDate;
  final BookingStatus status;  // pending, confirmed, completed, cancelled
  final double totalAmount;
  final double? depositAmount;
  final bool depositPaid;
  final String? notes;
}
```

---

## Notes for New Components

When building new features:

1. **Follow the folder structure** - Place files in correct feature folder
2. **Use BLoC pattern** - Create bloc, event, state files
3. **Use repository pattern** - Abstract data sources
4. **Use Either<Failure, T>** - For error handling
5. **Match existing UI** - Use AppColors, AppTypography, AppSpacing
6. **Add glassmorphism** - BackdropFilter, GlassCard, BackgroundGlow
7. **Handle all states** - Loading, error, empty, success
8. **Test on dark theme** - Everything should look good on dark background
9. **Add proper padding** - 100px bottom padding for nav bar overlap
