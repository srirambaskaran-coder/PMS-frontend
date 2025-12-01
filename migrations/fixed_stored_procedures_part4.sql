-- ========================================
-- FIXED STORED PROCEDURES PART 4
-- Appraisal Groups, Initiated Appraisals, Tasks, Publish Questionnaires
-- Fixed column names to match actual database schema
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
  @Description NTEXT = NULL,
  @CreatedById UNIQUEIDENTIFIER,
  @CompanyId UNIQUEIDENTIFIER = NULL,
  @Status NVARCHAR(50) = 'active'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.appraisal_groups
    (id, name, description, created_by_id, company_id, status, created_at, updated_at)
  VALUES 
    (@Id, @Name, @Description, @CreatedById, @CompanyId, @Status, GETDATE(), GETDATE());
    
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
  @Description NTEXT = NULL,
  @Status NVARCHAR(50) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.appraisal_groups 
  SET 
    name = COALESCE(@Name, name),
    description = COALESCE(@Description, description),
    status = COALESCE(@Status, status),
    updated_at = GETDATE()
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
    (@Id, @AppraisalGroupId, @UserId, @AddedById, GETDATE());
    
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
  @FrequencyCalendarDetailId UNIQUEIDENTIFIER,
  @AppraisalCycleId UNIQUEIDENTIFIER,
  @InitiatedById UNIQUEIDENTIFIER,
  @DaysToClose INT,
  @Status NVARCHAR(50) = 'active'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.initiated_appraisals
    (id, appraisal_group_id, frequency_calendar_detail_id, appraisal_cycle_id, 
     initiated_by_id, initiated_at, days_to_close, status, created_at, updated_at)
  VALUES 
    (@Id, @AppraisalGroupId, @FrequencyCalendarDetailId, @AppraisalCycleId,
     @InitiatedById, GETDATE(), @DaysToClose, @Status, GETDATE(), GETDATE());
    
  SELECT 
    id AS Id, appraisal_group_id AS AppraisalGroupId,
    frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    appraisal_cycle_id AS AppraisalCycleId, initiated_by_id AS InitiatedById,
    initiated_at AS InitiatedAt, completed_at AS CompletedAt,
    days_to_close AS DaysToClose, status AS Status,
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
    id AS Id, appraisal_group_id AS AppraisalGroupId,
    frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    appraisal_cycle_id AS AppraisalCycleId, initiated_by_id AS InitiatedById,
    initiated_at AS InitiatedAt, completed_at AS CompletedAt,
    days_to_close AS DaysToClose, status AS Status,
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
    ia.id AS Id, ia.appraisal_group_id AS AppraisalGroupId,
    ia.frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    ia.appraisal_cycle_id AS AppraisalCycleId, ia.initiated_by_id AS InitiatedById,
    ia.initiated_at AS InitiatedAt, ia.completed_at AS CompletedAt,
    ia.days_to_close AS DaysToClose, ia.status AS Status,
    ia.created_at AS CreatedAt, ia.updated_at AS UpdatedAt,
    ag.name AS AppraisalGroupName
  FROM dbo.initiated_appraisals ia
  INNER JOIN dbo.appraisal_groups ag ON ia.appraisal_group_id = ag.id
  WHERE ia.initiated_by_id = @CreatedById
  ORDER BY ia.initiated_at DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateInitiatedAppraisalStatus
  @Id UNIQUEIDENTIFIER,
  @Status NVARCHAR(50),
  @CompletedAt DATETIME = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.initiated_appraisals 
  SET 
    status = @Status,
    completed_at = COALESCE(@CompletedAt, completed_at),
    updated_at = GETDATE()
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
  @Stage NVARCHAR(100),
  @StartDate DATETIME,
  @EndDate DATETIME,
  @Status NVARCHAR(50) = 'pending'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.initiated_appraisal_detail_timings
    (id, initiated_appraisal_id, frequency_calendar_detail_id, stage, 
     start_date, end_date, status, created_at, updated_at)
  VALUES 
    (@Id, @InitiatedAppraisalId, @FrequencyCalendarDetailId, @Stage,
     @StartDate, @EndDate, @Status, GETDATE(), GETDATE());
    
  SELECT 
    id AS Id, initiated_appraisal_id AS InitiatedAppraisalId,
    frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    stage AS Stage, start_date AS StartDate, end_date AS EndDate,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt
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
    stage AS Stage, start_date AS StartDate, end_date AS EndDate,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.initiated_appraisal_detail_timings 
  WHERE initiated_appraisal_id = @InitiatedAppraisalId
  ORDER BY start_date;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateInitiatedAppraisalDetailTimingStatus
  @Id UNIQUEIDENTIFIER,
  @Status NVARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.initiated_appraisal_detail_timings 
  SET status = @Status, updated_at = GETDATE()
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
  @TaskType NVARCHAR(100),
  @ScheduledDate DATETIME,
  @EvaluationId UNIQUEIDENTIFIER = NULL,
  @Payload NTEXT = NULL,
  @Status NVARCHAR(50) = 'pending'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.scheduled_appraisal_tasks
    (id, initiated_appraisal_id, frequency_calendar_detail_id, task_type,
     scheduled_date, evaluation_id, payload, status, created_at, updated_at)
  VALUES 
    (@Id, @InitiatedAppraisalId, @FrequencyCalendarDetailId, @TaskType,
     @ScheduledDate, @EvaluationId, @Payload, @Status, GETDATE(), GETDATE());
    
  SELECT 
    id AS Id, initiated_appraisal_id AS InitiatedAppraisalId,
    frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    task_type AS TaskType, scheduled_date AS ScheduledDate,
    evaluation_id AS EvaluationId, payload AS Payload, status AS Status,
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
    task_type AS TaskType, scheduled_date AS ScheduledDate,
    evaluation_id AS EvaluationId, payload AS Payload, status AS Status,
    executed_at AS ExecutedAt, error AS Error,
    created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.scheduled_appraisal_tasks 
  WHERE status = 'pending' AND scheduled_date <= GETDATE()
  ORDER BY scheduled_date ASC;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateScheduledTaskStatus
  @Id UNIQUEIDENTIFIER,
  @Status NVARCHAR(50),
  @Error NTEXT = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.scheduled_appraisal_tasks 
  SET 
    status = @Status,
    executed_at = CASE WHEN @Status IN ('completed', 'failed') THEN GETDATE() ELSE executed_at END,
    error = @Error,
    updated_at = GETDATE()
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
    task_type AS TaskType, scheduled_date AS ScheduledDate,
    evaluation_id AS EvaluationId, payload AS Payload, status AS Status,
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
    id AS Id, questionnaire_template_id AS QuestionnaireTemplateId,
    questionnaire_name AS QuestionnaireName, frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    frequency_calendar_name AS FrequencyCalendarName, applicable_to AS ApplicableTo,
    initiated_appraisal_id AS InitiatedAppraisalId, status AS Status,
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
    id AS Id, questionnaire_template_id AS QuestionnaireTemplateId,
    questionnaire_name AS QuestionnaireName, frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    frequency_calendar_name AS FrequencyCalendarName, applicable_to AS ApplicableTo,
    initiated_appraisal_id AS InitiatedAppraisalId, status AS Status,
    created_by_id AS CreatedById, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.publish_questionnaires WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreatePublishQuestionnaire
  @QuestionnaireTemplateId UNIQUEIDENTIFIER,
  @QuestionnaireName NVARCHAR(255),
  @FrequencyCalendarDetailId UNIQUEIDENTIFIER,
  @FrequencyCalendarName NVARCHAR(255),
  @ApplicableTo NVARCHAR(100),
  @InitiatedAppraisalId UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER,
  @Status NVARCHAR(50) = 'active'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.publish_questionnaires
    (id, questionnaire_template_id, questionnaire_name, frequency_calendar_detail_id,
     frequency_calendar_name, applicable_to, initiated_appraisal_id, 
     created_by_id, status, created_at, updated_at)
  VALUES 
    (@Id, @QuestionnaireTemplateId, @QuestionnaireName, @FrequencyCalendarDetailId,
     @FrequencyCalendarName, @ApplicableTo, @InitiatedAppraisalId,
     @CreatedById, @Status, GETDATE(), GETDATE());
     
  SELECT 
    id AS Id, questionnaire_template_id AS QuestionnaireTemplateId,
    questionnaire_name AS QuestionnaireName, frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    frequency_calendar_name AS FrequencyCalendarName, applicable_to AS ApplicableTo,
    initiated_appraisal_id AS InitiatedAppraisalId, status AS Status,
    created_by_id AS CreatedById, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.publish_questionnaires WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdatePublishQuestionnaire
  @Id UNIQUEIDENTIFIER,
  @Status NVARCHAR(50) = NULL,
  @InitiatedAppraisalId UNIQUEIDENTIFIER = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.publish_questionnaires 
  SET 
    status = COALESCE(@Status, status),
    initiated_appraisal_id = COALESCE(@InitiatedAppraisalId, initiated_appraisal_id),
    updated_at = GETDATE()
  WHERE id = @Id;
  
  SELECT 
    id AS Id, questionnaire_template_id AS QuestionnaireTemplateId,
    questionnaire_name AS QuestionnaireName, frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    frequency_calendar_name AS FrequencyCalendarName, applicable_to AS ApplicableTo,
    initiated_appraisal_id AS InitiatedAppraisalId, status AS Status,
    created_by_id AS CreatedById, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.publish_questionnaires WHERE id = @Id;
END
GO

PRINT 'Fixed Part 4 of SPs created successfully - Appraisal Groups, Initiated Appraisals, Tasks, Publish Questionnaires';
PRINT 'All column names corrected to match actual database schema';