# SQL Server Migration Guide

## Summary

This project is being migrated from PostgreSQL (Drizzle ORM) to SQL Server (MSSQL) with stored procedures.

## Completed Steps

### 1. Database Connection

- ✅ Created `server/mssql.ts` - MSSQL connection pool
- ✅ Updated `server/db.ts` - Re-exports MSSQL pool
- ✅ Added `mssql` package and TypeScript types

### 2. Stored Procedures Created

- ✅ Calendar Credentials (GetCalendarCredential, UpdateCalendarCredentialTokens, SetCalendarCredential)
- ✅ Email Config (GetEmailConfig, CreateEmailConfig, UpdateEmailConfig)
- ✅ Users (GetUser, GetUserByEmail, UpsertUser, CreateUser, UpdateUser)
- ✅ Companies (GetCompanies, GetCompany, GetCompanyByUrl, CreateCompany, UpdateCompany, DeleteCompany)
- ✅ Locations (GetLocations, GetLocation, CreateLocation, UpdateLocation, DeleteLocation)

📄 **All SPs are in:** `migrations/stored_procedures_complete.sql`

### 3. Files Updated

- ✅ `server/calendarService.ts` - Uses SPs for calendar credentials
- ✅ `server/emailService.ts` - Uses SP for email config
- ✅ `server/db.ts` - Exports MSSQL pool

## Remaining Work

### Critical Files Needing Update

#### `server/storage.ts` (2400+ lines)

This is the main storage layer with 100+ methods. Each method needs conversion from Drizzle ORM to SP execution.

**Pattern to follow:**

```typescript
// OLD (Drizzle):
async getUser(id: string): Promise<User | undefined> {
  const [user] = await db.select().from(users).where(eq(users.id, id));
  return user;
}

// NEW (SP):
async getUser(id: string): Promise<User | undefined> {
  const pool = await getPool();
  const result = await pool.request()
    .input('Id', sql.UniqueIdentifier, id)
    .execute('dbo.GetUser');
  return result.recordset?.[0];
}
```

**Methods to convert** (sorted by priority):

**High Priority:**

- Authentication & Users

  - `getUser`, `getUserByEmail`, `getUserByCode`, `getUserByMobile`
  - `createUser`, `updateUser`, `deleteUser`, `upsertUser`
  - `getUsers`, `getUsersByManager`
  - `changePassword`

- Companies & Locations

  - `getCompanies`, `getCompany`, `getCompanyByUrl`
  - `createCompany`, `updateCompany`, `deleteCompany`
  - `getLocations`, `getLocation`, `createLocation`, `updateLocation`, `deleteLocation`

- Email Operations
  - `getEmailConfig`, `createEmailConfig`, `updateEmailConfig`
  - `getEmailTemplates`, `getEmailTemplate`, `createEmailTemplate`, `updateEmailTemplate`, `deleteEmailTemplate`

**Medium Priority:**

- Levels, Grades, Departments (admin-isolated entities)
- Appraisal Cycles, Review Frequencies
- Frequency Calendars & Details
- Questionnaire Templates
- Access Tokens, Calendar Credentials

**Lower Priority:**

- Evaluations & complex queries
- Appraisal Groups & Members
- Initiated Appraisals
- Scheduled Tasks
- Registrations

#### `server/routes.ts` (4300+ lines)

Currently imports `storage` object. After `storage.ts` is converted, this will automatically work.

**Key usage points:**

- Line 3: `import { storage } from "./storage";`
- Multiple calls like: `storage.getUser()`, `storage.createCompany()`, etc.

**Action:** Once `storage.ts` is migrated, this file requires no changes (it just uses the storage interface).

#### `server/replitAuth.ts`

- Uses `storage.getUser()` and `storage.upsertUser()`
- **Action:** Works automatically once `storage.ts` is migrated

#### `server/seedUsers.ts`

- Uses `storage` methods for test data seeding
- **Action:** Works automatically once `storage.ts` is migrated

### Required Stored Procedures (Not Yet Created)

You need to create SPs for:

1. **Levels** (5 SPs)

   - GetLevels, GetLevel, CreateLevel, UpdateLevel, DeleteLevel

2. **Grades** (5 SPs)

   - GetGrades, GetGrade, CreateGrade, UpdateGrade, DeleteGrade

3. **Departments** (5 SPs)

   - GetDepartments, GetDepartment, CreateDepartment, UpdateDepartment, DeleteDepartment

4. **Appraisal Cycles** (5+ SPs)

   - GetAppraisalCycles, GetAllAppraisalCycles, GetAppraisalCycle, CreateAppraisalCycle, UpdateAppraisalCycle, DeleteAppraisalCycle

5. **Review Frequencies** (5 SPs)

6. **Frequency Calendars** (5+ SPs)

7. **Frequency Calendar Details** (5+ SPs)

8. **Questionnaire Templates** (6+ SPs including copy operation)

9. **Review Cycles** (5 SPs)

10. **Evaluations** (10+ SPs including complex queries with joins)

11. **Appraisal Groups** (5+ SPs)

12. **Appraisal Group Members** (4 SPs)

13. **Initiated Appraisals** (5+ SPs)

14. **Scheduled Appraisal Tasks** (5+ SPs)

15. **Registrations** (4 SPs)

16. **Access Tokens** (5 SPs)

17. **Email Templates** (5 SPs)

18. **Publish Questionnaires** (5 SPs)

### Key Differences: Postgres → SQL Server

1. **Data Types:**

   - `serial` → `INT IDENTITY(1,1)` or `UNIQUEIDENTIFIER DEFAULT NEWID()`
   - `uuid` → `UNIQUEIDENTIFIER`
   - `text` → `NVARCHAR(MAX)`
   - `varchar(n)` → `NVARCHAR(n)`
   - `boolean` → `BIT`
   - `json/jsonb` → `NVARCHAR(MAX)` (store as JSON string)
   - `text[]` → `NVARCHAR(MAX)` (store as JSON array)
   - `timestamp with time zone` → `DATETIME2` or `DATETIMEOFFSET`
   - `now()` → `SYSDATETIME()` or `SYSDATETIMEOFFSET()`

2. **SQL Syntax:**

   - `RETURNING *` → Use `OUTPUT INSERTED.*` or return via SELECT after insert
   - `ON CONFLICT DO UPDATE` → Use `MERGE` statement or `IF EXISTS...UPDATE ELSE INSERT`
   - Array operators (`@>`, `&&`) → Use JSON functions or separate tables
   - `ILIKE` → `LIKE` (SQL Server is case-insensitive by default)

3. **Security & Roles:**

   - Array field `roles` (Postgres `text[]`) needs to be:
     - Option A: Store as JSON string in `NVARCHAR(MAX)`
     - Option B: Create a separate `user_roles` junction table
   - Current approach in SPs: stored as JSON string `["role1","role2"]`

4. **Connection String:**
   ```
   Server=YOUR_HOST,1433;Database=YourDatabaseName;User Id=YOUR_USER;Password=YOUR_PASSWORD;Encrypt=true;TrustServerCertificate=true
   ```

## Environment Setup

Add to `.env`:

```
DATABASE_URL=Server=YOUR_HOST,1433;Database=YourDatabaseName;User Id=YOUR_USER;Password=YOUR_PASSWORD;Encrypt=true;TrustServerCertificate=true
```

## Testing Approach

1. **Test connection:**

   ```powershell
   node -e "const sql=require('mssql');(async()=>{try{await sql.connect(process.env.DATABASE_URL);console.log('OK')}catch(e){console.error(e)}finally{sql.close()}})()"
   ```

2. **Test SPs:**

   - Run `migrations/stored_procedures_complete.sql` in SSMS
   - Test individual SPs with sample data

3. **Test app incrementally:**
   - Start with authentication routes
   - Then company management
   - Then user management
   - Finally complex features (appraisals, evaluations)

## Next Steps

1. **Deploy remaining SPs** - Create SPs for all entities following the pattern in `stored_procedures_complete.sql`

2. **Convert `storage.ts`** - Update each method to use `getPool()` and execute SPs instead of Drizzle queries

3. **Handle complex queries** - Some methods in `storage.ts` have complex joins and aggregations. These need custom SPs.

4. **Test thoroughly** - Each feature needs testing after migration

5. **Remove Drizzle dependencies** - Once migration is complete:
   ```bash
   npm uninstall @neondatabase/serverless drizzle-orm drizzle-kit
   ```

## Need Help?

The pattern is consistent across all entities:

1. Create SP in SSMS following naming convention `dbo.VerbEntityName`
2. Update `storage.ts` method to call SP via `getPool().request().input(...).execute(...)`
3. Map returned columns (PascalCase in SP) to expected TypeScript interface

Example template for any entity:

```typescript
async getEntity(id: string): Promise<Entity | undefined> {
  const pool = await getPool();
  const result = await pool.request()
    .input('Id', sql.UniqueIdentifier, id)
    .execute('dbo.GetEntity');
  return result.recordset?.[0];
}
```
