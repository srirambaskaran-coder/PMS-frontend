# API Configuration Guide

## Overview

The application uses a flexible API configuration system that automatically determines the backend URL based on your deployment environment.

## How It Works

The API URL is determined in the following priority order:

### 1. Manual Override (Highest Priority)

Set `VITE_API_URL` in your `.env` file to explicitly specify the backend URL.

```env
VITE_API_URL=http://192.168.11.187:5000
```

**Use this for:**

- Connecting to a colleague's local backend server
- Testing against a specific backend instance
- Overriding auto-detection

### 2. Auto-Derived from Frontend Domain

If `VITE_API_URL` is not set, the system automatically derives the API URL from your frontend domain:

| Frontend Domain | Auto-Derived API URL    |
| --------------- | ----------------------- |
| `smeqc.com`     | `https://api.smeqc.com` |
| `app.smeqc.com` | `https://api.smeqc.com` |
| `localhost`     | `http://localhost:5000` |

### 3. Stage-Based Fallback

If auto-derivation fails, it falls back to stage-specific URLs based on `VITE_STAGE`:

```env
VITE_STAGE=dev  # Options: local | dev | qc | prod
```

## Common Use Cases

### Connect to Colleague's Local Server

Edit `.env`:

```env
VITE_API_URL=http://192.168.1.100:5000
```

Replace `192.168.1.100` with your colleague's IP address.

### Use Your Own Local Backend

**Option 1: Manual Override**

```env
VITE_API_URL=http://localhost:5000
```

**Option 2: Stage-Based**

```env
VITE_API_URL=
VITE_STAGE=local
```

### Production Deployment

For production on `smeqc.com`:

**Option 1: Auto-Derive (Recommended)**

```env
VITE_API_URL=
VITE_STAGE=prod
```

The system will automatically use `https://api.smeqc.com`

**Option 2: Manual Override**

```env
VITE_API_URL=https://api.smeqc.com
```

### Development on Different Networks

Edit the stage-specific URLs in `.env`:

```env
VITE_API_URL_DEV=http://192.168.11.187:5000
VITE_STAGE=dev
```

## Debugging

The application logs the current API configuration in development mode. Check your browser console for:

```
🔧 API Configuration: {
  baseUrl: "http://192.168.11.187:5000",
  source: "VITE_API_URL (manual override)",
  stage: "dev"
}
```

## Quick Reference

### Environment Variables

| Variable             | Purpose                            | Example                      |
| -------------------- | ---------------------------------- | ---------------------------- |
| `VITE_API_URL`       | Manual override (highest priority) | `http://192.168.1.100:5000`  |
| `VITE_STAGE`         | Stage selector                     | `dev`, `qc`, `prod`, `local` |
| `VITE_API_URL_LOCAL` | Local backend URL                  | `http://localhost:5000`      |
| `VITE_API_URL_DEV`   | Development backend URL            | `http://192.168.11.187:5000` |
| `VITE_API_URL_QC`    | QC/Staging backend URL             | `https://api.smeqc.com`      |
| `VITE_API_URL_PROD`  | Production backend URL             | `https://api.production.com` |

### Domain Mappings

To add custom domain mappings, edit `client/src/lib/apiConfig.ts`:

```typescript
const DOMAIN_TO_API_MAP: DomainMapping = {
  "smeqc.com": "https://api.smeqc.com",
  "myapp.com": "https://api.myapp.com",
  // Add more mappings
};
```

## Tips

1. **Never commit** sensitive backend URLs or IP addresses to version control
2. Copy `.env.example` to `.env` and customize for your local setup
3. Use `VITE_API_URL` for temporary testing/debugging
4. Restart the dev server after changing `.env` files
5. Check browser console for API configuration details
