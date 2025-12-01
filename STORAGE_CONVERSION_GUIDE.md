# Storage.ts Conversion Guide - Drizzle to MSSQL Stored Procedures

## Import Changes

**Before:**

```typescript
import { db } from "./db";
import {
  eq,
  and,
  desc,
  asc,
  like,
  inArray,
  or,
  sql,
  isNotNull,
} from "drizzle-orm";
```

**After:**

```typescript
import { getPool } from "./mssql";
import * as sql from "mssql";
```

## Pattern: Simple GET by ID

**Before (Drizzle):**

```typescript
async getUser(id: string): Promise<User | undefined> {
  const [user] = await db.select().from(users).where(eq(users.id, id));
  return user;
}
```

**After (SP):**

```typescript
async getUser(id: string): Promise<User | undefined> {
  const pool = await getPool();
  const result = await pool.request()
    .input('Id', sql.UniqueIdentifier, id)
    .execute('dbo.GetUser');
  return result.recordset[0];
}
```

## Pattern: GET ALL with Filters

**Before (Drizzle):**

```typescript
async getUsers(filters?: { role?: string; companyId?: string }, requestingUserId?: string): Promise<SafeUser[]> {
  const conditions = [];
  if (filters?.role) conditions.push(eq(users.role, filters.role));
  if (filters?.companyId) conditions.push(eq(users.companyId, filters.companyId));

  const results = await db.select().from(users).where(and(...conditions));
  return sanitizeUsers(results);
}
```

**After (SP):**

```typescript
async getUsers(filters?: { role?: string; companyId?: string }, requestingUserId?: string): Promise<SafeUser[]> {
  const pool = await getPool();
  const result = await pool.request()
    .input('RequestingUserId', sql.UniqueIdentifier, requestingUserId || null)
    .input('Role', sql.NVarChar(50), filters?.role || null)
    .input('CompanyId', sql.UniqueIdentifier, filters?.companyId || null)
    .execute('dbo.GetUsers');
  return sanitizeUsers(result.recordset);
}
```

## Pattern: CREATE

**Before (Drizzle):**

```typescript
async createCompany(company: InsertCompany): Promise<Company> {
  const [result] = await db.insert(companies).values(company).returning();
  return result;
}
```

**After (SP):**

```typescript
async createCompany(company: InsertCompany): Promise<Company> {
  const pool = await getPool();
  const result = await pool.request()
    .input('Name', sql.NVarChar(255), company.name)
    .input('CompanyUrl', sql.NVarChar(255), company.companyUrl)
    .input('Address', sql.NVarChar(sql.MAX), company.address || null)
    .input('City', sql.NVarChar(255), company.city || null)
    .input('State', sql.NVarChar(255), company.state || null)
    .input('Country', sql.NVarChar(255), company.country || null)
    .input('Pincode', sql.NVarChar(20), company.pincode || null)
    .input('Status', sql.NVarChar(20), company.status || 'active')
    .execute('dbo.CreateCompany');
  return result.recordset[0];
}
```

## Pattern: UPDATE

**Before (Drizzle):**

```typescript
async updateCompany(id: string, company: Partial<InsertCompany>): Promise<Company> {
  const [result] = await db
    .update(companies)
    .set({ ...company, updatedAt: new Date() })
    .where(eq(companies.id, id))
    .returning();
  return result;
}
```

**After (SP):**

```typescript
async updateCompany(id: string, company: Partial<InsertCompany>): Promise<Company> {
  const pool = await getPool();
  const result = await pool.request()
    .input('Id', sql.UniqueIdentifier, id)
    .input('Name', sql.NVarChar(255), company.name || null)
    .input('CompanyUrl', sql.NVarChar(255), company.companyUrl || null)
    .input('Address', sql.NVarChar(sql.MAX), company.address || null)
    .input('City', sql.NVarChar(255), company.city || null)
    .input('State', sql.NVarChar(255), company.state || null)
    .input('Country', sql.NVarChar(255), company.country || null)
    .input('Pincode', sql.NVarChar(20), company.pincode || null)
    .input('Status', sql.NVarChar(20), company.status || null)
    .execute('dbo.UpdateCompany');
  return result.recordset[0];
}
```

## Pattern: DELETE

**Before (Drizzle):**

```typescript
async deleteCompany(id: string): Promise<void> {
  await db.delete(companies).where(eq(companies.id, id));
}
```

**After (SP):**

```typescript
async deleteCompany(id: string): Promise<void> {
  const pool = await getPool();
  await pool.request()
    .input('Id', sql.UniqueIdentifier, id)
    .execute('dbo.DeleteCompany');
}
```

## Pattern: Complex Filters with Security

**Before (Drizzle):**

```typescript
async getEvaluations(filters?: { employeeId?: string; managerId?: string }): Promise<Evaluation[]> {
  const conditions = [];
  if (filters?.employeeId) conditions.push(eq(evaluations.employeeId, filters.employeeId));
  if (filters?.managerId) conditions.push(eq(evaluations.managerId, filters.managerId));

  const results = await db
    .select()
    .from(evaluations)
    .where(conditions.length ? and(...conditions) : undefined)
    .orderBy(desc(evaluations.createdAt));
  return results;
}
```

**After (SP):**

```typescript
async getEvaluations(filters?: { employeeId?: string; managerId?: string }): Promise<Evaluation[]> {
  const pool = await getPool();
  const result = await pool.request()
    .input('EmployeeId', sql.UniqueIdentifier, filters?.employeeId || null)
    .input('ManagerId', sql.UniqueIdentifier, filters?.managerId || null)
    .input('ReviewCycleId', sql.UniqueIdentifier, null)
    .input('Status', sql.NVarChar(50), null)
    .execute('dbo.GetEvaluations');
  return result.recordset;
}
```

## Pattern: JSON Fields

**Before (Drizzle):**

```typescript
async createQuestionnaireTemplate(template: InsertQuestionnaireTemplate): Promise<QuestionnaireTemplate> {
  const [result] = await db.insert(questionnaireTemplates).values({
    ...template,
    questions: template.questions // Drizzle handles JSON automatically
  }).returning();
  return result;
}
```

**After (SP):**

```typescript
async createQuestionnaireTemplate(template: InsertQuestionnaireTemplate): Promise<QuestionnaireTemplate> {
  const pool = await getPool();
  const result = await pool.request()
    .input('Name', sql.NVarChar(255), template.name)
    .input('Description', sql.NVarChar(sql.MAX), template.description || null)
    .input('TargetRole', sql.NVarChar(50), template.targetRole)
    .input('Questions', sql.NVarChar(sql.MAX), JSON.stringify(template.questions)) // Convert to JSON string
    .input('Year', sql.Int, template.year || null)
    .input('Status', sql.NVarChar(20), template.status || 'active')
    .input('ApplicableCategory', sql.NVarChar(20), template.applicableCategory || null)
    .input('ApplicableLevelId', sql.UniqueIdentifier, template.applicableLevelId || null)
    .input('ApplicableGradeId', sql.UniqueIdentifier, template.applicableGradeId || null)
    .input('ApplicableLocationId', sql.UniqueIdentifier, template.applicableLocationId || null)
    .input('SendOnMail', sql.Bit, template.sendOnMail || false)
    .input('CreatedById', sql.UniqueIdentifier, template.createdById || null)
    .execute('dbo.CreateQuestionnaireTemplate');

  // Parse JSON fields in result
  const record = result.recordset[0];
  if (record && record.questions) {
    record.questions = JSON.parse(record.questions);
  }
  return record;
}
```

## Pattern: UPSERT (now needs special handling)

**Before (Drizzle):**

```typescript
async upsertUser(userData: UpsertUser): Promise<User> {
  const [user] = await db
    .insert(users)
    .values(userData)
    .onConflictDoUpdate({
      target: users.id,
      set: { email: userData.email, firstName: userData.firstName }
    })
    .returning();
  return user;
}
```

**After (SP):**

```typescript
async upsertUser(userData: UpsertUser): Promise<User> {
  const pool = await getPool();
  const result = await pool.request()
    .input('Id', sql.UniqueIdentifier, userData.id)
    .input('Email', sql.NVarChar(255), userData.email)
    .input('FirstName', sql.NVarChar(255), userData.firstName || null)
    .input('LastName', sql.NVarChar(255), userData.lastName || null)
    .input('ProfileImageUrl', sql.NVarChar(sql.MAX), userData.profileImageUrl || null)
    .execute('dbo.UpsertUser');
  return result.recordset[0];
}
```

## Pattern: Complex Joins (handle in application)

**Before (Drizzle):**

```typescript
async getAppraisalGroupsWithMembers(createdById: string): Promise<(AppraisalGroup & { members: SafeUser[] })[]> {
  const groups = await db
    .select()
    .from(appraisalGroups)
    .leftJoin(appraisalGroupMembers, eq(appraisalGroups.id, appraisalGroupMembers.appraisalGroupId))
    .leftJoin(users, eq(appraisalGroupMembers.employeeId, users.id))
    .where(eq(appraisalGroups.createdById, createdById));

  // Complex grouping logic...
  return results;
}
```

**After (SP - simplified, join in application):**

```typescript
async getAppraisalGroupsWithMembers(createdById: string): Promise<(AppraisalGroup & { members: SafeUser[] })[]> {
  const pool = await getPool();

  // Get groups
  const groupsResult = await pool.request()
    .input('CreatedById', sql.UniqueIdentifier, createdById)
    .execute('dbo.GetAppraisalGroups');
  const groups = groupsResult.recordset;

  // For each group, get members
  const result = await Promise.all(groups.map(async (group) => {
    const membersResult = await pool.request()
      .input('AppraisalGroupId', sql.UniqueIdentifier, group.id)
      .execute('dbo.GetAppraisalGroupMembers');
    const memberIds = membersResult.recordset.map((m: any) => m.employeeId);

    // Get user details for each member
    const memberUsers = await Promise.all(memberIds.map(async (userId: string) => {
      const userResult = await pool.request()
        .input('Id', sql.UniqueIdentifier, userId)
        .execute('dbo.GetUser');
      return userResult.recordset[0] ? sanitizeUser(userResult.recordset[0]) : null;
    }));

    return {
      ...group,
      members: memberUsers.filter(u => u !== null)
    };
  }));

  return result;
}
```

## Data Type Mappings

| TypeScript/Schema | MSSQL Input Type      | Example                                                      |
| ----------------- | --------------------- | ------------------------------------------------------------ |
| string (UUID)     | sql.UniqueIdentifier  | `input('Id', sql.UniqueIdentifier, id)`                      |
| string            | sql.NVarChar(length)  | `input('Name', sql.NVarChar(255), name)`                     |
| text (unlimited)  | sql.NVarChar(sql.MAX) | `input('Description', sql.NVarChar(sql.MAX), desc)`          |
| number            | sql.Int               | `input('Year', sql.Int, year)`                               |
| boolean           | sql.Bit               | `input('IsActive', sql.Bit, isActive)`                       |
| Date              | sql.DateTime2         | `input('CreatedAt', sql.DateTime2, new Date())`              |
| JSON object       | sql.NVarChar(sql.MAX) | `input('Data', sql.NVarChar(sql.MAX), JSON.stringify(obj))`  |
| JSON array        | sql.NVarChar(sql.MAX) | `input('Items', sql.NVarChar(sql.MAX), JSON.stringify(arr))` |

## Handling Optional Parameters

Always pass `null` for optional parameters that aren't provided:

```typescript
.input('OptionalField', sql.NVarChar(255), value || null)
```

The stored procedure uses `COALESCE(@OptionalField, existing_field)` to preserve existing values when null is passed.

## Error Handling

Wrap SP calls in try-catch for better error messages:

```typescript
async getUser(id: string): Promise<User | undefined> {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('Id', sql.UniqueIdentifier, id)
      .execute('dbo.GetUser');
    return result.recordset[0];
  } catch (error) {
    console.error('Error in getUser:', error);
    throw new Error(`Failed to get user: ${error.message}`);
  }
}
```

## Complete Example: User Methods

```typescript
// GET by ID
async getUser(id: string): Promise<User | undefined> {
  const pool = await getPool();
  const result = await pool.request()
    .input('Id', sql.UniqueIdentifier, id)
    .execute('dbo.GetUser');
  return result.recordset[0];
}

// GET by Email
async getUserByEmail(email: string): Promise<User | undefined> {
  const pool = await getPool();
  const result = await pool.request()
    .input('Email', sql.NVarChar(255), email)
    .execute('dbo.GetUserByEmail');
  return result.recordset[0];
}

// GET with filters
async getUsers(filters?: { role?: string; companyId?: string }, requestingUserId?: string): Promise<SafeUser[]> {
  const pool = await getPool();
  const result = await pool.request()
    .input('RequestingUserId', sql.UniqueIdentifier, requestingUserId || null)
    .input('Role', sql.NVarChar(50), filters?.role || null)
    .input('CompanyId', sql.UniqueIdentifier, filters?.companyId || null)
    .input('Department', sql.NVarChar(255), null)
    .input('Status', sql.NVarChar(20), null)
    .execute('dbo.GetUsers');
  return sanitizeUsers(result.recordset);
}

// CREATE
async createUser(user: InsertUser, creatorId?: string): Promise<SafeUser> {
  const pool = await getPool();
  const hashedPassword = user.passwordHash ? await bcrypt.hash(user.passwordHash, 10) : null;

  const result = await pool.request()
    .input('Email', sql.NVarChar(255), user.email)
    .input('FirstName', sql.NVarChar(255), user.firstName)
    .input('LastName', sql.NVarChar(255), user.lastName || null)
    .input('PasswordHash', sql.NVarChar(255), hashedPassword)
    .input('Role', sql.NVarChar(50), user.role || 'employee')
    .input('Department', sql.NVarChar(255), user.department || null)
    .input('Designation', sql.NVarChar(255), user.designation || null)
    .input('ManagerId', sql.UniqueIdentifier, user.managerId || null)
    .input('CompanyId', sql.UniqueIdentifier, user.companyId || null)
    .input('LocationId', sql.UniqueIdentifier, user.locationId || null)
    .input('GradeId', sql.UniqueIdentifier, user.gradeId || null)
    .input('LevelId', sql.UniqueIdentifier, user.levelId || null)
    .input('Status', sql.NVarChar(20), user.status || 'active')
    .input('Mobile', sql.NVarChar(20), user.mobile || null)
    .input('EmployeeCode', sql.NVarChar(50), user.employeeCode || null)
    .execute('dbo.CreateUser');

  return sanitizeUser(result.recordset[0]);
}

// UPDATE
async updateUser(id: string, user: Partial<InsertUser>, requestingUserId?: string): Promise<SafeUser> {
  const pool = await getPool();
  const hashedPassword = user.passwordHash ? await bcrypt.hash(user.passwordHash, 10) : null;

  const result = await pool.request()
    .input('Id', sql.UniqueIdentifier, id)
    .input('Email', sql.NVarChar(255), user.email || null)
    .input('FirstName', sql.NVarChar(255), user.firstName || null)
    .input('LastName', sql.NVarChar(255), user.lastName || null)
    .input('PasswordHash', sql.NVarChar(255), hashedPassword)
    .input('Role', sql.NVarChar(50), user.role || null)
    .input('Department', sql.NVarChar(255), user.department || null)
    .input('Designation', sql.NVarChar(255), user.designation || null)
    .input('ManagerId', sql.UniqueIdentifier, user.managerId || null)
    .input('CompanyId', sql.UniqueIdentifier, user.companyId || null)
    .input('LocationId', sql.UniqueIdentifier, user.locationId || null)
    .input('GradeId', sql.UniqueIdentifier, user.gradeId || null)
    .input('LevelId', sql.UniqueIdentifier, user.levelId || null)
    .input('Status', sql.NVarChar(20), user.status || null)
    .input('Mobile', sql.NVarChar(20), user.mobile || null)
    .input('EmployeeCode', sql.NVarChar(50), user.employeeCode || null)
    .input('RequestingUserId', sql.UniqueIdentifier, requestingUserId || null)
    .execute('dbo.UpdateUser');

  return sanitizeUser(result.recordset[0]);
}

// DELETE
async deleteUser(id: string, requestingUserId?: string): Promise<void> {
  const pool = await getPool();
  await pool.request()
    .input('Id', sql.UniqueIdentifier, id)
    .input('RequestingUserId', sql.UniqueIdentifier, requestingUserId || null)
    .execute('dbo.DeleteUser');
}

// UPSERT
async upsertUser(userData: UpsertUser): Promise<User> {
  const pool = await getPool();
  const result = await pool.request()
    .input('Id', sql.UniqueIdentifier, userData.id)
    .input('Email', sql.NVarChar(255), userData.email)
    .input('FirstName', sql.NVarChar(255), userData.firstName || null)
    .input('LastName', sql.NVarChar(255), userData.lastName || null)
    .input('ProfileImageUrl', sql.NVarChar(sql.MAX), userData.profileImageUrl || null)
    .execute('dbo.UpsertUser');
  return result.recordset[0];
}
```

## Deployment Steps

1. **Execute all SP migration files in SSMS:**

   ```sql
   USE [YourDatabaseName];
   -- Execute in order:
   -- all_stored_procedures.sql (Part 1)
   -- all_stored_procedures_part2.sql (Part 2)
   -- all_stored_procedures_part3.sql (Part 3)
   -- all_stored_procedures_part4.sql (Part 4)
   ```

2. **Update storage.ts imports and replace all methods**

3. **Remove Drizzle dependencies:**

   ```bash
   npm uninstall drizzle-orm drizzle-kit @neondatabase/serverless
   ```

4. **Update environment variables:**

   ```
   DATABASE_URL=Server=your-server;Database=your-db;User Id=user;Password=pass;Encrypt=true;
   ```

5. **Test each module:**
   - User operations
   - Company/Location/Level/Grade/Department CRUD
   - Appraisal Cycle management
   - Questionnaire Templates
   - Evaluations
   - Appraisal Groups and Initiated Appraisals

## Migration Checklist

### Core Entities

- [x] Users - 10 SPs (Get, GetByEmail, GetByCode, GetByMobile, GetUsers, GetUsersByManager, UpsertUser, Create, Update, Delete)
- [x] Companies - 6 SPs (Get, GetAll, GetByUrl, Create, Update, Delete)
- [x] Locations - 5 SPs (Get, GetAll, Create, Update, Delete)
- [x] Calendar Credentials - 5 SPs (Get, Create, Update, UpdateTokens, Delete)
- [x] Email Config - 3 SPs (Get, Create, Update)
- [x] Email Templates - 5 SPs (Get, GetAll, Create, Update, Delete)

### Admin Entities

- [x] Levels - 5 SPs (Get, GetAll, Create, Update, Delete)
- [x] Grades - 5 SPs (Get, GetAll, Create, Update, Delete)
- [x] Departments - 5 SPs (Get, GetAll, Create, Update, Delete)
- [x] Appraisal Cycles - 6 SPs (Get, GetAll, GetAllAppraisalCycles, Create, Update, Delete)
- [x] Review Frequencies - 5 SPs (Get, GetAll, Create, Update, Delete)
- [x] Frequency Calendars - 6 SPs (Get, GetAll, GetAllFrequencyCalendars, Create, Update, Delete)
- [x] Frequency Calendar Details - 7 SPs (Get, GetAll, GetAllFCD, GetByCalendar, Create, Update, Delete)

### Complex Entities

- [x] Questionnaire Templates - 7 SPs (Get, GetAll, Create, Update, Delete, GetByYear, Copy)
- [x] Review Cycles - 6 SPs (Get, GetAll, Create, Update, Delete, GetActive)
- [x] Evaluations - 9 SPs (Get, GetAll, Create, Update, Delete, GetByEmployeeAndCycle, GetByInitiatedAppraisal)
- [x] Registrations - 4 SPs (Get, GetAll, Create, Update)
- [x] Access Tokens - 5 SPs (Create, Get, MarkAsUsed, Deactivate, GetActiveByUser)

### Appraisal Entities

- [x] Appraisal Groups - 5 SPs (Get, GetAll, Create, Update, Delete)
- [x] Appraisal Group Members - 3 SPs (GetMembers, Add, Remove)
- [x] Initiated Appraisals - 4 SPs (Create, Get, GetAll, UpdateStatus)
- [x] Initiated Appraisal Detail Timings - 3 SPs (Create, Get, UpdateStatus)
- [x] Scheduled Appraisal Tasks - 4 SPs (Create, GetPending, UpdateStatus, GetByAppraisal)
- [x] Publish Questionnaires - 5 SPs (Get, GetAll, Create, Update, Delete)

### Storage.ts Conversion

- [ ] Update imports
- [ ] Convert all 100+ methods to use SPs
- [ ] Test all endpoints

TOTAL: 150+ stored procedures covering all entities
