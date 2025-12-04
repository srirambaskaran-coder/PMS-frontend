# PMS Frontend

Performance Management System - Frontend Application

## Overview

This is the frontend application for the Performance Management System (PMS). It's built with:

- **React 18** - UI library
- **TypeScript** - Type safety
- **Vite** - Build tool and dev server
- **Tailwind CSS** - Styling
- **Radix UI** - Accessible UI components
- **React Query** - Data fetching and caching
- **React Hook Form** - Form management
- **Zod** - Schema validation
- **Wouter** - Routing

## Project Structure

```
├── client/
│   ├── src/
│   │   ├── components/     # Reusable UI components
│   │   │   ├── ui/         # Base UI components (buttons, inputs, etc.)
│   │   │   └── dashboard/  # Dashboard-specific components
│   │   ├── pages/          # Page components
│   │   ├── hooks/          # Custom React hooks
│   │   ├── lib/            # Utility functions
│   │   ├── App.tsx         # Main app component
│   │   └── main.tsx        # Entry point
│   └── index.html          # HTML template
├── shared/
│   └── schema.ts           # Shared types and validation schemas
├── attached_assets/        # Static assets
├── package.json
├── vite.config.ts
├── tsconfig.json
├── tailwind.config.ts
└── postcss.config.js
```

## Getting Started

### Prerequisites

- Node.js 18+ 
- npm or yarn

### Installation

1. Clone the repository and checkout the frontend branch:
   ```bash
   git checkout PMS-frontend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file from the example:
   ```bash
   cp .env.example .env
   ```

4. Update the `VITE_API_URL` in `.env` to point to your backend server:
   ```
   VITE_API_URL=http://localhost:3000
   ```

### Development

Start the development server:

```bash
npm run dev
```

The app will be available at `http://localhost:5173`

### Build

Build for production:

```bash
npm run build
```

The build output will be in the `dist` folder.

### Preview Production Build

```bash
npm run preview
```

## API Integration

The frontend communicates with the backend via REST API. All API calls are proxied through Vite's dev server to avoid CORS issues during development.

API endpoints are configured to proxy to `VITE_API_URL` (default: `http://localhost:3000`).

### API Endpoints Used

The frontend expects the following API endpoints:

- `POST /api/login` - User authentication
- `GET /api/user` - Get current user
- `GET/POST/PUT/DELETE /api/users` - User management
- `GET/POST/PUT/DELETE /api/companies` - Company management
- `GET/POST/PUT/DELETE /api/locations` - Location management
- `GET/POST/PUT/DELETE /api/departments` - Department management
- `GET/POST/PUT/DELETE /api/levels` - Level management
- `GET/POST/PUT/DELETE /api/grades` - Grade management
- `GET/POST/PUT/DELETE /api/appraisal-cycles` - Appraisal cycle management
- `GET/POST/PUT/DELETE /api/review-frequencies` - Review frequency management
- `GET/POST/PUT/DELETE /api/frequency-calendars` - Frequency calendar management
- `GET/POST/PUT/DELETE /api/questionnaire-templates` - Questionnaire templates
- `GET/POST/PUT/DELETE /api/evaluations` - Evaluations
- And more...

## Type Definitions

All shared types and Zod validation schemas are in `shared/schema.ts`. These types should match the backend's data models.

## Contributing

1. Create a feature branch from `PMS-frontend`
2. Make your changes
3. Test locally
4. Create a pull request

## Notes for Backend Integration

When the backend is ready, ensure:

1. All API endpoints return JSON data matching the types in `shared/schema.ts`
2. Authentication uses session-based cookies or JWT tokens
3. CORS is configured to allow requests from the frontend origin
4. Error responses follow a consistent format
