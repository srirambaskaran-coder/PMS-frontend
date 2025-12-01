-- ========================================
-- COMPLETE STORED PROCEDURES LIBRARY
-- Performance Management System - MSSQL
-- ========================================

USE [YourDatabaseName];
GO
SET XACT_ABORT ON;
GO

-- ========================================
-- CALENDAR CREDENTIALS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetCalendarCredential
  @CompanyId UNIQUEIDENTIFIER,
  @Provider  NVARCHAR(20)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT TOP 1
    id AS Id, company_id AS CompanyId, provider AS Provider,
    client_id AS ClientId, client_secret AS ClientSecret,
    access_token AS AccessToken, refresh_token AS RefreshToken,
    expires_at AS ExpiresAt, created_at AS CreatedAt,
    updated_at AS UpdatedAt, scope AS Scope, is_active AS IsActive
  FROM dbo.calendar_credentials
  WHERE company_id = @CompanyId AND provider = @Provider AND is_active = 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateCalendarCredentialTokens
  @CompanyId UNIQUEIDENTIFIER, @Provider NVARCHAR(20),
  @AccessToken NVARCHAR(MAX), @RefreshToken NVARCHAR(MAX) = NULL,
  @ExpiresAt DATETIME2 = NULL
AS
BEGIN
  SET NOCOUNT ON;
  IF EXISTS (SELECT 1 FROM dbo.calendar_credentials WHERE company_id=@CompanyId AND provider=@Provider)
  BEGIN
    UPDATE dbo.calendar_credentials
    SET access_token=@AccessToken, refresh_token=@RefreshToken,
        expires_at=@ExpiresAt, updated_at=SYSDATETIME()
    WHERE company_id=@CompanyId AND provider=@Provider;
  END
  ELSE
  BEGIN
    INSERT INTO dbo.calendar_credentials
      (company_id, provider, client_id, client_secret, access_token, refresh_token, expires_at, created_at, updated_at, is_active)
    VALUES (@CompanyId, @Provider, NULL, NULL, @AccessToken, @RefreshToken, @ExpiresAt, SYSDATETIME(), SYSDATETIME(), 1);
  END
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateCalendarCredential
  @CompanyId UNIQUEIDENTIFIER, @Provider NVARCHAR(20),
  @ClientId NVARCHAR(255), @ClientSecret NVARCHAR(255),
  @AccessToken NVARCHAR(MAX) = NULL, @RefreshToken NVARCHAR(MAX) = NULL,
  @ExpiresAt DATETIME2 = NULL, @Scope NVARCHAR(MAX) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  INSERT INTO dbo.calendar_credentials
    (id, company_id, provider, client_id, client_secret, access_token, refresh_token, expires_at, scope, is_active, created_at, updated_at)
  VALUES (@Id, @CompanyId, @Provider, @ClientId, @ClientSecret, @AccessToken, @RefreshToken, @ExpiresAt, @Scope, 1, SYSDATETIME(), SYSDATETIME());
  
  EXEC dbo.GetCalendarCredential @CompanyId, @Provider;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateCalendarCredential
  @Id UNIQUEIDENTIFIER,
  @ClientId NVARCHAR(255) = NULL, @ClientSecret NVARCHAR(255) = NULL,
  @AccessToken NVARCHAR(MAX) = NULL, @RefreshToken NVARCHAR(MAX) = NULL,
  @ExpiresAt DATETIME2 = NULL, @Scope NVARCHAR(MAX) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE dbo.calendar_credentials
  SET client_id = COALESCE(@ClientId, client_id),
      client_secret = COALESCE(@ClientSecret, client_secret),
      access_token = COALESCE(@AccessToken, access_token),
      refresh_token = COALESCE(@RefreshToken, refresh_token),
      expires_at = COALESCE(@ExpiresAt, expires_at),
      scope = COALESCE(@Scope, scope),
      updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  SELECT TOP 1
    id AS Id, company_id AS CompanyId, provider AS Provider,
    client_id AS ClientId, client_secret AS ClientSecret,
    access_token AS AccessToken, refresh_token AS RefreshToken,
    expires_at AS ExpiresAt, created_at AS CreatedAt,
    updated_at AS UpdatedAt, scope AS Scope, is_active AS IsActive
  FROM dbo.calendar_credentials WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteCalendarCredential
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.calendar_credentials WHERE id = @Id;
END
GO

-- ========================================
-- EMAIL CONFIG
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetEmailConfig
AS
BEGIN
  SET NOCOUNT ON;
  SELECT TOP 1
    id AS Id, smtp_host AS SmtpHost, smtp_port AS SmtpPort,
    smtp_username AS SmtpUsername, smtp_password AS SmtpPassword,
    from_email AS FromEmail, from_name AS FromName,
    is_active AS IsActive, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.email_config WHERE is_active = 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateEmailConfig
  @SmtpHost NVARCHAR(255), @SmtpPort INT, @SmtpUsername NVARCHAR(255),
  @SmtpPassword NVARCHAR(255), @FromEmail NVARCHAR(255), @FromName NVARCHAR(255)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  INSERT INTO dbo.email_config
    (id, smtp_host, smtp_port, smtp_username, smtp_password, from_email, from_name, is_active, created_at, updated_at)
  VALUES (@Id, @SmtpHost, @SmtpPort, @SmtpUsername, @SmtpPassword, @FromEmail, @FromName, 1, SYSDATETIME(), SYSDATETIME());
  
  EXEC dbo.GetEmailConfig;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateEmailConfig
  @Id UNIQUEIDENTIFIER,
  @SmtpHost NVARCHAR(255) = NULL, @SmtpPort INT = NULL,
  @SmtpUsername NVARCHAR(255) = NULL, @SmtpPassword NVARCHAR(255) = NULL,
  @FromEmail NVARCHAR(255) = NULL, @FromName NVARCHAR(255) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE dbo.email_config
  SET smtp_host = COALESCE(@SmtpHost, smtp_host),
      smtp_port = COALESCE(@SmtpPort, smtp_port),
      smtp_username = COALESCE(@SmtpUsername, smtp_username),
      smtp_password = COALESCE(@SmtpPassword, smtp_password),
      from_email = COALESCE(@FromEmail, from_email),
      from_name = COALESCE(@FromName, from_name),
      updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  EXEC dbo.GetEmailConfig;
END
GO

-- ========================================
-- EMAIL TEMPLATES
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetEmailTemplates
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, name AS Name, subject AS Subject, body AS Body,
    template_type AS TemplateType, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.email_templates ORDER BY name;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetEmailTemplate
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, name AS Name, subject AS Subject, body AS Body,
    template_type AS TemplateType, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.email_templates WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateEmailTemplate
  @Name NVARCHAR(255), @Subject NVARCHAR(500), @Body NVARCHAR(MAX), @TemplateType NVARCHAR(100)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  INSERT INTO dbo.email_templates (id, name, subject, body, template_type, created_at, updated_at)
  VALUES (@Id, @Name, @Subject, @Body, @TemplateType, SYSDATETIME(), SYSDATETIME());
  
  EXEC dbo.GetEmailTemplate @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateEmailTemplate
  @Id UNIQUEIDENTIFIER,
  @Name NVARCHAR(255) = NULL, @Subject NVARCHAR(500) = NULL,
  @Body NVARCHAR(MAX) = NULL, @TemplateType NVARCHAR(100) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE dbo.email_templates
  SET name = COALESCE(@Name, name),
      subject = COALESCE(@Subject, subject),
      body = COALESCE(@Body, body),
      template_type = COALESCE(@TemplateType, template_type),
      updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  EXEC dbo.GetEmailTemplate @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteEmailTemplate
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.email_templates WHERE id = @Id;
END
GO

-- ========================================
-- USERS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetUser
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, email AS Email, first_name AS FirstName, last_name AS LastName,
    profile_image_url AS ProfileImageUrl, created_at AS CreatedAt, updated_at AS UpdatedAt,
    code AS Code, designation AS Designation, date_of_joining AS DateOfJoining,
    mobile_number AS MobileNumber, reporting_manager_id AS ReportingManagerId,
    location_id AS LocationId, company_id AS CompanyId, role AS Role,
    status AS Status, department AS Department, roles AS Roles,
    password_hash AS PasswordHash, created_by_id AS CreatedById,
    level_id AS LevelId, grade_id AS GradeId
  FROM dbo.users WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetUserByEmail
  @Email NVARCHAR(255)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, email AS Email, first_name AS FirstName, last_name AS LastName,
    profile_image_url AS ProfileImageUrl, created_at AS CreatedAt, updated_at AS UpdatedAt,
    code AS Code, designation AS Designation, date_of_joining AS DateOfJoining,
    mobile_number AS MobileNumber, reporting_manager_id AS ReportingManagerId,
    location_id AS LocationId, company_id AS CompanyId, role AS Role,
    status AS Status, department AS Department, roles AS Roles,
    password_hash AS PasswordHash, created_by_id AS CreatedById,
    level_id AS LevelId, grade_id AS GradeId
  FROM dbo.users WHERE email = @Email;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetUserByCode
  @Code NVARCHAR(100)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, email AS Email, first_name AS FirstName, last_name AS LastName,
    profile_image_url AS ProfileImageUrl, created_at AS CreatedAt, updated_at AS UpdatedAt,
    code AS Code, designation AS Designation, date_of_joining AS DateOfJoining,
    mobile_number AS MobileNumber, reporting_manager_id AS ReportingManagerId,
    location_id AS LocationId, company_id AS CompanyId, role AS Role,
    status AS Status, department AS Department, roles AS Roles,
    password_hash AS PasswordHash, created_by_id AS CreatedById,
    level_id AS LevelId, grade_id AS GradeId
  FROM dbo.users WHERE code = @Code;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetUserByMobile
  @MobileNumber NVARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, email AS Email, first_name AS FirstName, last_name AS LastName,
    profile_image_url AS ProfileImageUrl, created_at AS CreatedAt, updated_at AS UpdatedAt,
    code AS Code, designation AS Designation, date_of_joining AS DateOfJoining,
    mobile_number AS MobileNumber, reporting_manager_id AS ReportingManagerId,
    location_id AS LocationId, company_id AS CompanyId, role AS Role,
    status AS Status, department AS Department, roles AS Roles,
    password_hash AS PasswordHash, created_by_id AS CreatedById,
    level_id AS LevelId, grade_id AS GradeId
  FROM dbo.users WHERE mobile_number = @MobileNumber;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetUsers
  @Role NVARCHAR(50) = NULL,
  @Department NVARCHAR(255) = NULL,
  @Status NVARCHAR(20) = NULL,
  @CompanyId UNIQUEIDENTIFIER = NULL,
  @RequestingUserId UNIQUEIDENTIFIER = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  -- Get requesting user for security checks
  DECLARE @RequestingRole NVARCHAR(50);
  DECLARE @RequestingCompanyId UNIQUEIDENTIFIER;
  
  IF @RequestingUserId IS NOT NULL
  BEGIN
    SELECT @RequestingRole = role, @RequestingCompanyId = company_id
    FROM dbo.users WHERE id = @RequestingUserId;
  END
  
  SELECT 
    id AS Id, email AS Email, first_name AS FirstName, last_name AS LastName,
    profile_image_url AS ProfileImageUrl, created_at AS CreatedAt, updated_at AS UpdatedAt,
    code AS Code, designation AS Designation, date_of_joining AS DateOfJoining,
    mobile_number AS MobileNumber, reporting_manager_id AS ReportingManagerId,
    location_id AS LocationId, company_id AS CompanyId, role AS Role,
    status AS Status, department AS Department, roles AS Roles,
    created_by_id AS CreatedById, level_id AS LevelId, grade_id AS GradeId
  FROM dbo.users
  WHERE 1=1
    -- Company isolation for admin/hr_manager
    AND (
      @RequestingRole IS NULL 
      OR @RequestingRole NOT IN ('admin', 'hr_manager')
      OR (company_id = @RequestingCompanyId AND company_id IS NOT NULL)
    )
    -- HR Managers cannot see super_admin or admin roles
    AND (
      @RequestingRole IS NULL
      OR @RequestingRole != 'hr_manager'
      OR (role NOT IN ('super_admin', 'admin') AND (roles IS NULL OR roles NOT LIKE '%super_admin%' AND roles NOT LIKE '%admin%'))
    )
    -- Filter parameters
    AND (@Role IS NULL OR role = @Role OR roles LIKE '%' + @Role + '%')
    AND (@Department IS NULL OR department = @Department)
    AND (@Status IS NULL OR status = @Status)
    AND (@CompanyId IS NULL OR company_id = @CompanyId)
  ORDER BY first_name;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetUsersByManager
  @ManagerId UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, email AS Email, first_name AS FirstName, last_name AS LastName,
    profile_image_url AS ProfileImageUrl, created_at AS CreatedAt, updated_at AS UpdatedAt,
    code AS Code, designation AS Designation, date_of_joining AS DateOfJoining,
    mobile_number AS MobileNumber, reporting_manager_id AS ReportingManagerId,
    location_id AS LocationId, company_id AS CompanyId, role AS Role,
    status AS Status, department AS Department, roles AS Roles,
    created_by_id AS CreatedById, level_id AS LevelId, grade_id AS GradeId
  FROM dbo.users WHERE reporting_manager_id = @ManagerId;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpsertUser
  @Id UNIQUEIDENTIFIER,
  @Email NVARCHAR(255) = NULL,
  @FirstName NVARCHAR(255) = NULL,
  @LastName NVARCHAR(255) = NULL,
  @ProfileImageUrl NVARCHAR(500) = NULL,
  @Role NVARCHAR(50) = 'employee'
AS
BEGIN
  SET NOCOUNT ON;
  
  IF EXISTS (SELECT 1 FROM dbo.users WHERE id = @Id)
  BEGIN
    UPDATE dbo.users
    SET email = COALESCE(@Email, email),
        first_name = COALESCE(@FirstName, first_name),
        last_name = COALESCE(@LastName, last_name),
        profile_image_url = COALESCE(@ProfileImageUrl, profile_image_url),
        updated_at = SYSDATETIME()
    WHERE id = @Id;
  END
  ELSE
  BEGIN
    INSERT INTO dbo.users (
      id, email, first_name, last_name, profile_image_url,
      role, roles, created_at, updated_at, status
    )
    VALUES (
      @Id, @Email, @FirstName, @LastName, @ProfileImageUrl,
      @Role, '["' + @Role + '"]', SYSDATETIME(), SYSDATETIME(), 'active'
    );
  END
  
  EXEC dbo.GetUser @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateUser
  @Email NVARCHAR(255),
  @FirstName NVARCHAR(255) = NULL,
  @LastName NVARCHAR(255) = NULL,
  @Code NVARCHAR(100) = NULL,
  @Designation NVARCHAR(255) = NULL,
  @DateOfJoining DATETIME2 = NULL,
  @MobileNumber NVARCHAR(50) = NULL,
  @ReportingManagerId UNIQUEIDENTIFIER = NULL,
  @LocationId UNIQUEIDENTIFIER = NULL,
  @CompanyId UNIQUEIDENTIFIER = NULL,
  @Role NVARCHAR(50) = 'employee',
  @Status NVARCHAR(20) = 'active',
  @Department NVARCHAR(255) = NULL,
  @Roles NVARCHAR(MAX) = NULL,
  @PasswordHash NVARCHAR(255) = NULL,
  @CreatedById UNIQUEIDENTIFIER = NULL,
  @LevelId UNIQUEIDENTIFIER = NULL,
  @GradeId UNIQUEIDENTIFIER = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  SET @Roles = COALESCE(@Roles, '["' + @Role + '"]');
  
  INSERT INTO dbo.users (
    id, email, first_name, last_name, code, designation, date_of_joining,
    mobile_number, reporting_manager_id, location_id, company_id, role,
    status, department, roles, password_hash, created_by_id, level_id, grade_id,
    created_at, updated_at
  )
  VALUES (
    @Id, @Email, @FirstName, @LastName, @Code, @Designation, @DateOfJoining,
    @MobileNumber, @ReportingManagerId, @LocationId, @CompanyId, @Role,
    @Status, @Department, @Roles, @PasswordHash, @CreatedById, @LevelId, @GradeId,
    SYSDATETIME(), SYSDATETIME()
  );
  
  SELECT 
    id AS Id, email AS Email, first_name AS FirstName, last_name AS LastName,
    profile_image_url AS ProfileImageUrl, created_at AS CreatedAt, updated_at AS UpdatedAt,
    code AS Code, designation AS Designation, date_of_joining AS DateOfJoining,
    mobile_number AS MobileNumber, reporting_manager_id AS ReportingManagerId,
    location_id AS LocationId, company_id AS CompanyId, role AS Role,
    status AS Status, department AS Department, roles AS Roles,
    created_by_id AS CreatedById, level_id AS LevelId, grade_id AS GradeId
  FROM dbo.users WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateUser
  @Id UNIQUEIDENTIFIER,
  @Email NVARCHAR(255) = NULL,
  @FirstName NVARCHAR(255) = NULL,
  @LastName NVARCHAR(255) = NULL,
  @ProfileImageUrl NVARCHAR(500) = NULL,
  @Code NVARCHAR(100) = NULL,
  @Designation NVARCHAR(255) = NULL,
  @DateOfJoining DATETIME2 = NULL,
  @MobileNumber NVARCHAR(50) = NULL,
  @ReportingManagerId UNIQUEIDENTIFIER = NULL,
  @LocationId UNIQUEIDENTIFIER = NULL,
  @CompanyId UNIQUEIDENTIFIER = NULL,
  @Role NVARCHAR(50) = NULL,
  @Status NVARCHAR(20) = NULL,
  @Department NVARCHAR(255) = NULL,
  @Roles NVARCHAR(MAX) = NULL,
  @PasswordHash NVARCHAR(255) = NULL,
  @LevelId UNIQUEIDENTIFIER = NULL,
  @GradeId UNIQUEIDENTIFIER = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.users
  SET email = COALESCE(@Email, email),
      first_name = COALESCE(@FirstName, first_name),
      last_name = COALESCE(@LastName, last_name),
      profile_image_url = COALESCE(@ProfileImageUrl, profile_image_url),
      code = COALESCE(@Code, code),
      designation = COALESCE(@Designation, designation),
      date_of_joining = COALESCE(@DateOfJoining, date_of_joining),
      mobile_number = COALESCE(@MobileNumber, mobile_number),
      reporting_manager_id = COALESCE(@ReportingManagerId, reporting_manager_id),
      location_id = COALESCE(@LocationId, location_id),
      company_id = COALESCE(@CompanyId, company_id),
      role = COALESCE(@Role, role),
      status = COALESCE(@Status, status),
      department = COALESCE(@Department, department),
      roles = COALESCE(@Roles, roles),
      password_hash = COALESCE(@PasswordHash, password_hash),
      level_id = COALESCE(@LevelId, level_id),
      grade_id = COALESCE(@GradeId, grade_id),
      updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  SELECT 
    id AS Id, email AS Email, first_name AS FirstName, last_name AS LastName,
    profile_image_url AS ProfileImageUrl, created_at AS CreatedAt, updated_at AS UpdatedAt,
    code AS Code, designation AS Designation, date_of_joining AS DateOfJoining,
    mobile_number AS MobileNumber, reporting_manager_id AS ReportingManagerId,
    location_id AS LocationId, company_id AS CompanyId, role AS Role,
    status AS Status, department AS Department, roles AS Roles,
    created_by_id AS CreatedById, level_id AS LevelId, grade_id AS GradeId
  FROM dbo.users WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteUser
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.users WHERE id = @Id;
END
GO

-- ========================================
-- COMPANIES
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetCompanies
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, name AS Name, address AS Address, client_contact AS ClientContact,
    email AS Email, contact_number AS ContactNumber, gst_number AS GstNumber,
    logo_url AS LogoUrl, status AS Status, created_at AS CreatedAt,
    updated_at AS UpdatedAt, url AS Url, company_url AS CompanyUrl
  FROM dbo.companies ORDER BY name;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetCompany
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, name AS Name, address AS Address, client_contact AS ClientContact,
    email AS Email, contact_number AS ContactNumber, gst_number AS GstNumber,
    logo_url AS LogoUrl, status AS Status, created_at AS CreatedAt,
    updated_at AS UpdatedAt, url AS Url, company_url AS CompanyUrl
  FROM dbo.companies WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetCompanyByUrl
  @CompanyUrl NVARCHAR(500)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, name AS Name, address AS Address, client_contact AS ClientContact,
    email AS Email, contact_number AS ContactNumber, gst_number AS GstNumber,
    logo_url AS LogoUrl, status AS Status, created_at AS CreatedAt,
    updated_at AS UpdatedAt, url AS Url, company_url AS CompanyUrl
  FROM dbo.companies WHERE company_url = @CompanyUrl;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateCompany
  @Name NVARCHAR(255),
  @Address NVARCHAR(MAX) = NULL,
  @ClientContact NVARCHAR(255) = NULL,
  @Email NVARCHAR(255) = NULL,
  @ContactNumber NVARCHAR(50) = NULL,
  @GstNumber NVARCHAR(50) = NULL,
  @LogoUrl NVARCHAR(500) = NULL,
  @Status NVARCHAR(20) = 'active',
  @Url NVARCHAR(500) = NULL,
  @CompanyUrl NVARCHAR(500) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.companies (
    id, name, address, client_contact, email, contact_number,
    gst_number, logo_url, status, url, company_url, created_at, updated_at
  )
  VALUES (
    @Id, @Name, @Address, @ClientContact, @Email, @ContactNumber,
    @GstNumber, @LogoUrl, @Status, @Url, @CompanyUrl, SYSDATETIME(), SYSDATETIME()
  );
  
  EXEC dbo.GetCompany @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateCompany
  @Id UNIQUEIDENTIFIER,
  @Name NVARCHAR(255) = NULL,
  @Address NVARCHAR(MAX) = NULL,
  @ClientContact NVARCHAR(255) = NULL,
  @Email NVARCHAR(255) = NULL,
  @ContactNumber NVARCHAR(50) = NULL,
  @GstNumber NVARCHAR(50) = NULL,
  @LogoUrl NVARCHAR(500) = NULL,
  @Status NVARCHAR(20) = NULL,
  @Url NVARCHAR(500) = NULL,
  @CompanyUrl NVARCHAR(500) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.companies
  SET name = COALESCE(@Name, name),
      address = COALESCE(@Address, address),
      client_contact = COALESCE(@ClientContact, client_contact),
      email = COALESCE(@Email, email),
      contact_number = COALESCE(@ContactNumber, contact_number),
      gst_number = COALESCE(@GstNumber, gst_number),
      logo_url = COALESCE(@LogoUrl, logo_url),
      status = COALESCE(@Status, status),
      url = COALESCE(@Url, url),
      company_url = COALESCE(@CompanyUrl, company_url),
      updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  EXEC dbo.GetCompany @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteCompany
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.companies WHERE id = @Id;
END
GO

-- ========================================
-- LOCATIONS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetLocations
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, name AS Name, state AS State,
    country AS Country, status AS Status, created_at AS CreatedAt,
    updated_at AS UpdatedAt
  FROM dbo.locations ORDER BY name;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetLocation
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, name AS Name, state AS State,
    country AS Country, status AS Status, created_at AS CreatedAt,
    updated_at AS UpdatedAt
  FROM dbo.locations WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateLocation
  @Code NVARCHAR(100),
  @Name NVARCHAR(255),
  @State NVARCHAR(100) = NULL,
  @Country NVARCHAR(100) = NULL,
  @Status NVARCHAR(20) = 'active'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.locations (id, code, name, state, country, status, created_at, updated_at)
  VALUES (@Id, @Code, @Name, @State, @Country, @Status, SYSDATETIME(), SYSDATETIME());
  
  EXEC dbo.GetLocation @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateLocation
  @Id UNIQUEIDENTIFIER,
  @Code NVARCHAR(100) = NULL,
  @Name NVARCHAR(255) = NULL,
  @State NVARCHAR(100) = NULL,
  @Country NVARCHAR(100) = NULL,
  @Status NVARCHAR(20) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.locations
  SET code = COALESCE(@Code, code),
      name = COALESCE(@Name, name),
      state = COALESCE(@State, state),
      country = COALESCE(@Country, country),
      status = COALESCE(@Status, status),
      updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  EXEC dbo.GetLocation @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteLocation
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.locations WHERE id = @Id;
END
GO

-- Continue in next file due to length...
PRINT 'Part 1 of SPs created successfully - Core entities (Calendar, Email, Users, Companies, Locations)';
GO
