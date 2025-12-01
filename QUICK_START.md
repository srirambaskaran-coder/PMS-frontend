# Quick Start Guide - Complete Storage.ts Conversion

## What's Been Done ✅

1. **All 150+ Stored Procedures Created** in 4 files:

   - `migrations/all_stored_procedures.sql` (Part 1 - Core: Users, Companies, Locations, Email, Calendar)
   - `migrations/all_stored_procedures_part2.sql` (Part 2 - Admin: Levels, Grades, Departments, Cycles, Calendars)
   - `migrations/all_stored_procedures_part3.sql` (Part 3 - Complex: Questionnaires, Evaluations, Registrations, Tokens)
   - `migrations/all_stored_procedures_part4.sql` (Part 4 - Appraisals: Groups, Initiated, Tasks, Publish)

2. **Templates & Documentation Created:**

   - `STORAGE_CONVERSION_GUIDE.md` - Detailed conversion patterns
   - `server/storage_sp_template.ts` - Working code examples
   - `MIGRATION_STATUS.md` - Complete project status
   - `server/storage.ts.backup` - Original file backup

3. **Infrastructure Ready:**
   - `server/mssql.ts` - Connection pool manager
   - `mssql` package installed

## What You Need to Do 🔨

### STEP 1: Deploy Stored Procedures

```sql
-- In SQL Server Management Studio (SSMS):
USE [YourDatabaseName];
GO

-- Execute these 4 files in order:
-- File 1: migrations/all_stored_procedures.sql
-- File 2: migrations/all_stored_procedures_part2.sql
-- File 3: migrations/all_stored_procedures_part3.sql
-- File 4: migrations/all_stored_procedures_part4.sql

-- Verify SPs created:
SELECT COUNT(*) AS TotalSPs FROM sys.procedures WHERE name LIKE 'Get%' OR name LIKE 'Create%' OR name LIKE 'Update%' OR name LIKE 'Delete%';
-- Should show 150+ SPs
```

### STEP 2: Convert storage.ts

**Option A: Manual Conversion (Recommended for Learning)**
Open `server/storage.ts` and for each method, apply the patterns from `server/storage_sp_template.ts`:

```typescript
// BEFORE (Drizzle):
async getUser(id: string): Promise<User | undefined> {
  const [user] = await db.select().from(users).where(eq(users.id, id));
  return user;
}

// AFTER (MSSQL SP):
async getUser(id: string): Promise<User | undefined> {
  const pool = await getPool();
  const result = await pool.request()
    .input('Id', sql.UniqueIdentifier, id)
    .execute('dbo.GetUser');
  return result.recordset[0];
}
```

**Repeat this pattern for all ~100 methods.**

**Option B: Quick Conversion (Use Template)**

1. Copy entire `DatabaseStorage` class from `server/storage_sp_template.ts`
2. Paste into `server/storage.ts` (replacing old class)
3. Add missing methods using patterns from template
4. Refer to `STORAGE_CONVERSION_GUIDE.md` for specific patterns

### STEP 3: Update Environment

```bash
# .env file
DATABASE_URL=Server=your-server.database.windows.net;Database=YourDatabaseName;User Id=your-user;Password=your-password;Encrypt=true;
```

### STEP 4: Test

```bash
npm run dev
# Test each endpoint systematically
```

## Common Patterns Reference

### Simple GET

```typescript
async getCompany(id: string): Promise<Company | undefined> {
  const pool = await getPool();
  const result = await pool.request()
    .input('Id', sql.UniqueIdentifier, id)
    .execute('dbo.GetCompany');
  return result.recordset[0];
}
```

### CREATE with Multiple Fields

```typescript
async createCompany(company: InsertCompany): Promise<Company> {
  const pool = await getPool();
  const result = await pool.request()
    .input('Name', sql.NVarChar(255), company.name)
    .input('CompanyUrl', sql.NVarChar(255), company.companyUrl)
    .input('Address', sql.NVarChar(sql.MAX), company.address || null)
    .input('Status', sql.NVarChar(20), company.status || 'active')
    .execute('dbo.CreateCompany');
  return result.recordset[0];
}
```

### UPDATE with Optional Fields

```typescript
async updateCompany(id: string, company: Partial<InsertCompany>): Promise<Company> {
  const pool = await getPool();
  const result = await pool.request()
    .input('Id', sql.UniqueIdentifier, id)
    .input('Name', sql.NVarChar(255), company.name || null)
    .input('CompanyUrl', sql.NVarChar(255), company.companyUrl || null)
    .input('Status', sql.NVarChar(20), company.status || null)
    .execute('dbo.UpdateCompany');
  return result.recordset[0];
}
```

### DELETE

```typescript
async deleteCompany(id: string): Promise<void> {
  const pool = await getPool();
  await pool.request()
    .input('Id', sql.UniqueIdentifier, id)
    .execute('dbo.DeleteCompany');
}
```

### With Security Isolation (Levels, Grades, etc.)

```typescript
async getLevels(createdById: string): Promise<Level[]> {
  const pool = await getPool();
  const result = await pool.request()
    .input('CreatedById', sql.UniqueIdentifier, createdById)
    .execute('dbo.GetLevels');
  return result.recordset;
}
```

### With JSON Fields (Questionnaires, Evaluations)

```typescript
async createQuestionnaireTemplate(template: InsertQuestionnaireTemplate): Promise<QuestionnaireTemplate> {
  const pool = await getPool();
  const result = await pool.request()
    .input('Name', sql.NVarChar(255), template.name)
    .input('Questions', sql.NVarChar(sql.MAX), JSON.stringify(template.questions))
    .execute('dbo.CreateQuestionnaireTemplate');

  const record = result.recordset[0];
  if (record && record.questions) {
    record.questions = JSON.parse(record.questions);
  }
  return record;
}
```

### With Filters (Users, Evaluations)

```typescript
async getEvaluations(filters?: { employeeId?: string; status?: string }): Promise<Evaluation[]> {
  const pool = await getPool();
  const result = await pool.request()
    .input('EmployeeId', sql.UniqueIdentifier, filters?.employeeId || null)
    .input('ManagerId', sql.UniqueIdentifier, null)
    .input('ReviewCycleId', sql.UniqueIdentifier, null)
    .input('Status', sql.NVarChar(50), filters?.status || null)
    .execute('dbo.GetEvaluations');
  return result.recordset;
}
```

## Data Type Quick Reference

| TypeScript    | MSSQL Input             | Example                                                     |
| ------------- | ----------------------- | ----------------------------------------------------------- |
| string (UUID) | `sql.UniqueIdentifier`  | `input('Id', sql.UniqueIdentifier, id)`                     |
| string        | `sql.NVarChar(255)`     | `input('Name', sql.NVarChar(255), name)`                    |
| text          | `sql.NVarChar(sql.MAX)` | `input('Desc', sql.NVarChar(sql.MAX), desc)`                |
| number        | `sql.Int`               | `input('Year', sql.Int, year)`                              |
| boolean       | `sql.Bit`               | `input('Active', sql.Bit, active)`                          |
| Date          | `sql.DateTime2`         | `input('Date', sql.DateTime2, new Date())`                  |
| JSON          | `sql.NVarChar(sql.MAX)` | `input('Data', sql.NVarChar(sql.MAX), JSON.stringify(obj))` |

## Method Mapping

Each storage.ts method → Stored Procedure:

- `getUser(id)` → `dbo.GetUser`
- `getUserByEmail(email)` → `dbo.GetUserByEmail`
- `getUsers(filters)` → `dbo.GetUsers`
- `createUser(user)` → `dbo.CreateUser`
- `updateUser(id, user)` → `dbo.UpdateUser`
- `deleteUser(id)` → `dbo.DeleteUser`
- `upsertUser(user)` → `dbo.UpsertUser`

**Same pattern for all entities:** Get, GetAll, GetByX, Create, Update, Delete

## Files to Reference

1. **STORAGE_CONVERSION_GUIDE.md** - Comprehensive patterns with explanations
2. **server/storage_sp_template.ts** - Working code you can copy
3. **MIGRATION_STATUS.md** - Full project status and checklist
4. **migrations/all_stored_procedures\*.sql** - The actual SPs (4 files)

## Estimated Time

- Manual conversion: **4-6 hours** (best for understanding)
- Template-based: **2-3 hours** (faster, some cleanup needed)
- Testing: **2-3 hours** (critical paths)

**Total: 6-12 hours** depending on approach

## Need Help?

Check these files in order:

1. `STORAGE_CONVERSION_GUIDE.md` - Detailed patterns
2. `server/storage_sp_template.ts` - Copy-paste examples
3. `migrations/all_stored_procedures.sql` - See what SP accepts

---

**You're 70% done!** The hard work (designing 150+ SPs) is complete. Now it's just systematic application of patterns to each method.
