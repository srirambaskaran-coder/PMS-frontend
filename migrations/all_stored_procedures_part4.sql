-- ========================================
-- STORED PROCEDURES PART 4
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
    id AS Id, group_name AS GroupName, manager_id AS ManagerId,
    created_by_id AS CreatedById, created_at AS CreatedAt,
    updated_at AS UpdatedAt
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
    id AS Id, group_name AS GroupName, manager_id AS ManagerId,
    created_by_id AS CreatedById, created_at AS CreatedAt,
    updated_at AS UpdatedAt
  FROM dbo.appraisal_groups WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateAppraisalGroup
  @GroupName NVARCHAR(255),
  @ManagerId UNIQUEIDENTIFIER,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.appraisal_groups
    (id, group_name, manager_id, created_by_id, created_at, updated_at)
  VALUES
    (@Id, @GroupName, @ManagerId, @CreatedById, SYSDATETIME(), SYSDATETIME());
  
  EXEC dbo.GetAppraisalGroup @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateAppraisalGroup
  @Id UNIQUEIDENTIFIER,
  @GroupName NVARCHAR(255) = NULL,
  @ManagerId UNIQUEIDENTIFIER = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.appraisal_groups
  SET group_name = COALESCE(@GroupName, group_name),
      manager_id = COALESCE(@ManagerId, manager_id),
      updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  EXEC dbo.GetAppraisalGroup @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteAppraisalGroup
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  -- Delete members first
  DELETE FROM dbo.appraisal_group_members WHERE appraisal_group_id = @Id;
  -- Delete group
  DELETE FROM dbo.appraisal_groups WHERE id = @Id;
END
GO

-- ========================================
-- APPRAISAL GROUP MEMBERS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetAppraisalGroupMembers
  @AppraisalGroupId UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    agm.id AS Id, 
    agm.appraisal_group_id AS AppraisalGroupId,
    agm.user_id AS UserId, 
    agm.added_at AS AddedAt,
    agm.added_by_id AS AddedById,
    -- User fields
    u.id AS UserId,
    u.email AS UserEmail,
    u.first_name AS UserFirstName,
    u.last_name AS UserLastName,
    u.profile_image_url AS UserProfileImageUrl,
    u.created_at AS UserCreatedAt,
    u.updated_at AS UserUpdatedAt,
    u.code AS UserCode,
    u.designation AS UserDesignation,
    u.department AS UserDepartment,
    u.date_of_joining AS UserDateOfJoining,
    u.mobile_number AS UserMobileNumber,
    u.reporting_manager_id AS UserReportingManagerId,
    u.location_id AS UserLocationId,
    u.company_id AS UserCompanyId,
    u.level_id AS UserLevelId,
    u.grade_id AS UserGradeId,
    u.role AS UserRole,
    u.roles AS UserRoles,
    u.status AS UserStatus,
    u.created_by_id AS UserCreatedById
  FROM dbo.appraisal_group_members agm
  LEFT JOIN dbo.users u ON agm.user_id = u.id
  WHERE agm.appraisal_group_id = @AppraisalGroupId
  ORDER BY agm.added_at;
END
GO

CREATE OR ALTER PROCEDURE dbo.AddAppraisalGroupMember
  @AppraisalGroupId UNIQUEIDENTIFIER,
  @EmployeeId UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  -- Check if already exists
  IF EXISTS (SELECT 1 FROM dbo.appraisal_group_members 
             WHERE appraisal_group_id = @AppraisalGroupId AND employee_id = @EmployeeId)
  BEGIN
    SELECT 
      id AS Id, appraisal_group_id AS AppraisalGroupId,
      employee_id AS EmployeeId, added_at AS AddedAt
    FROM dbo.appraisal_group_members
    WHERE appraisal_group_id = @AppraisalGroupId AND employee_id = @EmployeeId;
    RETURN;
  END
  
  INSERT INTO dbo.appraisal_group_members
    (id, appraisal_group_id, employee_id, added_at)
  VALUES
    (@Id, @AppraisalGroupId, @EmployeeId, SYSDATETIME());
  
  SELECT 
    id AS Id, appraisal_group_id AS AppraisalGroupId,
    employee_id AS EmployeeId, added_at AS AddedAt
  FROM dbo.appraisal_group_members WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.RemoveAppraisalGroupMember
  @AppraisalGroupId UNIQUEIDENTIFIER,
  @EmployeeId UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.appraisal_group_members
  WHERE appraisal_group_id = @AppraisalGroupId AND employee_id = @EmployeeId;
END
GO

-- ========================================
-- INITIATED APPRAISALS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.CreateInitiatedAppraisal
  @FrequencyCalendarDetailId UNIQUEIDENTIFIER,
  @AppraisalCycleId UNIQUEIDENTIFIER,
  @QuestionnaireTemplateId UNIQUEIDENTIFIER,
  @InitiatedById UNIQUEIDENTIFIER,
  @Status NVARCHAR(50) = 'initiated'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.initiated_appraisals
    (id, frequency_calendar_detail_id, appraisal_cycle_id, questionnaire_template_id,
     initiated_by_id, initiated_at, status)
  VALUES
    (@Id, @FrequencyCalendarDetailId, @AppraisalCycleId, @QuestionnaireTemplateId,
     @InitiatedById, SYSDATETIME(), @Status);
  
  SELECT 
    id AS Id, frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    appraisal_cycle_id AS AppraisalCycleId,
    questionnaire_template_id AS QuestionnaireTemplateId,
    initiated_by_id AS InitiatedById, initiated_at AS InitiatedAt,
    status AS Status, completed_at AS CompletedAt
  FROM dbo.initiated_appraisals WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetInitiatedAppraisal
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    appraisal_cycle_id AS AppraisalCycleId,
    questionnaire_template_id AS QuestionnaireTemplateId,
    initiated_by_id AS InitiatedById, initiated_at AS InitiatedAt,
    status AS Status, completed_at AS CompletedAt
  FROM dbo.initiated_appraisals WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetInitiatedAppraisals
  @AppraisalCycleId UNIQUEIDENTIFIER = NULL,
  @Status NVARCHAR(50) = NULL,
  @FrequencyCalendarDetailId UNIQUEIDENTIFIER = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  SELECT 
    id AS Id, frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    appraisal_cycle_id AS AppraisalCycleId,
    questionnaire_template_id AS QuestionnaireTemplateId,
    initiated_by_id AS InitiatedById, initiated_at AS InitiatedAt,
    status AS Status, completed_at AS CompletedAt
  FROM dbo.initiated_appraisals
  WHERE (@AppraisalCycleId IS NULL OR appraisal_cycle_id = @AppraisalCycleId)
    AND (@Status IS NULL OR status = @Status)
    AND (@FrequencyCalendarDetailId IS NULL OR frequency_calendar_detail_id = @FrequencyCalendarDetailId)
  ORDER BY initiated_at DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateInitiatedAppraisalStatus
  @Id UNIQUEIDENTIFIER,
  @Status NVARCHAR(50),
  @CompletedAt DATETIME2 = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.initiated_appraisals
  SET status = @Status,
      completed_at = COALESCE(@CompletedAt, completed_at)
  WHERE id = @Id;
  
  EXEC dbo.GetInitiatedAppraisal @Id;
END
GO

-- ========================================
-- INITIATED APPRAISAL DETAIL TIMINGS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.CreateInitiatedAppraisalDetailTiming
  @InitiatedAppraisalId UNIQUEIDENTIFIER,
  @Stage NVARCHAR(100),
  @StartDate DATETIME2,
  @EndDate DATETIME2,
  @Status NVARCHAR(50) = 'pending'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.initiated_appraisal_detail_timings
    (id, initiated_appraisal_id, stage, start_date, end_date, status, created_at)
  VALUES
    (@Id, @InitiatedAppraisalId, @Stage, @StartDate, @EndDate, @Status, SYSDATETIME());
  
  SELECT 
    id AS Id, initiated_appraisal_id AS InitiatedAppraisalId,
    stage AS Stage, start_date AS StartDate, end_date AS EndDate,
    status AS Status, created_at AS CreatedAt
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
    stage AS Stage, start_date AS StartDate, end_date AS EndDate,
    status AS Status, created_at AS CreatedAt
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
  SET status = @Status
  WHERE id = @Id;
  
  SELECT 
    id AS Id, initiated_appraisal_id AS InitiatedAppraisalId,
    stage AS Stage, start_date AS StartDate, end_date AS EndDate,
    status AS Status, created_at AS CreatedAt
  FROM dbo.initiated_appraisal_detail_timings WHERE id = @Id;
END
GO

-- ========================================
-- SCHEDULED APPRAISAL TASKS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.CreateScheduledAppraisalTask
  @TaskType NVARCHAR(100),
  @ScheduledFor DATETIME2,
  @Status NVARCHAR(50) = 'pending',
  @InitiatedAppraisalId UNIQUEIDENTIFIER = NULL,
  @EvaluationId UNIQUEIDENTIFIER = NULL,
  @Payload NVARCHAR(MAX) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.scheduled_appraisal_tasks
    (id, task_type, scheduled_for, status, initiated_appraisal_id,
     evaluation_id, payload, created_at, updated_at)
  VALUES
    (@Id, @TaskType, @ScheduledFor, @Status, @InitiatedAppraisalId,
     @EvaluationId, @Payload, SYSDATETIME(), SYSDATETIME());
  
  SELECT 
    id AS Id, task_type AS TaskType, scheduled_for AS ScheduledFor,
    status AS Status, initiated_appraisal_id AS InitiatedAppraisalId,
    evaluation_id AS EvaluationId, payload AS Payload,
    processed_at AS ProcessedAt, error_message AS ErrorMessage,
    created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.scheduled_appraisal_tasks WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetPendingScheduledTasks
  @CurrentTime DATETIME2
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, task_type AS TaskType, scheduled_for AS ScheduledFor,
    status AS Status, initiated_appraisal_id AS InitiatedAppraisalId,
    evaluation_id AS EvaluationId, payload AS Payload,
    processed_at AS ProcessedAt, error_message AS ErrorMessage,
    created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.scheduled_appraisal_tasks
  WHERE status = 'pending' AND scheduled_for <= @CurrentTime
  ORDER BY scheduled_for;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateScheduledTaskStatus
  @Id UNIQUEIDENTIFIER,
  @Status NVARCHAR(50),
  @ProcessedAt DATETIME2 = NULL,
  @ErrorMessage NVARCHAR(MAX) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.scheduled_appraisal_tasks
  SET status = @Status,
      processed_at = COALESCE(@ProcessedAt, processed_at),
      error_message = COALESCE(@ErrorMessage, error_message),
      updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  SELECT 
    id AS Id, task_type AS TaskType, scheduled_for AS ScheduledFor,
    status AS Status, initiated_appraisal_id AS InitiatedAppraisalId,
    evaluation_id AS EvaluationId, payload AS Payload,
    processed_at AS ProcessedAt, error_message AS ErrorMessage,
    created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.scheduled_appraisal_tasks WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetScheduledTasksByAppraisal
  @InitiatedAppraisalId UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, task_type AS TaskType, scheduled_for AS ScheduledFor,
    status AS Status, initiated_appraisal_id AS InitiatedAppraisalId,
    evaluation_id AS EvaluationId, payload AS Payload,
    processed_at AS ProcessedAt, error_message AS ErrorMessage,
    created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.scheduled_appraisal_tasks
  WHERE initiated_appraisal_id = @InitiatedAppraisalId
  ORDER BY scheduled_for;
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
    questionnaire_name AS QuestionnaireName,
    frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    frequency_calendar_name AS FrequencyCalendarName,
    applicable_to AS ApplicableTo, initiated_appraisal_id AS InitiatedAppraisalId,
    created_by_id AS CreatedById, created_at AS CreatedAt
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
    questionnaire_name AS QuestionnaireName,
    frequency_calendar_detail_id AS FrequencyCalendarDetailId,
    frequency_calendar_name AS FrequencyCalendarName,
    applicable_to AS ApplicableTo, initiated_appraisal_id AS InitiatedAppraisalId,
    created_by_id AS CreatedById, created_at AS CreatedAt
  FROM dbo.publish_questionnaires WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreatePublishQuestionnaire
  @QuestionnaireTemplateId UNIQUEIDENTIFIER,
  @QuestionnaireName NVARCHAR(255),
  @FrequencyCalendarDetailId UNIQUEIDENTIFIER,
  @FrequencyCalendarName NVARCHAR(255),
  @ApplicableTo NVARCHAR(MAX),
  @InitiatedAppraisalId UNIQUEIDENTIFIER = NULL,
  @CreatedById UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.publish_questionnaires
    (id, questionnaire_template_id, questionnaire_name, frequency_calendar_detail_id,
     frequency_calendar_name, applicable_to, initiated_appraisal_id, created_by_id, created_at)
  VALUES
    (@Id, @QuestionnaireTemplateId, @QuestionnaireName, @FrequencyCalendarDetailId,
     @FrequencyCalendarName, @ApplicableTo, @InitiatedAppraisalId, @CreatedById, SYSDATETIME());
  
  EXEC dbo.GetPublishQuestionnaire @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdatePublishQuestionnaire
  @Id UNIQUEIDENTIFIER,
  @InitiatedAppraisalId UNIQUEIDENTIFIER = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.publish_questionnaires
  SET initiated_appraisal_id = COALESCE(@InitiatedAppraisalId, initiated_appraisal_id)
  WHERE id = @Id;
  
  EXEC dbo.GetPublishQuestionnaire @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeletePublishQuestionnaire
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.publish_questionnaires WHERE id = @Id;
END
GO

PRINT 'Part 4 of SPs created successfully - Appraisal Groups, Initiated Appraisals, Tasks, Publish Questionnaires';
GO
