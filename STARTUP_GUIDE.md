# 🚀 Application Startup Guide

## Step 1: Configure Database Connection

### Option A: Using Connection String (Recommended)

Edit `.env` file and replace the DATABASE_URL:

```
DATABASE_URL=mssql://pms_app_user:Sriramraghavi1617**%40%40@localhost:1433/PMS_DB
```

### Option B: Using Individual Parameters

Comment out DATABASE_URL and set these in `.env`:

```
DB_SERVER=your_server_name_or_ip
DB_PORT=1433
DB_DATABASE=your_database_name
DB_USER=your_username
DB_PASSWORD=your_password
DB_ENCRYPT=true
DB_TRUST_SERVER_CERTIFICATE=true
```

## Step 2: Test Database Connection

Run the connection test:

```bash
node test-db-connection.cjs
```

This will verify:

- ✅ Database connectivity
- ✅ Required tables exist
- ✅ Stored procedures are available

## Step 3: Install Dependencies (if needed)

```bash
npm install
```

## Step 4: Start the Application

### Development Mode:

```bash
npm run dev
```

### Production Mode:

```bash
npm run build
npm start
```

## Step 5: Access the Application

- **Frontend**: http://localhost:5173 (dev) or http://localhost:3000 (prod)
- **Backend API**: http://localhost:3000/api (check server/index.ts for exact port)

## Common Issues & Solutions

### 1. Connection Refused

- Ensure SQL Server is running
- Check firewall settings
- Verify port 1433 is open

### 2. Authentication Failed

- Check username/password
- Ensure SQL Server authentication is enabled
- Verify user has database access

### 3. SSL/TLS Issues

- Set `DB_TRUST_SERVER_CERTIFICATE=true` for local development
- For production, use proper SSL certificates

### 4. Missing Tables/Procedures

- Run your schema creation scripts first
- Execute all stored procedure files

## Next Steps

1. **First-time Setup**: Create admin user through registration
2. **Configure Email**: Set up SMTP settings in database
3. **Upload Company Logo**: Use the company settings
4. **Create Organizational Structure**: Add levels, grades, departments

## Troubleshooting

If you encounter issues:

1. Check the connection test output
2. Verify all environment variables are set
3. Ensure database schema is properly created
4. Check server logs for specific errors

## Default Credentials

After setup, create your first admin user through:

- Registration endpoint: `POST /api/auth/register`
- Or directly through the application UI

---

Your application is now ready to connect to MSSQL! 🎉
