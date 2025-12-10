-- =============================================
-- Create Super Admin User for PMS Application
-- Database: SQL Server (MSSQL)
-- =============================================

USE [PMS_DB];
GO

SET XACT_ABORT ON;
GO

-- =============================================
-- SUPER ADMIN CREDENTIALS
-- =============================================
-- Email: superadmin@pms.com
-- Password: SuperAdmin@2024!
-- =============================================

BEGIN TRANSACTION;

DECLARE @SuperAdminId UNIQUEIDENTIFIER = NEWID();

-- Insert Super Admin User
-- Password hash is for 'SuperAdmin@2024!' using bcrypt
INSERT INTO dbo.users (
    id,
    email,
    first_name,
    last_name,
    code,
    designation,
    date_of_joining,
    mobile_number,
    role,
    roles,
    status,
    password_hash,
    company_id,
    created_at,
    updated_at
)
VALUES (
    @SuperAdminId,
    'superadmin@pms.com',
    'Super',
    'Admin',
    'SA001',
    'Super Administrator',
    SYSDATETIME(),
    '+1234567890',
    'super_admin',
    '["super_admin"]',  -- JSON array for roles
    'active',
    '$2b$10$YQ98PqF2cG3bI6FZJqMvxO6FvZJqY8nKqvFQ0QP0xGVqH7cE3qQy2',  -- SuperAdmin@2024!
    NULL,  -- No company for super admin
    SYSDATETIME(),
    SYSDATETIME()
);

-- Verify the user was created
SELECT
    id,
    email,
    first_name,
    last_name,
    code,
    designation,
    role,
    roles,
    status,
    created_at,
    updated_at
FROM dbo.users
WHERE email = 'superadmin@pms.com';

-- Print success message
PRINT '========================================';
PRINT 'Super Admin user created successfully!';
PRINT '========================================';
PRINT 'Login Credentials:';
PRINT 'Email: superadmin@pms.com';
PRINT 'Password: SuperAdmin@2024!';
PRINT '========================================';

COMMIT TRANSACTION;
GO
