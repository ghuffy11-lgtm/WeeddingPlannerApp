# Feature Specifications

> Detailed specifications for all features in the Wedding Planner App
> **Last Updated:** January 30, 2026

---

## Table of Contents

1. [Authentication](#1-authentication)
2. [Couple Features](#2-couple-features)
3. [Vendor Features](#3-vendor-features)
4. [Admin Panel](#4-admin-panel)
5. [Support Panel](#5-support-panel)
6. [Guest Page](#6-guest-page)
7. [Notifications](#7-notifications)
8. [Chat System](#8-chat-system)

---

## 1. Authentication

### 1.1 Couple/Vendor Registration

**Screen:** Registration Screen

**Fields:**
| Field | Type | Required | Validation |
|-------|------|----------|------------|
| Email | Text | Yes | Valid email format |
| Password | Password | Yes | Min 8 chars, 1 uppercase, 1 number |
| Confirm Password | Password | Yes | Must match password |
| Account Type | Select | Yes | Couple / Vendor |

**Social Login Options:**
- Google
- Apple

**Flow:**
1. User enters email + password
2. User selects account type
3. System creates account
4. If Couple → Go to Onboarding
5. If Vendor → Go to Vendor Registration

### 1.2 Login

**Fields:**
| Field | Type | Required |
|-------|------|----------|
| Email | Text | Yes |
| Password | Password | Yes |

**Features:**
- Remember me checkbox
- Forgot password link
- Social login buttons

### 1.3 Forgot Password

**Flow:**
1. User enters email
2. System sends reset link
3. User clicks link in email
4. User enters new password
5. Password updated

---

## 2. Couple Features

### 2.1 Onboarding Flow

**Step 1: Wedding Date**
- Calendar date picker
- "We haven't set a date yet" option
- Skip allowed

**Step 2: Budget**
- Slider: $5,000 - $100,000+
- Currency selector (KWD, USD, EUR)
- "I'll set this later" option

**Step 3: Guest Count**
- Number input
- Helper text (region-adaptive):
  - Western: "Average wedding: 100-150 guests"
  - Middle East: "Average wedding: 300-500 guests"
  - South Asian: "Average wedding: 200-400 guests"

**Step 4: Style Preferences**
- Multi-select visual cards:
  - Romantic
  - Modern
  - Traditional
  - Bohemian
  - Rustic
  - Glamorous

**Step 5: Cultural Traditions**
- Searchable list:
  - Western
  - Islamic
  - Hindu
  - Jewish
  - Chinese
  - Custom...

**Completion:**
- Celebration screen with confetti
- Options: Create checklist, Explore vendors, Skip

### 2.2 Home Dashboard

**Components:**

1. **Countdown Card**
   - Days until wedding
   - Wedding date
   - Progress percentage

2. **Quick Actions**
   - Tasks button
   - Budget button
   - Guests button

3. **Budget Overview**
   - Spent vs Total
   - Progress bar
   - Top spending categories

4. **Upcoming Tasks**
   - Next 2-3 tasks
   - Due dates
   - Priority indicators

5. **Vendor Status**
   - Booked vendors with status icons
   - Confirmed ✓
   - Pending ⏳
   - Action needed 💬

### 2.3 Vendor Marketplace

**Category Grid:**
- Photography
- Catering
- Cake
- Music/DJ
- Flowers
- Decor
- Venue
- (Admin can add more)

**Vendor List:**
- Sort by: Recommended, Price, Rating, Distance
- Filter by:
  - Date availability
  - Budget range
  - Rating (stars)
  - Distance
  - Style tags

**Vendor Card Shows:**
- Photo
- Name
- Rating + review count
- Location
- Price range ($ to $$$$)
- "Available on your date" badge
- Featured badge (if applicable)

### 2.4 Vendor Profile

**Tabs:**
1. **Portfolio** - Photo gallery
2. **Packages** - Service packages with prices
3. **Reviews** - Customer reviews
4. **About** - Business info

**Actions:**
- Heart/favorite
- Share
- Chat
- Call
- Book Now

### 2.5 Booking Flow

1. Select package
2. View package details
3. Check date availability (calendar)
4. Select date
5. Add message to vendor
6. Submit booking request
7. Confirmation screen

**Booking Statuses:**
- Pending (waiting for vendor)
- Accepted (vendor accepted)
- Declined (vendor declined)
- Confirmed (payment completed)
- Completed (service delivered)
- Cancelled

### 2.6 Guest Management

**Features:**
- Add guests manually
- Import from phone contacts
- Import from CSV file
- Create groups (Family, Friends, Work)
- Edit guest details
- Delete guests

**Guest Fields:**
| Field | Required |
|-------|----------|
| Name | Yes |
| Email | No |
| Phone | No |
| Group | No |
| Plus-one allowed | No |

### 2.7 Budget Tracker

**Features:**
- Set total budget
- Add expenses by category
- Link expenses to vendors
- Visual breakdown (pie chart)
- Over-budget warnings

**Categories:**
- Venue
- Catering
- Photography
- Videography
- Music
- Flowers
- Decor
- Attire
- Invitations
- Other

### 2.8 Invitations

**Template Gallery:**
- Browse templates by style
- Filter by color, format
- Preview before selecting

**Editor:**
- Edit text (names, date, venue)
- Change colors
- Change fonts
- Add photos
- Set RSVP deadline
- Configure RSVP questions

**Sending:**
- Select guests
- Choose delivery method (SMS, Email, WhatsApp)
- Schedule or send immediately
- Track delivery status

**RSVP Dashboard:**
- Accepted count
- Declined count
- Pending count
- Response rate percentage
- Individual responses with details

---

## 3. Vendor Features

### 3.1 Vendor Registration

**Step 1: Business Info**
| Field | Required |
|-------|----------|
| Business Name | Yes |
| Category | Yes |
| Description | Yes |
| Location (City) | Yes |
| Phone | Yes |

**Step 2: Documents**
- Business license (upload)
- ID proof (upload)
- Portfolio photos (min 5)

**Step 3: Packages**
- Add at least 1 package
- Package name
- Description
- Price
- What's included

**Submission:**
- Submit for review
- "Pending approval" status
- Notified when approved/rejected

### 3.2 Vendor Dashboard

**Stats Cards:**
- Total Bookings
- Pending Requests
- This Month's Earnings
- Rating

**Sections:**
1. Pending Requests (accept/decline)
2. Upcoming Jobs
3. Recent Reviews

**Info Displayed:**
- Commission rate (set by admin)
- Earnings after commission

### 3.3 Booking Management

**Pending Requests:**
- Client name
- Wedding date
- Package selected
- Price
- Client message
- [Accept] [Decline] [Message] buttons

**Accepted Bookings:**
- Calendar view
- List view
- Booking details
- Chat with client

### 3.4 Earnings & Payouts

**Dashboard Shows:**
- Gross earnings
- Commission deducted
- Net earnings
- Pending payout

**History:**
- All transactions
- Filter by date
- Export option

### 3.5 Profile Management

**Editable:**
- Business description
- Portfolio photos
- Service packages
- Availability calendar
- Contact info

**Read-only:**
- Commission rate
- Approval status
- Reviews (can respond)

---

## 4. Admin Panel

### 4.1 Dashboard

**Stats Cards:**
- Total Users (Couples + Vendors)
- Total Bookings
- Revenue This Month
- Pending Vendor Approvals

**Charts:**
- Bookings over time
- Revenue over time
- Popular categories

### 4.2 Vendor Management

**Pending Approvals List:**
- Vendor name
- Category
- Submitted date
- [Review] button

**Approval Screen:**
```
Business Name: [name]
Category: [category]
Location: [city]
Documents: [View License] [View ID]
Portfolio: [View Photos]

--- CONTRACT TERMS ---
Commission Rate: [__]%
Contract Notes: [________]

[Reject] [Approve]
```

**All Vendors List:**
- Search & filter
- View profile
- Edit commission rate
- Suspend/unsuspend
- View earnings

### 4.3 Category Management

**Features:**
- View all categories
- Add new category (name, icon)
- Edit category
- Deactivate category
- Reorder categories

### 4.4 Booking Overview

**List Shows:**
- Booking ID
- Couple name
- Vendor name
- Date
- Amount
- Commission earned
- Status

**Filters:**
- Date range
- Status
- Category
- Vendor

### 4.5 User Management

**Couples List:**
- Name
- Email
- Wedding date
- Bookings count
- [View Details]

**Actions:**
- View full profile
- View bookings
- Suspend account

### 4.6 Reports

**Available Reports:**
- Revenue by period
- Revenue by category
- Top vendors
- Booking statistics
- User growth

**Export:** CSV, PDF

### 4.7 Settings

- Platform commission default %
- Supported currencies
- Notification templates
- Terms & conditions
- Privacy policy

---

## 5. Support Panel

### 5.1 Chat Interface

**Left Sidebar:**
- Open conversations
- Resolved conversations
- Search

**Main Area:**
- Chat messages
- User info sidebar

### 5.2 User Info Sidebar

**For Couples:**
```
Name: [name]
Email: [email]
Phone: [phone]
Wedding Date: [date]
Member Since: [date]

BOOKINGS
- [Vendor] - [Status] - [Amount]
- [Vendor] - [Status] - [Amount]

PAYMENT HISTORY
- [Date] - [Amount] - [Status]
- [Date] - [Amount] - [Status]
```

**For Vendors:**
```
Business: [name]
Category: [category]
Commission: [%]
Status: [Active/Suspended]

EARNINGS
This Month: $[amount]
Pending: $[amount]

BOOKINGS
- [x] Completed
- [x] Upcoming
- [x] Disputed
```

### 5.3 Actions Available

| Action | Description |
|--------|-------------|
| Retry Payment | Re-attempt failed payment |
| Issue Refund | Full or partial refund |
| Cancel Booking | Cancel and handle refund |
| Modify Booking | Change date or package |
| Contact Vendor | Start chat with vendor |
| Contact Couple | Start chat with couple |
| Escalate | Send to admin |
| Add Note | Internal note |

### 5.4 Automated Responses

**Chatbot handles:**
- FAQs (How to book, payment issues, etc.)
- Business hours info
- Collect initial issue info
- Route to human when needed

---

## 6. Guest Page

### 6.1 Invitation View

**Shows:**
- Couple names
- Wedding date & time
- Venue name & address
- Dress code
- Custom message

**Actions:**
- RSVP Now button
- View Details
- Get Directions
- Gift Registry (if enabled)

### 6.2 RSVP Form

**Fields:**
| Field | Type |
|-------|------|
| Name | Text (pre-filled if known) |
| Email | Text |
| Attending? | Yes / No |
| Plus-one? | Yes / No (if allowed) |
| Plus-one name | Text |
| Meal preference | Select |
| Dietary restrictions | Text |
| Song request | Text |
| Message to couple | Text |

### 6.3 Confirmation

**Shows:**
- Thank you message
- Summary of response
- Next steps (add to calendar, directions)
- Edit response option

---

## 7. Notifications

### 7.1 Push Notifications

**Couples receive:**
- Booking request accepted/declined
- New message from vendor
- Payment confirmation
- RSVP received
- Task reminders

**Vendors receive:**
- New booking request
- New message from couple
- Booking confirmed
- Payment received
- New review

### 7.2 Email Notifications

- Welcome email
- Booking confirmations
- Payment receipts
- Password reset
- Weekly summary (optional)

### 7.3 SMS Notifications

- OTP for verification
- Booking reminders (day before)
- Critical alerts

---

## 8. Chat System

### 8.1 Couple-Vendor Chat

**Technology:** Firebase Firestore

**Features:**
- Text messages
- Image sharing
- Read receipts (✓✓)
- Typing indicator
- Message timestamps
- Push notifications

**Retention:** 2 years minimum

### 8.2 Support Chat

**Technology:** Chatwoot (embedded)

**Features:**
- Live chat with support
- Automated bot responses
- File attachments
- Chat history
- Satisfaction rating

---

## Appendix: Data Validation Rules

### Email
- Valid email format
- Max 255 characters

### Password
- Min 8 characters
- At least 1 uppercase letter
- At least 1 number

### Phone
- Valid phone format
- Include country code

### Names
- Min 2 characters
- Max 100 characters

### Prices
- Positive numbers only
- Max 2 decimal places

### Commission
- 0% to 50% range
- Default: 10%
