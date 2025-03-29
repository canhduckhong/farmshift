# FarmShift Backend API

This is the Phoenix-based backend API for the FarmShift application, providing authentication services and data endpoints for the frontend and mobile applications.

## Features

- JWT-based authentication
- User registration and login
- Role-based access control (admin/employee)
- RESTful API design
- CORS support for cross-domain requests

## Technology Stack

- **Elixir**: 1.17+
- **Phoenix**: 1.7+
- **PostgreSQL**: Database
- **Guardian**: JWT authentication
- **Bcrypt**: Password hashing

## Setup and Installation

### Prerequisites

- Elixir 1.17 or later
- Erlang/OTP 27 or later
- PostgreSQL

### Installation Steps

1. Clone the repository

```bash
git clone <repository-url>
cd farmshift/backend
```

2. Install dependencies

```bash
mix deps.get
```

3. Setup the database

```bash
mix ecto.setup  # Creates, migrates, and seeds the database
```

4. Start the Phoenix server

```bash
mix phx.server
```

The API will be available at [`localhost:4000/api`](http://localhost:4000/api)

## API Endpoints

### Authentication

#### User Registration

```
POST /api/register
```

Request body:
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "name": "User Name",
    "role": "employee"  // Optional, defaults to "employee"
  }
}
```

Response:
```json
{
  "status": "success",
  "data": {
    "user": {
      "id": "1",
      "email": "user@example.com",
      "name": "User Name",
      "role": "employee",
      "inserted_at": "2025-03-29T22:00:00Z"
    },
    "token": "eyJhb..."
  }
}
```

#### User Login

```
POST /api/login
```

Request body:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

Response:
```json
{
  "status": "success",
  "data": {
    "user": {
      "id": "1",
      "email": "user@example.com",
      "name": "User Name",
      "role": "employee",
      "inserted_at": "2025-03-29T22:00:00Z"
    },
    "token": "eyJhb..."
  }
}
```

#### Get Current User

```
GET /api/current_user
```

Headers:
```
Authorization: Bearer eyJhb...
```

Response:
```json
{
  "status": "success",
  "data": {
    "user": {
      "id": "1",
      "email": "user@example.com",
      "name": "User Name",
      "role": "employee",
      "inserted_at": "2025-03-29T22:00:00Z"
    }
  }
}
```

#### Logout

```
POST /api/logout
```

Headers:
```
Authorization: Bearer eyJhb...
```

Response:
```json
{
  "status": "success",
  "message": "Successfully logged out"
}
```

## Test Users

After running the database seeds, the following test users will be available:

| Email | Password | Role |
|-------|----------|------|
| admin@farmshift.com | password123 | admin |
| john@farmshift.com | password123 | employee |
| jane@farmshift.com | password123 | employee |
| lars@farmshift.com | password123 | employee |

## Development

### Running Tests

```bash
mix test
```

### Generating Documentation

```bash
mix docs
```

## Learn more

- Official Phoenix website: https://www.phoenixframework.org/
- Phoenix Guides: https://hexdocs.pm/phoenix/overview.html
- Phoenix Docs: https://hexdocs.pm/phoenix
- Guardian (Authentication): https://hexdocs.pm/guardian/readme.html
