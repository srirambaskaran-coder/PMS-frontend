-- ========================================
-- STORED PROCEDURES PART 2
-- Levels, Grades, Departments, Cycles, Frequencies, Calendars
-- ========================================

USE [YourDatabaseName];
GO

-- ========================================
-- LEVELS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetLevels
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, description AS Description,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById
  FROM dbo.levels
  WHERE created_by_id = @CreatedById AND status = 'active'
  ORDER BY code;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetLevel
  @Id UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, description AS Description,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById
  FROM dbo.levels
  WHERE id = @Id AND created_by_id = @CreatedById;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateLevel
  @Code NVARCHAR(100),
  @Description NVARCHAR(MAX),
  @CreatedById UNIQUEIDENTIFIER,
  @Status NVARCHAR(20) = 'active'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.levels (id, code, description, status, created_by_id, created_at, updated_at)
  VALUES (@Id, @Code, @Description, @Status, @CreatedById, SYSDATETIME(), SYSDATETIME());
  
  EXEC dbo.GetLevel @Id, @CreatedById;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateLevel
  @Id UNIQUEIDENTIFIER,
  @Code NVARCHAR(100) = NULL,
  @Description NVARCHAR(MAX) = NULL,
  @Status NVARCHAR(20) = NULL,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.levels
  SET code = COALESCE(@Code, code),
      description = COALESCE(@Description, description),
      status = COALESCE(@Status, status),
      updated_at = SYSDATETIME()
  WHERE id = @Id AND created_by_id = @CreatedById;
  
  EXEC dbo.GetLevel @Id, @CreatedById;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteLevel
  @Id UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.levels WHERE id = @Id AND created_by_id = @CreatedById;
END
GO

-- ========================================
-- GRADES
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetGrades
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, description AS Description,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById
  FROM dbo.grades
  WHERE created_by_id = @CreatedById AND status = 'active'
  ORDER BY code;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetGrade
  @Id UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, description AS Description,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById
  FROM dbo.grades
  WHERE id = @Id AND created_by_id = @CreatedById;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateGrade
  @Code NVARCHAR(100),
  @Description NVARCHAR(MAX),
  @CreatedById UNIQUEIDENTIFIER,
  @Status NVARCHAR(20) = 'active'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.grades (id, code, description, status, created_by_id, created_at, updated_at)
  VALUES (@Id, @Code, @Description, @Status, @CreatedById, SYSDATETIME(), SYSDATETIME());
  
  EXEC dbo.GetGrade @Id, @CreatedById;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateGrade
  @Id UNIQUEIDENTIFIER,
  @Code NVARCHAR(100) = NULL,
  @Description NVARCHAR(MAX) = NULL,
  @Status NVARCHAR(20) = NULL,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.grades
  SET code = COALESCE(@Code, code),
      description = COALESCE(@Description, description),
      status = COALESCE(@Status, status),
      updated_at = SYSDATETIME()
  WHERE id = @Id AND created_by_id = @CreatedById;
  
  EXEC dbo.GetGrade @Id, @CreatedById;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteGrade
  @Id UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.grades WHERE id = @Id AND created_by_id = @CreatedById;
END
GO

-- ========================================
-- DEPARTMENTS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetDepartments
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, description AS Description,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById
  FROM dbo.departments
  WHERE created_by_id = @CreatedById AND status = 'active'
  ORDER BY code;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetDepartment
  @Id UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, description AS Description,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById
  FROM dbo.departments
  WHERE id = @Id AND created_by_id = @CreatedById;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateDepartment
  @Code NVARCHAR(100),
  @Description NVARCHAR(MAX),
  @CreatedById UNIQUEIDENTIFIER,
  @Status NVARCHAR(20) = 'active'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.departments (id, code, description, status, created_by_id, created_at, updated_at)
  VALUES (@Id, @Code, @Description, @Status, @CreatedById, SYSDATETIME(), SYSDATETIME());
  
  EXEC dbo.GetDepartment @Id, @CreatedById;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateDepartment
  @Id UNIQUEIDENTIFIER,
  @Code NVARCHAR(100) = NULL,
  @Description NVARCHAR(MAX) = NULL,
  @Status NVARCHAR(20) = NULL,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.departments
  SET code = COALESCE(@Code, code),
      description = COALESCE(@Description, description),
      status = COALESCE(@Status, status),
      updated_at = SYSDATETIME()
  WHERE id = @Id AND created_by_id = @CreatedById;
  
  EXEC dbo.GetDepartment @Id, @CreatedById;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteDepartment
  @Id UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.departments WHERE id = @Id AND created_by_id = @CreatedById;
END
GO

-- ========================================
-- APPRAISAL CYCLES
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetAppraisalCycles
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, description AS Description,
    from_date AS FromDate, to_date AS ToDate,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById
  FROM dbo.appraisal_cycles
  WHERE created_by_id = @CreatedById AND status = 'active'
  ORDER BY code;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetAllAppraisalCycles
  @CompanyId UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    ac.id AS Id, ac.code AS Code, ac.description AS Description,
    ac.from_date AS FromDate, ac.to_date AS ToDate,
    ac.status AS Status, ac.created_at AS CreatedAt, ac.updated_at AS UpdatedAt,
    ac.created_by_id AS CreatedById
  FROM dbo.appraisal_cycles ac
  INNER JOIN dbo.users u ON ac.created_by_id = u.id
  WHERE u.company_id = @CompanyId AND ac.status = 'active'
  ORDER BY ac.code;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetAppraisalCycle
  @Id UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER = NULL
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, description AS Description,
    from_date AS FromDate, to_date AS ToDate,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById
  FROM dbo.appraisal_cycles
  WHERE id = @Id AND (@CreatedById IS NULL OR created_by_id = @CreatedById);
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateAppraisalCycle
  @Code NVARCHAR(100),
  @Description NVARCHAR(MAX),
  @FromDate DATETIME2,
  @ToDate DATETIME2,
  @CreatedById UNIQUEIDENTIFIER,
  @Status NVARCHAR(20) = 'active'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.appraisal_cycles (id, code, description, from_date, to_date, status, created_by_id, created_at, updated_at)
  VALUES (@Id, @Code, @Description, @FromDate, @ToDate, @Status, @CreatedById, SYSDATETIME(), SYSDATETIME());
  
  EXEC dbo.GetAppraisalCycle @Id, @CreatedById;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateAppraisalCycle
  @Id UNIQUEIDENTIFIER,
  @Code NVARCHAR(100) = NULL,
  @Description NVARCHAR(MAX) = NULL,
  @FromDate DATETIME2 = NULL,
  @ToDate DATETIME2 = NULL,
  @Status NVARCHAR(20) = NULL,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.appraisal_cycles
  SET code = COALESCE(@Code, code),
      description = COALESCE(@Description, description),
      from_date = COALESCE(@FromDate, from_date),
      to_date = COALESCE(@ToDate, to_date),
      status = COALESCE(@Status, status),
      updated_at = SYSDATETIME()
  WHERE id = @Id AND created_by_id = @CreatedById;
  
  EXEC dbo.GetAppraisalCycle @Id, @CreatedById;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteAppraisalCycle
  @Id UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.appraisal_cycles WHERE id = @Id AND created_by_id = @CreatedById;
END
GO

-- ========================================
-- REVIEW FREQUENCIES
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetReviewFrequencies
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, description AS Description,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById
  FROM dbo.review_frequencies
  WHERE created_by_id = @CreatedById AND status = 'active'
  ORDER BY code;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetReviewFrequency
  @Id UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, description AS Description,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById
  FROM dbo.review_frequencies
  WHERE id = @Id AND created_by_id = @CreatedById;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateReviewFrequency
  @Code NVARCHAR(100),
  @Description NVARCHAR(MAX),
  @CreatedById UNIQUEIDENTIFIER,
  @Status NVARCHAR(20) = 'active'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.review_frequencies (id, code, description, status, created_by_id, created_at, updated_at)
  VALUES (@Id, @Code, @Description, @Status, @CreatedById, SYSDATETIME(), SYSDATETIME());
  
  EXEC dbo.GetReviewFrequency @Id, @CreatedById;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateReviewFrequency
  @Id UNIQUEIDENTIFIER,
  @Code NVARCHAR(100) = NULL,
  @Description NVARCHAR(MAX) = NULL,
  @Status NVARCHAR(20) = NULL,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.review_frequencies
  SET code = COALESCE(@Code, code),
      description = COALESCE(@Description, description),
      status = COALESCE(@Status, status),
      updated_at = SYSDATETIME()
  WHERE id = @Id AND created_by_id = @CreatedById;
  
  EXEC dbo.GetReviewFrequency @Id, @CreatedById;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteReviewFrequency
  @Id UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.review_frequencies WHERE id = @Id AND created_by_id = @CreatedById;
END
GO

-- ========================================
-- FREQUENCY CALENDARS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetFrequencyCalendars
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, description AS Description,
    appraisal_cycle_id AS AppraisalCycleId,
    review_frequency_id AS ReviewFrequencyId,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById
  FROM dbo.frequency_calendars
  WHERE created_by_id = @CreatedById AND status = 'active'
  ORDER BY code;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetAllFrequencyCalendars
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, description AS Description,
    appraisal_cycle_id AS AppraisalCycleId,
    review_frequency_id AS ReviewFrequencyId,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById
  FROM dbo.frequency_calendars
  WHERE status = 'active'
  ORDER BY code;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetFrequencyCalendar
  @Id UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER = NULL
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, description AS Description,
    appraisal_cycle_id AS AppraisalCycleId,
    review_frequency_id AS ReviewFrequencyId,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById
  FROM dbo.frequency_calendars
  WHERE id = @Id AND (@CreatedById IS NULL OR created_by_id = @CreatedById);
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateFrequencyCalendar
  @Code NVARCHAR(100),
  @Description NVARCHAR(MAX),
  @AppraisalCycleId UNIQUEIDENTIFIER,
  @ReviewFrequencyId UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER,
  @Status NVARCHAR(20) = 'active'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.frequency_calendars
    (id, code, description, appraisal_cycle_id, review_frequency_id, status, created_by_id, created_at, updated_at)
  VALUES
    (@Id, @Code, @Description, @AppraisalCycleId, @ReviewFrequencyId, @Status, @CreatedById, SYSDATETIME(), SYSDATETIME());
  
  EXEC dbo.GetFrequencyCalendar @Id, @CreatedById;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateFrequencyCalendar
  @Id UNIQUEIDENTIFIER,
  @Code NVARCHAR(100) = NULL,
  @Description NVARCHAR(MAX) = NULL,
  @AppraisalCycleId UNIQUEIDENTIFIER = NULL,
  @ReviewFrequencyId UNIQUEIDENTIFIER = NULL,
  @Status NVARCHAR(20) = NULL,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.frequency_calendars
  SET code = COALESCE(@Code, code),
      description = COALESCE(@Description, description),
      appraisal_cycle_id = COALESCE(@AppraisalCycleId, appraisal_cycle_id),
      review_frequency_id = COALESCE(@ReviewFrequencyId, review_frequency_id),
      status = COALESCE(@Status, status),
      updated_at = SYSDATETIME()
  WHERE id = @Id AND created_by_id = @CreatedById;
  
  EXEC dbo.GetFrequencyCalendar @Id, @CreatedById;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteFrequencyCalendar
  @Id UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.frequency_calendars WHERE id = @Id AND created_by_id = @CreatedById;
END
GO

-- ========================================
-- FREQUENCY CALENDAR DETAILS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetFrequencyCalendarDetails
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    fcd.id AS Id, fcd.frequency_calendar_id AS FrequencyCalendarId,
    fcd.display_name AS DisplayName, fcd.start_date AS StartDate,
    fcd.end_date AS EndDate, fcd.status AS Status,
    fcd.created_at AS CreatedAt, fcd.updated_at AS UpdatedAt,
    fcd.created_by_id AS CreatedById
  FROM dbo.frequency_calendar_details fcd
  INNER JOIN dbo.frequency_calendars fc ON fcd.frequency_calendar_id = fc.id
  WHERE fc.created_by_id = @CreatedById AND fcd.status = 'active'
  ORDER BY fcd.start_date;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetAllFrequencyCalendarDetails
  @CompanyId UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    fcd.id AS Id, fcd.frequency_calendar_id AS FrequencyCalendarId,
    fcd.display_name AS DisplayName, fcd.start_date AS StartDate,
    fcd.end_date AS EndDate, fcd.status AS Status,
    fcd.created_at AS CreatedAt, fcd.updated_at AS UpdatedAt,
    fcd.created_by_id AS CreatedById
  FROM dbo.frequency_calendar_details fcd
  INNER JOIN dbo.frequency_calendars fc ON fcd.frequency_calendar_id = fc.id
  INNER JOIN dbo.users u ON fc.created_by_id = u.id
  WHERE u.company_id = @CompanyId AND fcd.status = 'active'
  ORDER BY fcd.start_date;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetFrequencyCalendarDetailsByCalendarId
  @CalendarId UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, frequency_calendar_id AS FrequencyCalendarId,
    display_name AS DisplayName, start_date AS StartDate,
    end_date AS EndDate, status AS Status,
    created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById
  FROM dbo.frequency_calendar_details
  WHERE frequency_calendar_id = @CalendarId AND status = 'active'
  ORDER BY start_date;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetFrequencyCalendarDetail
  @Id UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER = NULL
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    fcd.id AS Id, fcd.frequency_calendar_id AS FrequencyCalendarId,
    fcd.display_name AS DisplayName, fcd.start_date AS StartDate,
    fcd.end_date AS EndDate, fcd.status AS Status,
    fcd.created_at AS CreatedAt, fcd.updated_at AS UpdatedAt,
    fcd.created_by_id AS CreatedById
  FROM dbo.frequency_calendar_details fcd
  INNER JOIN dbo.frequency_calendars fc ON fcd.frequency_calendar_id = fc.id
  WHERE fcd.id = @Id AND (@CreatedById IS NULL OR fc.created_by_id = @CreatedById);
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateFrequencyCalendarDetails
  @FrequencyCalendarId UNIQUEIDENTIFIER,
  @DisplayName NVARCHAR(255),
  @StartDate DATETIME2,
  @EndDate DATETIME2,
  @CreatedById UNIQUEIDENTIFIER,
  @Status NVARCHAR(20) = 'active'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.frequency_calendar_details
    (id, frequency_calendar_id, display_name, start_date, end_date, status, created_by_id, created_at, updated_at)
  VALUES
    (@Id, @FrequencyCalendarId, @DisplayName, @StartDate, @EndDate, @Status, @CreatedById, SYSDATETIME(), SYSDATETIME());
  
  SELECT 
    id AS Id, frequency_calendar_id AS FrequencyCalendarId,
    display_name AS DisplayName, start_date AS StartDate,
    end_date AS EndDate, status AS Status,
    created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById
  FROM dbo.frequency_calendar_details WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateFrequencyCalendarDetails
  @Id UNIQUEIDENTIFIER,
  @FrequencyCalendarId UNIQUEIDENTIFIER = NULL,
  @DisplayName NVARCHAR(255) = NULL,
  @StartDate DATETIME2 = NULL,
  @EndDate DATETIME2 = NULL,
  @Status NVARCHAR(20) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.frequency_calendar_details
  SET frequency_calendar_id = COALESCE(@FrequencyCalendarId, frequency_calendar_id),
      display_name = COALESCE(@DisplayName, display_name),
      start_date = COALESCE(@StartDate, start_date),
      end_date = COALESCE(@EndDate, end_date),
      status = COALESCE(@Status, status),
      updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  SELECT 
    id AS Id, frequency_calendar_id AS FrequencyCalendarId,
    display_name AS DisplayName, start_date AS StartDate,
    end_date AS EndDate, status AS Status,
    created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById
  FROM dbo.frequency_calendar_details WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteFrequencyCalendarDetails
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.frequency_calendar_details WHERE id = @Id;
END
GO

PRINT 'Part 2 of SPs created successfully - Levels, Grades, Departments, Cycles, Frequencies, Calendars';
GO
