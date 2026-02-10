# Wedding Planner - API Integration Guide

## Base Configuration

**Base URL:** `http://[SERVER_IP]:3000/api/v1`

All requests require JWT token in header (except auth endpoints):
```
Authorization: Bearer <access_token>
```

---

## Authentication Endpoints

### Register
```
POST /auth/register
Content-Type: application/json

Request:
{
  "email": "user@example.com",
  "password": "Password123",
  "userType": "couple" | "vendor"
}

Response:
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "userType": "couple",
      "createdAt": "2024-01-01T00:00:00Z"
    },
    "tokens": {
      "accessToken": "jwt_token",
      "refreshToken": "refresh_token",
      "expiresAt": "2024-01-01T01:00:00Z"
    }
  }
}
```

### Login
```
POST /auth/login
Content-Type: application/json

Request:
{
  "email": "user@example.com",
  "password": "Password123"
}

Response: Same as register
```

### Refresh Token
```
POST /auth/refresh
Content-Type: application/json

Request:
{
  "refreshToken": "refresh_token"
}

Response:
{
  "success": true,
  "data": {
    "accessToken": "new_jwt_token",
    "refreshToken": "new_refresh_token",
    "expiresAt": "2024-01-01T01:00:00Z"
  }
}
```

### Logout
```
POST /auth/logout
Authorization: Bearer <token>
```

### Get Current User
```
GET /auth/me
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "userType": "couple",
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

---

## Couple Endpoints

### Wedding
```
GET /wedding
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "id": "uuid",
    "coupleId": "uuid",
    "partnerOneName": "John",
    "partnerTwoName": "Jane",
    "weddingDate": "2025-06-15",
    "venueName": "Grand Hotel",
    "venueAddress": "123 Main St",
    "totalBudget": 50000,
    "guestCountExpected": 150,
    "stylePreferences": ["rustic", "elegant"],
    "traditions": ["western"],
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

```
PUT /wedding
Authorization: Bearer <token>

Request:
{
  "partnerOneName": "John",
  "partnerTwoName": "Jane",
  "weddingDate": "2025-06-15",
  "totalBudget": 50000,
  "guestCountExpected": 150,
  "stylePreferences": ["rustic", "elegant"]
}
```

### Tasks
```
GET /tasks?status=pending&category=venue
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "title": "Book venue",
      "description": "Find and book wedding venue",
      "dueDate": "2024-03-01",
      "status": "pending" | "in_progress" | "completed",
      "priority": "high" | "medium" | "low",
      "category": "venue" | "catering" | "photography" | "attire" | "other",
      "assignedTo": "partner_one" | "partner_two" | "both",
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "totalPages": 3
  }
}
```

```
POST /tasks
PUT /tasks/:id
DELETE /tasks/:id
PATCH /tasks/:id/complete
```

### Guests
```
GET /guests?rsvpStatus=confirmed&group=family
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "firstName": "Alice",
      "lastName": "Smith",
      "email": "alice@example.com",
      "phone": "+1234567890",
      "rsvpStatus": "pending" | "confirmed" | "declined" | "maybe",
      "group": "family" | "friends" | "work" | "other",
      "side": "partner_one" | "partner_two" | "both",
      "plusOne": true,
      "plusOneName": "Bob Smith",
      "dietaryRestrictions": ["vegetarian"],
      "tableNumber": 5,
      "notes": "Allergic to nuts",
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "summary": {
    "total": 150,
    "confirmed": 80,
    "declined": 10,
    "pending": 60
  }
}
```

```
POST /guests
PUT /guests/:id
DELETE /guests/:id
POST /guests/bulk-import (CSV)
POST /guests/:id/send-invitation
```

### Budget
```
GET /budget
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "totalBudget": 50000,
    "totalSpent": 25000,
    "totalPending": 10000,
    "remaining": 15000,
    "categories": [
      {
        "category": "venue",
        "budgeted": 15000,
        "spent": 10000,
        "pending": 5000
      }
    ],
    "expenses": [
      {
        "id": "uuid",
        "category": "venue",
        "vendorName": "Grand Hotel",
        "description": "Venue deposit",
        "amount": 5000,
        "status": "paid" | "pending" | "cancelled",
        "dueDate": "2024-02-01",
        "paidDate": "2024-02-01",
        "receipt": "url_to_receipt",
        "notes": "50% deposit",
        "createdAt": "2024-01-01T00:00:00Z"
      }
    ]
  }
}
```

```
POST /budget/expenses
PUT /budget/expenses/:id
DELETE /budget/expenses/:id
PUT /budget/total (update total budget)
```

### Bookings (Couple's view of vendor bookings)
```
GET /bookings
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "vendorId": "uuid",
      "vendor": {
        "id": "uuid",
        "businessName": "Elite Photography",
        "category": "Photography",
        "thumbnail": "url"
      },
      "packageId": "uuid",
      "package": {
        "id": "uuid",
        "name": "Premium Package",
        "price": 3000
      },
      "eventDate": "2025-06-15",
      "status": "pending" | "confirmed" | "completed" | "cancelled",
      "totalAmount": 3000,
      "depositAmount": 1000,
      "depositPaid": true,
      "notes": "Need extra hour",
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

```
POST /bookings
DELETE /bookings/:id (cancel)
```

---

## Vendor Discovery Endpoints

### Categories
```
GET /vendors/categories
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Photography",
      "icon": "camera_alt",
      "vendorCount": 45
    },
    {
      "id": "uuid",
      "name": "Catering",
      "icon": "restaurant",
      "vendorCount": 32
    }
  ]
}
```

### Vendors List
```
GET /vendors?categoryId=uuid&city=Kuwait&priceRange=premium&minRating=4&search=photo&sortBy=rating_avg&sortOrder=desc&page=1&limit=20
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "businessName": "Elite Photography",
      "description": "Professional wedding photography",
      "locationCity": "Kuwait City",
      "locationCountry": "Kuwait",
      "priceRange": "premium",
      "ratingAvg": 4.8,
      "reviewCount": 125,
      "isVerified": true,
      "isFeatured": true,
      "responseTimeHours": 2,
      "thumbnail": "url",
      "category": {
        "id": "uuid",
        "name": "Photography"
      }
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "totalPages": 3
  }
}
```

### Vendor Detail
```
GET /vendors/:id
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "id": "uuid",
    "businessName": "Elite Photography",
    "description": "Professional wedding photography with 10+ years experience",
    "locationCity": "Kuwait City",
    "locationCountry": "Kuwait",
    "latitude": 29.3759,
    "longitude": 47.9774,
    "priceRange": "premium",
    "ratingAvg": 4.8,
    "reviewCount": 125,
    "isVerified": true,
    "isFeatured": true,
    "responseTimeHours": 2,
    "thumbnail": "url",
    "phone": "+965 1234 5678",
    "email": "contact@elitephoto.com",
    "website": "https://elitephoto.com",
    "category": {
      "id": "uuid",
      "name": "Photography"
    },
    "packages": [
      {
        "id": "uuid",
        "name": "Basic Package",
        "description": "4 hours coverage",
        "price": 500,
        "features": ["4 hours", "100 edited photos", "Online gallery"],
        "durationHours": 4,
        "isPopular": false
      },
      {
        "id": "uuid",
        "name": "Premium Package",
        "description": "Full day coverage",
        "price": 1500,
        "features": ["Full day", "500 edited photos", "Album", "Second shooter"],
        "durationHours": 10,
        "isPopular": true
      }
    ],
    "portfolio": [
      {
        "id": "uuid",
        "type": "image",
        "url": "url",
        "thumbnail": "url",
        "caption": "Beach wedding"
      }
    ]
  }
}
```

### Vendor Reviews
```
GET /vendors/:id/reviews?page=1&limit=10
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "rating": 5,
      "comment": "Amazing service!",
      "authorName": "John D.",
      "authorAvatar": "url",
      "createdAt": "2024-01-01T00:00:00Z",
      "response": {
        "comment": "Thank you!",
        "createdAt": "2024-01-02T00:00:00Z"
      }
    }
  ],
  "pagination": {...}
}
```

### Favorites
```
GET /vendors/favorites
POST /vendors/:id/favorite
DELETE /vendors/:id/favorite
```

---

## Vendor App Endpoints

### Dashboard
```
GET /vendor/dashboard
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "stats": {
      "totalBookings": 45,
      "pendingRequests": 3,
      "completedBookings": 40,
      "totalEarnings": 25000,
      "thisMonthEarnings": 5000,
      "averageRating": 4.8
    },
    "recentBookings": [...],
    "upcomingBookings": [...]
  }
}
```

### Vendor Profile
```
GET /vendor/profile
Authorization: Bearer <token>

Response: Same as vendor detail but for current vendor
```

```
PUT /vendor/profile
Authorization: Bearer <token>

Request:
{
  "businessName": "Elite Photography",
  "description": "...",
  "phone": "+965 1234 5678",
  "email": "contact@elitephoto.com",
  "website": "https://elitephoto.com",
  "locationCity": "Kuwait City",
  "locationCountry": "Kuwait",
  "priceRange": "premium"
}
```

### Vendor Packages
```
GET /vendor/packages
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Premium Package",
      "description": "Full day coverage",
      "price": 1500,
      "features": ["Full day", "500 photos"],
      "durationHours": 10,
      "isPopular": true,
      "bookingCount": 25,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

```
POST /vendor/packages
Authorization: Bearer <token>

Request:
{
  "name": "Premium Package",
  "description": "Full day coverage",
  "price": 1500,
  "features": ["Full day", "500 photos"],
  "durationHours": 10
}
```

```
PUT /vendor/packages/:id
DELETE /vendor/packages/:id
```

### Vendor Bookings
```
GET /vendor/bookings?status=pending&page=1&limit=20
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "coupleId": "uuid",
      "couple": {
        "id": "uuid",
        "partnerOneName": "John",
        "partnerTwoName": "Jane",
        "email": "john.jane@example.com",
        "phone": "+1234567890"
      },
      "packageId": "uuid",
      "package": {
        "id": "uuid",
        "name": "Premium Package",
        "price": 1500
      },
      "eventDate": "2025-06-15",
      "eventTime": "14:00",
      "eventLocation": "Grand Hotel",
      "status": "pending" | "confirmed" | "completed" | "cancelled" | "declined",
      "totalAmount": 1500,
      "depositAmount": 500,
      "depositPaid": false,
      "coupleNotes": "Need extra hour",
      "vendorNotes": "Confirmed availability",
      "declineReason": null,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {...}
}
```

```
POST /vendor/bookings/:id/accept
Request: { "vendorNotes": "Looking forward to it!" }

POST /vendor/bookings/:id/decline
Request: { "reason": "Not available on this date" }

POST /vendor/bookings/:id/complete
```

### Vendor Earnings
```
GET /vendor/earnings?period=month&year=2024&month=1
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "totalEarnings": 25000,
    "periodEarnings": 5000,
    "pendingPayments": 2000,
    "completedPayments": 23000,
    "transactions": [
      {
        "id": "uuid",
        "bookingId": "uuid",
        "amount": 1500,
        "type": "booking_payment",
        "status": "completed",
        "date": "2024-01-15T00:00:00Z"
      }
    ],
    "chartData": [
      { "label": "Jan", "value": 5000 },
      { "label": "Feb", "value": 6000 }
    ]
  }
}
```

### Vendor Availability
```
GET /vendor/availability?from=2024-01-01&to=2024-12-31
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "bookedDates": ["2024-06-15", "2024-07-20"],
    "blockedDates": ["2024-08-01", "2024-08-02"]
  }
}
```

```
POST /vendor/availability/block
Request: { "dates": ["2024-08-01", "2024-08-02"] }

DELETE /vendor/availability/block
Request: { "dates": ["2024-08-01"] }
```

---

## Chat Endpoints (or Firebase)

If using REST API:
```
GET /conversations
GET /conversations/:id/messages
POST /conversations/:id/messages
POST /conversations (create new with vendor)
```

If using Firebase Firestore, the structure is:
```
conversations/
  {conversationId}/
    participants: [userId1, userId2]
    lastMessage: "Hello"
    lastMessageTime: timestamp
    unreadCount: { [userId]: count }

    messages/
      {messageId}/
        senderId: "userId"
        content: "Hello"
        type: "text" | "image" | "file"
        createdAt: timestamp
        readBy: ["userId1"]
```

---

## Common Response Formats

### Success Response
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": [
      { "field": "email", "message": "Email is required" }
    ]
  }
}
```

### Pagination
```json
{
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5,
    "hasMore": true
  }
}
```

---

## Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `UNAUTHORIZED` | 401 | Invalid or expired token |
| `FORBIDDEN` | 403 | No permission for this action |
| `NOT_FOUND` | 404 | Resource not found |
| `VALIDATION_ERROR` | 400 | Invalid input data |
| `CONFLICT` | 409 | Resource already exists |
| `SERVER_ERROR` | 500 | Internal server error |

---

## Flutter Implementation Notes

### Dio Setup
```dart
final dio = Dio(
  BaseOptions(
    baseUrl: 'http://SERVER_IP:3000/api/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ),
);
```

### Auth Interceptor
Add token to all requests automatically and handle 401 responses with token refresh.

### Error Handling
```dart
try {
  final response = await dio.get('/endpoint');
  return Right(Model.fromJson(response.data['data']));
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    return Left(AuthFailure('Session expired'));
  }
  return Left(ServerFailure(e.message ?? 'Server error'));
} catch (e) {
  return Left(ServerFailure(e.toString()));
}
```
