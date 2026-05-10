# GeoLinked API - User Guide

## Overview
This guide matches the current API implementation.

Core flow:
1. Signup once
2. Login to get JWT token
3. Send token to protected APIs
4. Logout (optionally clear device token to stop push notifications)

Base URL examples use `http://localhost:5000`.

---

## Authentication

### POST /api/auth/signup
Create a user account (one-time user creation).

Request body:
```json
{
  "name": "Ali",
  "email": "ali@example.com",
  "password": "StrongPass123",
  "firebaseDeviceToken": "optional_fcm_token"
}
```

Response 200:
```json
{
  "success": true,
  "message": "Signup successful.",
  "detailedMessage": null,
  "data": {
    "userId": "8b0f3e89-8d59-4f0a-a393-37ae402ea7d8",
    "name": "Ali",
    "email": "ali@example.com",
    "message": "Signup successful.",
    "token": "jwt_token_here"
  },
  "errors": null
}
```

Possible errors:
- 400: Missing fields / weak password / validation issues
- 400: Email already registered

### POST /api/auth/login
Login every time user opens app/session and needs a fresh token.

Request body:
```json
{
  "email": "ali@example.com",
  "password": "StrongPass123",
  "firebaseDeviceToken": "optional_fcm_token"
}
```

Response 200:
```json
{
  "success": true,
  "message": "Login successful.",
  "detailedMessage": null,
  "data": {
    "userId": "8b0f3e89-8d59-4f0a-a393-37ae402ea7d8",
    "name": "Ali",
    "email": "ali@example.com",
    "message": "Login successful.",
    "token": "jwt_token_here"
  },
  "errors": null
}
```

Possible errors:
- 401: Invalid email or password

### POST /api/auth/logout
Logout current user.

Headers:
```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

Request body:
```json
{
  "clearDeviceToken": true
}
```

Response:
- 204 No Content

Notes:
- If `clearDeviceToken = true`, server clears user Firebase token.
- Clearing token helps prevent push notifications after logout.

---

## Authorization Header (Required for protected APIs)

All protected endpoints must include:
```http
Authorization: Bearer <jwt_token>
```

Protected modules:
- `/api/users/*`
- `/api/askquery/*`
- `/api/askchat/*`
- `/api/broadcast/*`
- `/api/broadcastchat/*`

Public endpoints:
- `GET /health/db`
- `POST /api/auth/signup`
- `POST /api/auth/login`

---

## Health Check

### GET /health/db
Purpose: Verify database connectivity.

Response 200:
```json
{
  "status": "ok",
  "database": "mysql"
}
```

---

## Users (Protected)

### GET /api/users/{id}
Get current user profile by id.

Response 200:
```json
{
  "success": true,
  "message": "User fetched successfully.",
  "detailedMessage": null,
  "data": {
    "id": "8b0f3e89-8d59-4f0a-a393-37ae402ea7d8",
    "name": "Ali",
    "email": "ali@example.com",
    "firebaseDeviceToken": "optional_fcm_token",
    "lastKnownLatitude": 33.6844,
    "lastKnownLongitude": 73.0479,
    "createdAtUtc": "2026-04-15T14:30:00Z"
  },
  "errors": null
}
```

Possible errors:
- 401: Unauthorized (missing or invalid token)
- 403: Forbidden (token user does not match requested user id)
- 404: Not Found (user does not exist)

### PUT /api/users/{id}/device-token
Set or clear Firebase device token.

Request body:
```json
{
  "firebaseDeviceToken": "fcm_device_token_here"
}
```

Response:
- 204 No Content

Possible errors:
- 403: Token user mismatch
- 404: User not found

### PUT /api/users/{id}/location
Update user last known location.

Request body:
```json
{
  "latitude": 33.6844,
  "longitude": 73.0479
}
```

Response:
- 204 No Content

Possible errors:
- 403: Token user mismatch
- 404: User not found

---

## Ask Query (Protected)

### POST /api/askquery
Create ask query and linked query chat.

Request body:
```json
{
  "creatorUserId": "8b0f3e89-8d59-4f0a-a393-37ae402ea7d8",
  "queryText": "Anyone knows why road is blocked?",
  "latitude": 33.6844,
  "longitude": 73.0479,
  "targetGeoPoints": [
    { "latitude": 33.6844, "longitude": 73.0479 }
  ],
  "notifyUserIds": [
    "d84f7c15-31cd-45cc-8fd8-19498aa7cbf5"
  ]
}
```

Response 200:
```json
{
  "askQueryId": "ef801390-8625-4dc2-94d9-4a147ac8d96e",
  "queryChatId": "6dd5d5a7-7ef3-4f5d-8be8-bdd1fa3983e6",
  "creatorUserId": "8b0f3e89-8d59-4f0a-a393-37ae402ea7d8",
  "queryText": "Anyone knows why road is blocked?",
  "latitude": 33.6844,
  "longitude": 73.0479,
  "createdAtUtc": "2026-04-15T14:35:00Z"
}
```

Possible errors:
- 400: Invalid request data
- 403: Token user does not match `creatorUserId`

### GET /api/askquery?latitude={lat}&longitude={lng}&radiusMeters={r}
List ask queries in radius.

Response 200:
- Array of AskQueryResponse

---

## Ask Chat (Protected)

### POST /api/askchat/{queryChatId}/messages
Send message in query chat.

Request body:
```json
{
  "senderUserId": "8b0f3e89-8d59-4f0a-a393-37ae402ea7d8",
  "receiverUserId": "d84f7c15-31cd-45cc-8fd8-19498aa7cbf5",
  "text": "Traffic police is there.",
  "latitude": 33.6849,
  "longitude": 73.0482
}
```

Response 200:
- ChatMessageResponse object

Possible errors:
- 403: Token user does not match `senderUserId`
- 404: Query chat not found

### GET /api/askchat/{queryChatId}/messages
List messages for query chat.

Response 200:
- Array of ChatMessageResponse

---

## Broadcast (Protected)

### GET /api/broadcast/categories
List active broadcast categories.

Response 200:
- Array of BroadcastCategoryResponse

### POST /api/broadcast
Create broadcast and linked broadcast chat.

Request body:
```json
{
  "creatorUserId": "8b0f3e89-8d59-4f0a-a393-37ae402ea7d8",
  "categoryId": "b9f8ea7b-9391-43cc-a614-0af06a5b1b01",
  "title": "Heavy Traffic",
  "content": "Avoid main avenue for next 30 minutes",
  "latitude": 33.6844,
  "longitude": 73.0479,
  "targetRadiusMeters": 3000,
  "validUntilUtc": "2026-04-15T16:00:00Z",
  "targetGeoPoints": [
    { "latitude": 33.6844, "longitude": 73.0479 }
  ],
  "notifyUserIds": [
    "d84f7c15-31cd-45cc-8fd8-19498aa7cbf5"
  ]
}
```

Response 200:
- BroadcastResponse object

Possible errors:
- 400: Validation/category/user issues
- 403: Token user does not match `creatorUserId`

### GET /api/broadcast?latitude={lat}&longitude={lng}&radiusMeters={r}
List valid broadcasts in radius.

Response 200:
- Array of BroadcastResponse

---

## Broadcast Chat (Protected)

### POST /api/broadcastchat/{broadcastChatId}/messages
Send message in broadcast chat.

Request body:
```json
{
  "senderUserId": "8b0f3e89-8d59-4f0a-a393-37ae402ea7d8",
  "receiverUserId": "d84f7c15-31cd-45cc-8fd8-19498aa7cbf5",
  "text": "Thanks, I changed route.",
  "latitude": 33.6850,
  "longitude": 73.0480
}
```

Response 200:
- ChatMessageResponse object

Possible errors:
- 403: Token user does not match `senderUserId`
- 404: Broadcast chat not found

### GET /api/broadcastchat/{broadcastChatId}/messages
List messages for broadcast chat.

Response 200:
- Array of ChatMessageResponse

---

Every API response follows a unified structure:
- `success` (bool): Indicates if the request was successful.
- `message` (string): A user-friendly message describing the result.
- `detailedMessage` (string?): Technical details or stack trace (only visible in Development mode).
- `data` (T?): The actual payload of the response.
- `errors` (List<string>?): A list of specific error messages and the `TraceId`.

| Status | Meaning | Format |
|--------|---------|--------|
| 200 | Successful request | Standard Response |
| 400 | Validation/request error | Standard Response (success: false) |
| 401 | Invalid or missing token | Standard Response (success: false) |
| 403 | Action forbidden for this user | Standard Response (success: false) |
| 404 | Resource not found | Standard Response (success: false) |
| 422 | Validation failed | Standard Response (success: false) |
| 500 | Server/internal error | Standard Response (success: false) |

---

## Quick Example Flow

1. Signup
```bash
curl -X POST http://localhost:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Ali","email":"ali@example.com","password":"StrongPass123"}'
```

2. Login and copy token
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"ali@example.com","password":"StrongPass123"}'
```

3. Call protected API
```bash
curl -X GET http://localhost:5000/api/broadcast/categories \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

4. Logout and clear device token
```bash
curl -X POST http://localhost:5000/api/auth/logout \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"clearDeviceToken": true}'
```
