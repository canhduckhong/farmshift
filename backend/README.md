# FarmShift Backend

A Node.js backend with Express.js and TypeScript for the FarmShift application.

## Features

- TypeScript support
- Express.js server
- PostgreSQL database
- JWT-based authentication
- Input validation using express-validator
- Password hashing with bcrypt
- Environment variable configuration with dotenv

## Prerequisites

- Node.js (v16 or higher)
- PostgreSQL
- pnpm package manager

## Setup

1. Install dependencies:
```bash
pnpm install
```

2. Create a PostgreSQL database named 'farmshift'

3. Configure environment variables:
Copy the `.env.example` file to `.env` and update the values:
```
PORT=5000
JWT_SECRET=your_jwt_secret_key_here
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=farmshift
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
```

## Development

Run the development server:
```bash
pnpm dev
```

## Build

Build the project:
```bash
pnpm build
```

## Production

Run the production server:
```bash
pnpm start
```

## API Endpoints

### Authentication

- `POST /auth/register` - Register a new user
  - Body: `{ "email": "user@example.com", "password": "password123", "name": "John Doe" }`

- `POST /auth/login` - Login and get JWT token
  - Body: `{ "email": "user@example.com", "password": "password123" }`

### User

- `GET /me` - Get logged-in user details (Protected route)
  - Header: `Authorization: Bearer <token>`
