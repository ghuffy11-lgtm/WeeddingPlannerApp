# UI Development Instructions for Third-Party AI Tools

> **Project:** Wedding Planner App
> **Platform:** Flutter (Dart)
> **Target:** Bolt.ai, Google Stitch, or similar AI design tools

---

## Project Overview

A wedding planning mobile app with two user types:
- **Couples** - Plan their wedding, browse vendors, manage guests, budget
- **Vendors** - Offer services, manage bookings, view earnings

---

## Design System (MUST FOLLOW)

### Colors
```dart
// Primary Colors
Rose Gold: #B76E79 (primary brand color)
Blush Rose: #F8E8E8 (light backgrounds)
Champagne: #F7E7CE (accent)
Soft Ivory: #FFFFF0 (backgrounds)

// Neutrals
Deep Charcoal: #2C2C2C (primary text)
Warm Gray: #6B6B6B (secondary text)
Light Gray: #9B9B9B (disabled/hints)
Divider: #E8E8E8
White: #FFFFFF

// Semantic Colors
Success: #4CAF50
Warning: #FFC107
Error: #E53935
Info: #2196F3
```

### Typography
```
Headlines: CormorantGaramond (or Playfair Display as fallback)
  - H1: 32px, Bold
  - H2: 24px, SemiBold
  - H3: 20px, SemiBold

Body: Inter (or system sans-serif)
  - Large: 16px, Regular
  - Medium: 14px, Regular
  - Small: 12px, Regular

Buttons: Inter
  - Large: 16px, SemiBold
  - Medium: 14px, SemiBold
```

### Spacing
```
micro: 4px
small: 8px
base: 16px
medium: 20px
large: 24px
xl: 32px
xxl: 48px
```

### Border Radius
```
Small: 8px (buttons, inputs)
Medium: 12px (cards)
Large: 16px (modals, sheets)
Full: 9999px (pills, avatars)
```

---

## Screens to Build

### 1. Vendor Browsing (Priority: HIGH)

#### 1.1 Category Grid Screen
**Route:** `/vendors`

**Layout:**
- Search bar at top (tap opens search page)
- Grid of category cards (2 columns)
- Each card: Icon + Category name + Vendor count

**Categories to show:**
1. Photography (camera icon)
2. Videography (video icon)
3. Venue (location icon)
4. Catering (restaurant icon)
5. Music & DJ (music icon)
6. Florist (flower icon)
7. Decoration (celebration icon)
8. Wedding Cake (cake icon)
9. Wedding Planner (event icon)
10. Makeup & Hair (face icon)
11. Dress & Attire (checkroom icon)
12. Jewelry (diamond icon)
13. Transportation (car icon)
14. Invitations (mail icon)
15. Other Services (more icon)

**Interactions:**
- Tap category → Navigate to vendor list
- Tap search → Navigate to search page

---

#### 1.2 Vendor List Screen
**Route:** `/vendors/category/:categoryId`

**Layout:**
- Back button + Category name in app bar
- Filter button (top right)
- Sort dropdown (Price, Rating, Distance)
- List of vendor cards

**Vendor Card Design:**
```
┌─────────────────────────────────┐
│ [Image]                         │
│ ★ 4.8 (124 reviews)            │
│ Business Name                   │
│ Category • Location             │
│ Starting from $1,500            │
│ [♡ Favorite]                    │
└─────────────────────────────────┘
```

**Interactions:**
- Tap card → Vendor detail page
- Tap heart → Add to favorites
- Tap filter → Show filter modal

---

#### 1.3 Vendor Detail Screen
**Route:** `/vendors/:id`

**Sections:**
1. **Header**
   - Cover image (full width, 200px height)
   - Profile image (overlapping, 80px circle)
   - Business name
   - Rating + Reviews count
   - Location
   - "Contact" and "Book Now" buttons

2. **Tab Bar**
   - About | Portfolio | Packages | Reviews

3. **About Tab**
   - Description text
   - Services offered (chips)
   - Business hours
   - Contact info

4. **Portfolio Tab**
   - Grid of images (3 columns)
   - Tap to view full screen

5. **Packages Tab**
   - List of package cards:
   ```
   ┌─────────────────────────────────┐
   │ Package Name                    │
   │ Description (2 lines max)       │
   │ • Feature 1                     │
   │ • Feature 2                     │
   │ $2,500                [Select]  │
   └─────────────────────────────────┘
   ```

6. **Reviews Tab**
   - Average rating (large)
   - Rating breakdown (5 bars)
   - List of reviews:
   ```
   ┌─────────────────────────────────┐
   │ [Avatar] User Name    ★★★★★    │
   │ Review text...                  │
   │ Date                            │
   └─────────────────────────────────┘
   ```

---

#### 1.4 Filter Modal
**Trigger:** Filter button on vendor list

**Filters:**
- Price Range (slider: $0 - $50,000)
- Rating (minimum: 1-5 stars)
- Distance (if location enabled)
- Availability (date picker)

**Buttons:** "Reset" and "Apply"

---

### 2. Booking Flow (Priority: HIGH)

#### 2.1 Package Selection Screen
- Show selected vendor info
- List of packages (radio selection)
- "Continue" button

#### 2.2 Date Selection Screen
- Calendar view
- Unavailable dates grayed out
- Selected date highlighted in Rose Gold
- "Continue" button

#### 2.3 Booking Details Screen
- Form fields:
  - Event date (read-only, from previous step)
  - Event time
  - Event location
  - Special requests (textarea)
- "Review Booking" button

#### 2.4 Booking Confirmation Screen
- Summary of booking
- Vendor info
- Package details
- Date & time
- Total price
- "Confirm & Pay Deposit" button
- "Cancel" link

---

### 3. Guest Management (Priority: MEDIUM)

#### 3.1 Guest List Screen
- Search bar
- Filter tabs: All | Confirmed | Pending | Declined
- "Add Guest" FAB
- Guest cards:
  ```
  ┌─────────────────────────────────┐
  │ [Avatar] Guest Name             │
  │ email@example.com               │
  │ Table: 5 • Dietary: Vegetarian  │
  │ Status: [Confirmed ✓]           │
  └─────────────────────────────────┘
  ```

#### 3.2 Add/Edit Guest Screen
- Form fields:
  - Name (required)
  - Email
  - Phone
  - Group (dropdown: Family, Friends, Work, etc.)
  - Table assignment
  - Dietary restrictions
  - Plus ones allowed (number)
  - Notes

#### 3.3 Import Guests Modal
- Options:
  - Import from Contacts
  - Import from CSV
  - Add manually

---

### 4. Budget Tracker (Priority: MEDIUM)

#### 4.1 Budget Overview Screen
- Total budget (editable)
- Spent vs Remaining (progress bar)
- Pie chart by category
- List of categories with amounts

#### 4.2 Budget Category Screen
- Category name + allocated amount
- List of expenses:
  ```
  ┌─────────────────────────────────┐
  │ Expense Name                    │
  │ Vendor Name (if linked)         │
  │ $500 / $1,000 estimated         │
  │ [Paid ✓] or [Mark as Paid]      │
  └─────────────────────────────────┘
  ```
- "Add Expense" button

#### 4.3 Add Expense Screen
- Category (dropdown)
- Title
- Estimated cost
- Actual cost
- Vendor (optional, searchable)
- Notes
- Mark as paid (toggle)

---

### 5. Task/Checklist (Priority: MEDIUM)

#### 5.1 Task List Screen
- Progress bar (X of Y completed)
- Filter: All | Today | This Week | Overdue
- Grouped by time period
- Task items:
  ```
  ┌─────────────────────────────────┐
  │ [○] Book photographer           │
  │ Due: Jan 15 • Photography       │
  │ ● High priority                 │
  └─────────────────────────────────┘
  ```
- "Add Task" FAB

#### 5.2 Add/Edit Task Screen
- Title
- Description
- Due date
- Category
- Priority (Low, Medium, High)
- Assigned to (Partner 1, Partner 2, Both)
- Reminders

---

### 6. Profile & Settings (Priority: LOW)

#### 6.1 Profile Screen
- Profile photo
- Names (Partner 1 & Partner 2)
- Wedding date
- Venue
- "Edit Profile" button
- Settings list:
  - Notifications
  - Language
  - Currency
  - Privacy
  - Help & Support
  - About
  - Logout

---

## Component Specifications

### Buttons
```
Primary Button:
- Background: Rose Gold (#B76E79)
- Text: White, 16px SemiBold
- Height: 52px
- Border radius: 8px
- Full width by default

Secondary Button:
- Background: White
- Border: 1.5px Rose Gold
- Text: Rose Gold, 16px SemiBold
- Height: 52px
- Border radius: 8px

Text Button:
- No background
- Text: Rose Gold, 14px SemiBold
```

### Input Fields
```
- Height: 52px
- Border: 1px Blush Rose
- Border radius: 8px
- Focus border: 2px Rose Gold
- Error border: 2px Error Red
- Filled background: White
- Label: Above field, 14px Medium Gray
- Hint: Inside field, 14px Light Gray
```

### Cards
```
- Background: White
- Border: 1px Divider (#E8E8E8)
- Border radius: 12px
- Padding: 16px
- Shadow: None (flat design)
```

### Bottom Navigation
```
5 items:
1. Home (house icon)
2. Tasks (checklist icon)
3. Vendors (store icon)
4. Chat (message icon)
5. Profile (person icon)

Active: Rose Gold icon + label
Inactive: Warm Gray icon only
```

---

## Important Notes for AI Tools

1. **DO NOT** generate backend/API code - we have that
2. **DO NOT** generate state management - we use BLoC
3. **ONLY** generate UI widgets and layouts
4. **USE** the exact colors specified above
5. **FOLLOW** the spacing system
6. **MAKE** all text translatable (no hardcoded strings in final code)
7. **SUPPORT** RTL layouts (Arabic language)
8. **USE** Material 3 design principles

---

## Deliverables Expected

For each screen, provide:
1. Flutter widget code (StatelessWidget preferred)
2. Separate file for each screen
3. Use placeholder data (we'll connect to real data)
4. Comments indicating where dynamic data goes

---

## File Naming Convention

```
lib/features/{feature}/presentation/
├── pages/
│   └── {feature}_page.dart
└── widgets/
    └── {widget_name}.dart

Examples:
- vendor_list_page.dart
- vendor_card.dart
- guest_list_page.dart
- budget_chart.dart
```

---

## Questions?

Contact the project owner before making assumptions about:
- User flows not documented here
- Data structures
- Business logic
- API integration
