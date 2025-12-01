-- ========================================
-- CORRECTED STORED PROCEDURES PART 4
-- Based on actual MSSQL schema from Complete_query.sql
-- Appraisal Groups, Initiated Appraisals, Tasks, Publish Questionnaires
-- ========================================

USE [YourDatabaseName];
GO

-- ========================================
-- APPRAISAL GROUPS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetAppraisalGroups
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, name AS Name, description AS Description,
    created_by_id AS CreatedById, company_id AS CompanyId,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.appraisal_groups
  WHERE created_by_id = @CreatedById
  ORDER BY created_at DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetAppraisalGroup
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, name AS Name, description AS Description,
    created_by_id AS CreatedById, company_id AS CompanyId,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.appraisal_groups WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateAppraisalGroup
  @Name NVARCHAR(255),
  @Description NVARCHAR(MAX) = NULL,
  @CreatedById UNIQUEIDENTIFIER,
  @CompanyId UNIQUEIDENTIFIER = NULL,
  @Status NVARCHAR(20) = 'active'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.appraisal_groups
    (id, name, description, created_by_id, company_id, status, created_at, updated_at)
  VALUES 
    (@Id, @Name, @Description, @CreatedById, @CompanyId, @Status, SYSDATETIME(), SYSDATETIME());
    
  SELECT 
    id AS Id, name AS Name, description AS Description,
    created_by_id AS CreatedById, company_id AS CompanyId,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.appraisal_groups WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateAppraisalGroup
  @Id UNIQUEIDENTIFIER,
  @Name NVARCHAR(255) = NULL,
  @Description NVARCHAR(MAX) = NULL,
  @Status NVARCHAR(20) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.appraisal_groups 
  SET 
    name = COALESCE(@Name, name),
    description = COALESCE(@Description, description),
    status = COALESCE(@Status, status),
    updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  SELECT 
    id AS Id, name AS Name, description AS Description,
    created_by_id AS CreatedById, company_id AS CompanyId,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.appraisal_groups WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteAppraisalGroup
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.appraisal_groups WHERE id = @Id;
  SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- ========================================
-- APPRAISAL GROUP MEMBERS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetAppraisalGroupMembers
  @AppraisalGroupId UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    agm.id AS Id,
    agm.appraisal_group_id AS AppraisalGroupId,
    agm.user_id AS UserId,
    agm.added_by_id AS AddedById,
    agm.added_at AS AddedAt,
    u.first_name AS FirstName,
    u.last_name AS LastName,
    u.email AS Email,
    u.designation AS Designation,
    u.department AS Department
  FROM dbo.appraisal_group_members agm
  INNER JOIN dbo.users u ON agm.user_id = u.id
  INNER JOIN dbo.appraisal_groups ag ON agm.appraisal_group_id = ag.id
  WHERE agm.appraisal_group_id = @AppraisalGroupId 
    AND ag.created_by_id = @CreatedById
  ORDER BY u.first_name, u.last_name;
END
GO

CREATE OR ALTER PROCEDURE dbo.AddAppraisalGroupMember
  @AppraisalGroupId UNIQUEIDENTIFIER,
  @UserId UNIQUEIDENTIFIER,
  @AddedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  
  -- Check if member already exists
  IF EXISTS (SELECT 1 FROM dbo.appraisal_group_members 
             WHERE appraisal_group_id = @AppraisalGroupId AND user_id = @UserId)
  BEGIN
    RAISERROR('User is already a member of this appraisal group', 16, 1);
    RETURN;
  END
  
  -- Check if user exists
  IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE id = @UserId)
  BEGIN
    RAISERROR('User not found', 16, 1);
    RETURN;
  END
  
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.appraisal_group_members
    (id, appraisal_group_id, user_id, added_by_id, added_at)
  VALUES 
    (@Id, @AppraisalGroupId, @UserId, @AddedById, SYSDATETIME());
    
  SELECT 
    id AS Id, appraisal_group_id AS AppraisalGroupId,
    user_id AS UserId, added_by_id AS AddedById, added_at AS AddedAt
  FROM dbo.appraisal_group_members WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.RemoveAppraisalGroupMember
  @AppraisalGroupId UNIQUEIDENTIFIER,
  @UserId UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.appraisal_group_members 
  WHERE appraisal_group_id = @AppraisalGroupId AND user_id = @UserId;
  SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- ========================================
-- INITIATED APPRAISALS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.CreateInitiatedAppraisal
  @AppraisalGroupId UNIQUEIDENTIFIER,
  @AppraisalType NVARCHAR(50),
  @QuestionnaireTemplateId UNIQUEIDENTIFIER = NULL,
  @DocumentUrl NVARCHAR(500) = NULL,
  @FrequencyCalendarId UNIQUEIDENTIFIER = NULL,
  @DaysToInitiate INT = 0,
  @DaysToClose INT = 30,
  @NumberOfReminders INT = 3,
  @ExcludeTenureLessThanYear BIT = 0,
  @ExcludedEmployeeIds NVARCHAR(MAX) = NULL,
  @Status NVARCHAR(20) = 'draft',
  @MakePublic BIT = 0,
  @PublishType NVARCHAR(20) = 'now',
  @CreatedById UNIQUEIDENTIFIER,
  @QuestionnaireTemplateIds NVARCHAR(MAX) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.initiated_appraisals
    (id, appraisal_group_id, appraisal_type, questionnaire_template_id, document_url,
     frequency_calendar_id, days_to_initiate, days_to_close, number_of_reminders,
     exclude_tenure_less_than_year, excluded_employee_ids, status, make_public,
     publish_type, created_by_id, questionnaire_template_ids, created_at, updated_at)
  VALUES 
    (@Id, @AppraisalGroupId, @AppraisalType, @QuestionnaireTemplateId, @DocumentUrl,
     @FrequencyCalendarId, @DaysToInitiate, @DaysToClose, @NumberOfReminders,
     @ExcludeTenureLessThanYear, @ExcludedEmployeeIds, @Status, @MakePublic,
     @PublishType, @CreatedById, @QuestionnaireTemplateIds, SYSDATETIME(), SYSDATETIME());
    
  SELECT 
    id AS Id, appraisal_group_id AS AppraisalGroupId, appraisal_type AS AppraisalType,
    questionnaire_template_id AS QuestionnaireTemplateId, document_url AS DocumentUrl,
    frequency_calendar_id AS FrequencyCalendarId, days_to_initiate AS DaysToInitiate,
    days_to_close AS DaysToClose, number_of_reminders AS NumberOfReminders,
    exclude_tenure_less_than_year AS ExcludeTenureLessThanYear,
    excluded_employee_ids AS ExcludedEmployeeIds, status AS Status,
    make_public AS MakePublic, publish_type AS PublishType,
    created_by_id AS CreatedById, questionnaire_template_ids AS QuestionnaireTemplateIds,
    created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.initiated_appraisals WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetInitiatedAppraisal
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, appraisal_group_id AS AppraisalGroupId, appraisal_type AS AppraisalType,
    questionnaire_template_id AS QuestionnaireTemplateId, document_url AS DocumentUrl,
    frequency_calendar_id AS FrequencyCalendarId, days_to_initiate AS DaysToInitiate,
    days_to_close AS DaysToClose, number_of_reminders AS NumberOfReminders,
    exclude_tenure_less_than_year AS ExcludeTenureLessThanYear,
    excluded_employee_ids AS ExcludedEmployeeIds, status AS Status,
    make_public AS MakePublic, publish_type AS PublishType,
    created_by_id AS CreatedById, questionnaire_template_ids AS QuestionnaireTemplateIds,
    created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.initiated_appraisals WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetInitiatedAppraisals
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    ia.id AS Id, ia.appraisal_group_id AS AppraisalGroupId, ia.appraisal_type AS AppraisalType,
    ia.questionnaire_template_id AS QuestionnaireTemplateId, ia.document_url AS DocumentUrl,
    ia.frequency_calendar_id AS FrequencyCalendarId, ia.days_to_initiate AS DaysToInitiate,
    ia.days_to_close AS DaysToClose, ia.number_of_reminders AS NumberOfReminders,
    ia.exclude_tenure_less_than_year AS ExcludeTenureLessThanYear,
    ia.excluded_employee_ids AS ExcludedEmployeeIds, ia.status AS Status,
    ia.make_public AS MakePublic, ia.publish_type AS PublishType,
    ia.created_by_id AS CreatedById, ia.questionnaire_template_ids AS QuestionnaireTemplateIds,
    ia.created_at AS CreatedAt, ia.updated_at AS UpdatedAt,
    ag.name AS AppraisalGroupName
  FROM dbo.initiated_appraisals ia
  INNER JOIN dbo.appraisal_groups ag ON ia.appraisal_group_id = ag.id
  WHERE ia.created_by_id = @CreatedById
  ORDER BY ia.created_at DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateInitiatedAppraisalStatus
  @Id UNIQUEIDENTIFIER,
  @Status NVARCHAR(20)
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.initiated_appraisals 
  SET status = @Status, updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- ========================================
-- INITIATED APPRAISAL DETAIL TIMINGS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.CreateInitiatedAppraisalDetailTiming
  @InitiatedAppraisalId UNIQUEIDENTIFIER,
  @FrequencyCalendarDetailId UNIQUEIDENTIFIER,
  @DaysToInitiate INT = 0,
  @DaysToClose INT = 30,
  @NumberOfReminders INT = 3
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.initiated_appraisal_detail_timings
    (id, initiated_appraisal_id, frequency_calendar_detail_id, 
     days_to_initiate, days_to_close, number_of_reminders, created_at, updated_at)
  VALUES 
    (@Id, @InitiatedAppraisalId, @FrequencyCalendarDetailId,
     @DaysToInitiate, @DaysToClose, @NumberOfReminders, SYSDATETIME(), SYSDATETIME());
    
  SELECT 
    id AS Id, initiated_appraisal_id AS InitiatedAppraisalId,
    frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    days_to_initiate AS DaysToInitiate, days_to_close AS DaysToClose,
    number_of_reminders AS NumberOfReminders,
    created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.initiated_appraisal_detail_timings WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetInitiatedAppraisalDetailTimings
  @InitiatedAppraisalId UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, initiated_appraisal_id AS InitiatedAppraisalId,
    frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    days_to_initiate AS DaysToInitiate, days_to_close AS DaysToClose,
    number_of_reminders AS NumberOfReminders,
    created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.initiated_appraisal_detail_timings 
  WHERE initiated_appraisal_id = @InitiatedAppraisalId
  ORDER BY days_to_initiate;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateInitiatedAppraisalDetailTimingStatus
  @Id UNIQUEIDENTIFIER,
  @DaysToInitiate INT = NULL,
  @DaysToClose INT = NULL,
  @NumberOfReminders INT = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.initiated_appraisal_detail_timings 
  SET 
    days_to_initiate = COALESCE(@DaysToInitiate, days_to_initiate),
    days_to_close = COALESCE(@DaysToClose, days_to_close),
    number_of_reminders = COALESCE(@NumberOfReminders, number_of_reminders),
    updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- ========================================
-- SCHEDULED APPRAISAL TASKS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.CreateScheduledAppraisalTask
  @InitiatedAppraisalId UNIQUEIDENTIFIER,
  @FrequencyCalendarDetailId UNIQUEIDENTIFIER,
  @ScheduledDate DATETIME2,
  @Status NVARCHAR(50) = 'pending'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.scheduled_appraisal_tasks
    (id, initiated_appraisal_id, frequency_calendar_detail_id, 
     scheduled_date, status, created_at, updated_at)
  VALUES 
    (@Id, @InitiatedAppraisalId, @FrequencyCalendarDetailId,
     @ScheduledDate, @Status, SYSDATETIME(), SYSDATETIME());
    
  SELECT 
    id AS Id, initiated_appraisal_id AS InitiatedAppraisalId,
    frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    scheduled_date AS ScheduledDate, status AS Status,
    executed_at AS ExecutedAt, error AS Error,
    created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.scheduled_appraisal_tasks WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetPendingScheduledTasks
  @MaxTasks INT = 100
AS
BEGIN
  SET NOCOUNT ON;
  SELECT TOP (@MaxTasks)
    id AS Id, initiated_appraisal_id AS InitiatedAppraisalId,
    frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    scheduled_date AS ScheduledDate, status AS Status,
    executed_at AS ExecutedAt, error AS Error,
    created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.scheduled_appraisal_tasks 
  WHERE status = 'pending' AND scheduled_date <= SYSDATETIME()
  ORDER BY scheduled_date ASC;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateScheduledTaskStatus
  @Id UNIQUEIDENTIFIER,
  @Status NVARCHAR(50),
  @Error NVARCHAR(MAX) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.scheduled_appraisal_tasks 
  SET 
    status = @Status,
    executed_at = CASE WHEN @Status IN ('completed', 'failed') THEN SYSDATETIME() ELSE executed_at END,
    error = @Error,
    updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  SELECT @@ROWCOUNT AS RowsAffected;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetScheduledTasksByAppraisal
  @InitiatedAppraisalId UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, initiated_appraisal_id AS InitiatedAppraisalId,
    frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    scheduled_date AS ScheduledDate, status AS Status,
    executed_at AS ExecutedAt, error AS Error,
    created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.scheduled_appraisal_tasks 
  WHERE initiated_appraisal_id = @InitiatedAppraisalId
  ORDER BY scheduled_date DESC;
END
GO

-- ========================================
-- PUBLISH QUESTIONNAIRES
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetPublishQuestionnaires
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, display_name AS DisplayName,
    template_id AS TemplateId, frequency_calendar_id AS FrequencyCalendarId,
    status AS Status, publish_type AS PublishType,
    created_by_id AS CreatedById, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.publish_questionnaires
  WHERE created_by_id = @CreatedById
  ORDER BY created_at DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetPublishQuestionnaire
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, code AS Code, display_name AS DisplayName,
    template_id AS TemplateId, frequency_calendar_id AS FrequencyCalendarId,
    status AS Status, publish_type AS PublishType,
    created_by_id AS CreatedById, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.publish_questionnaires WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreatePublishQuestionnaire
  @Code NVARCHAR(100),
  @DisplayName NVARCHAR(255),
  @TemplateId UNIQUEIDENTIFIER,
  @FrequencyCalendarId UNIQUEIDENTIFIER = NULL,
  @Status NVARCHAR(20) = 'active',
  @PublishType NVARCHAR(20) = 'now',
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.publish_questionnaires
    (id, code, display_name, template_id, frequency_calendar_id,
     status, publish_type, created_by_id, created_at, updated_at)
  VALUES 
    (@Id, @Code, @DisplayName, @TemplateId, @FrequencyCalendarId,
     @Status, @PublishType, @CreatedById, SYSDATETIME(), SYSDATETIME());
     
  SELECT 
    id AS Id, code AS Code, display_name AS DisplayName,
    template_id AS TemplateId, frequency_calendar_id AS FrequencyCalendarId,
    status AS Status, publish_type AS PublishType,
    created_by_id AS CreatedById, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.publish_questionnaires WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdatePublishQuestionnaire
  @Id UNIQUEIDENTIFIER,
  @Status NVARCHAR(20) = NULL,
  @FrequencyCalendarId UNIQUEIDENTIFIER = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.publish_questionnaires 
  SET 
    status = COALESCE(@Status, status),
    frequency_calendar_id = COALESCE(@FrequencyCalendarId, frequency_calendar_id),
    updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  SELECT 
    id AS Id, code AS Code, display_name AS DisplayName,
    template_id AS TemplateId, frequency_calendar_id AS FrequencyCalendarId,
    status AS Status, publish_type AS PublishType,
    created_by_id AS CreatedById, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.publish_questionnaires WHERE id = @Id;
END
GO

PRINT 'Corrected Part 4 of SPs created successfully - Based on actual MSSQL schema';
PRINT 'All column names match Complete_query.sql structure';