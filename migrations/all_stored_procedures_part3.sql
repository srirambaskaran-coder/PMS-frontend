-- ========================================
-- STORED PROCEDURES PART 3
-- Questionnaires, Reviews, Evaluations, Registrations, Access Tokens
-- ========================================

USE [YourDatabaseName];
GO

-- ========================================
-- QUESTIONNAIRE TEMPLATES
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetQuestionnaireTemplates
  @RequestingUserId UNIQUEIDENTIFIER = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  -- Security check for HR managers
  IF @RequestingUserId IS NOT NULL
  BEGIN
    DECLARE @RequestingRole NVARCHAR(50);
    DECLARE @RequestingCompanyId UNIQUEIDENTIFIER;
    
    SELECT @RequestingRole = role, @RequestingCompanyId = company_id
    FROM dbo.users WHERE id = @RequestingUserId;
    
    IF @RequestingRole = 'hr_manager'
    BEGIN
      SELECT 
        qt.id AS Id, qt.name AS Name, qt.description AS Description,
        qt.target_role AS TargetRole, qt.questions AS Questions, qt.year AS Year,
        qt.status AS Status, qt.created_at AS CreatedAt, qt.updated_at AS UpdatedAt,
        qt.created_by_id AS CreatedById, qt.applicable_category AS ApplicableCategory,
        qt.applicable_level_id AS ApplicableLevelId,
        qt.applicable_grade_id AS ApplicableGradeId,
        qt.applicable_location_id AS ApplicableLocationId,
        qt.send_on_mail AS SendOnMail
      FROM dbo.questionnaire_templates qt
      LEFT JOIN dbo.users u ON qt.created_by_id = u.id
      WHERE u.company_id = @RequestingCompanyId AND qt.created_by_id IS NOT NULL
      ORDER BY qt.created_at DESC;
      RETURN;
    END
  END
  
  -- Default: return all templates
  SELECT 
    id AS Id, name AS Name, description AS Description,
    target_role AS TargetRole, questions AS Questions, year AS Year,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById, applicable_category AS ApplicableCategory,
    applicable_level_id AS ApplicableLevelId,
    applicable_grade_id AS ApplicableGradeId,
    applicable_location_id AS ApplicableLocationId,
    send_on_mail AS SendOnMail
  FROM dbo.questionnaire_templates
  ORDER BY created_at DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetQuestionnaireTemplate
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, name AS Name, description AS Description,
    target_role AS TargetRole, questions AS Questions, year AS Year,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById, applicable_category AS ApplicableCategory,
    applicable_level_id AS ApplicableLevelId,
    applicable_grade_id AS ApplicableGradeId,
    applicable_location_id AS ApplicableLocationId,
    send_on_mail AS SendOnMail
  FROM dbo.questionnaire_templates WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateQuestionnaireTemplate
  @Name NVARCHAR(255),
  @Description NVARCHAR(MAX) = NULL,
  @TargetRole NVARCHAR(50),
  @Questions NVARCHAR(MAX),
  @Year INT = NULL,
  @Status NVARCHAR(20) = 'active',
  @ApplicableCategory NVARCHAR(20) = NULL,
  @ApplicableLevelId UNIQUEIDENTIFIER = NULL,
  @ApplicableGradeId UNIQUEIDENTIFIER = NULL,
  @ApplicableLocationId UNIQUEIDENTIFIER = NULL,
  @SendOnMail BIT = 0,
  @CreatedById UNIQUEIDENTIFIER = NULL
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.questionnaire_templates
    (id, name, description, target_role, questions, year, status, applicable_category,
     applicable_level_id, applicable_grade_id, applicable_location_id, send_on_mail,
     created_by_id, created_at, updated_at)
  VALUES
    (@Id, @Name, @Description, @TargetRole, @Questions, @Year, @Status, @ApplicableCategory,
     @ApplicableLevelId, @ApplicableGradeId, @ApplicableLocationId, @SendOnMail,
     @CreatedById, SYSDATETIME(), SYSDATETIME());
  
  EXEC dbo.GetQuestionnaireTemplate @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateQuestionnaireTemplate
  @Id UNIQUEIDENTIFIER,
  @Name NVARCHAR(255) = NULL,
  @Description NVARCHAR(MAX) = NULL,
  @TargetRole NVARCHAR(50) = NULL,
  @Questions NVARCHAR(MAX) = NULL,
  @Year INT = NULL,
  @Status NVARCHAR(20) = NULL,
  @ApplicableCategory NVARCHAR(20) = NULL,
  @ApplicableLevelId UNIQUEIDENTIFIER = NULL,
  @ApplicableGradeId UNIQUEIDENTIFIER = NULL,
  @ApplicableLocationId UNIQUEIDENTIFIER = NULL,
  @SendOnMail BIT = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.questionnaire_templates
  SET name = COALESCE(@Name, name),
      description = COALESCE(@Description, description),
      target_role = COALESCE(@TargetRole, target_role),
      questions = COALESCE(@Questions, questions),
      year = COALESCE(@Year, year),
      status = COALESCE(@Status, status),
      applicable_category = COALESCE(@ApplicableCategory, applicable_category),
      applicable_level_id = COALESCE(@ApplicableLevelId, applicable_level_id),
      applicable_grade_id = COALESCE(@ApplicableGradeId, applicable_grade_id),
      applicable_location_id = COALESCE(@ApplicableLocationId, applicable_location_id),
      send_on_mail = COALESCE(@SendOnMail, send_on_mail),
      updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  EXEC dbo.GetQuestionnaireTemplate @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteQuestionnaireTemplate
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.questionnaire_templates WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetQuestionnaireTemplatesByYear
  @Year INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, name AS Name, description AS Description,
    target_role AS TargetRole, questions AS Questions, year AS Year,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt,
    created_by_id AS CreatedById, applicable_category AS ApplicableCategory,
    applicable_level_id AS ApplicableLevelId,
    applicable_grade_id AS ApplicableGradeId,
    applicable_location_id AS ApplicableLocationId,
    send_on_mail AS SendOnMail
  FROM dbo.questionnaire_templates
  WHERE year = @Year;
END
GO

-- ========================================
-- REVIEW CYCLES
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetReviewCycles
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, name AS Name, description AS Description,
    start_date AS StartDate, end_date AS EndDate,
    questionnaire_template_id AS QuestionnaireTemplateId,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.review_cycles ORDER BY created_at DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetReviewCycle
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, name AS Name, description AS Description,
    start_date AS StartDate, end_date AS EndDate,
    questionnaire_template_id AS QuestionnaireTemplateId,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.review_cycles WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateReviewCycle
  @Name NVARCHAR(255),
  @Description NVARCHAR(MAX) = NULL,
  @StartDate DATETIME2,
  @EndDate DATETIME2,
  @QuestionnaireTemplateId UNIQUEIDENTIFIER,
  @Status NVARCHAR(20) = 'active'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.review_cycles
    (id, name, description, start_date, end_date, questionnaire_template_id, status, created_at, updated_at)
  VALUES
    (@Id, @Name, @Description, @StartDate, @EndDate, @QuestionnaireTemplateId, @Status, SYSDATETIME(), SYSDATETIME());
  
  EXEC dbo.GetReviewCycle @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateReviewCycle
  @Id UNIQUEIDENTIFIER,
  @Name NVARCHAR(255) = NULL,
  @Description NVARCHAR(MAX) = NULL,
  @StartDate DATETIME2 = NULL,
  @EndDate DATETIME2 = NULL,
  @QuestionnaireTemplateId UNIQUEIDENTIFIER = NULL,
  @Status NVARCHAR(20) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.review_cycles
  SET name = COALESCE(@Name, name),
      description = COALESCE(@Description, description),
      start_date = COALESCE(@StartDate, start_date),
      end_date = COALESCE(@EndDate, end_date),
      questionnaire_template_id = COALESCE(@QuestionnaireTemplateId, questionnaire_template_id),
      status = COALESCE(@Status, status),
      updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  EXEC dbo.GetReviewCycle @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteReviewCycle
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.review_cycles WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetActiveReviewCycles
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, name AS Name, description AS Description,
    start_date AS StartDate, end_date AS EndDate,
    questionnaire_template_id AS QuestionnaireTemplateId,
    status AS Status, created_at AS CreatedAt, updated_at AS UpdatedAt
  FROM dbo.review_cycles WHERE status = 'active';
END
GO

-- ========================================
-- EVALUATIONS (simplified - complex joins handled in application)
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetEvaluations
  @EmployeeId UNIQUEIDENTIFIER = NULL,
  @ManagerId UNIQUEIDENTIFIER = NULL,
  @ReviewCycleId UNIQUEIDENTIFIER = NULL,
  @Status NVARCHAR(50) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  SELECT 
    id AS Id, employee_id AS EmployeeId, manager_id AS ManagerId,
    review_cycle_id AS ReviewCycleId, self_evaluation_data AS SelfEvaluationData,
    self_evaluation_submitted_at AS SelfEvaluationSubmittedAt,
    manager_evaluation_data AS ManagerEvaluationData,
    manager_evaluation_submitted_at AS ManagerEvaluationSubmittedAt,
    overall_rating AS OverallRating, status AS Status,
    meeting_scheduled_at AS MeetingScheduledAt, meeting_notes AS MeetingNotes,
    meeting_completed_at AS MeetingCompletedAt, finalized_at AS FinalizedAt,
    created_at AS CreatedAt, updated_at AS UpdatedAt,
    initiated_appraisal_id AS InitiatedAppraisalId,
    show_notes_to_employee AS ShowNotesToEmployee,
    calibrated_rating AS CalibratedRating, calibration_remarks AS CalibrationRemarks,
    calibrated_by AS CalibratedBy, calibrated_at AS CalibratedAt
  FROM dbo.evaluations
  WHERE (@EmployeeId IS NULL OR employee_id = @EmployeeId)
    AND (@ManagerId IS NULL OR manager_id = @ManagerId)
    AND (@ReviewCycleId IS NULL OR review_cycle_id = @ReviewCycleId)
    AND (@Status IS NULL OR status = @Status)
  ORDER BY created_at DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetEvaluation
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, employee_id AS EmployeeId, manager_id AS ManagerId,
    review_cycle_id AS ReviewCycleId, self_evaluation_data AS SelfEvaluationData,
    self_evaluation_submitted_at AS SelfEvaluationSubmittedAt,
    manager_evaluation_data AS ManagerEvaluationData,
    manager_evaluation_submitted_at AS ManagerEvaluationSubmittedAt,
    overall_rating AS OverallRating, status AS Status,
    meeting_scheduled_at AS MeetingScheduledAt, meeting_notes AS MeetingNotes,
    meeting_completed_at AS MeetingCompletedAt, finalized_at AS FinalizedAt,
    created_at AS CreatedAt, updated_at AS UpdatedAt,
    initiated_appraisal_id AS InitiatedAppraisalId,
    show_notes_to_employee AS ShowNotesToEmployee,
    calibrated_rating AS CalibratedRating, calibration_remarks AS CalibrationRemarks,
    calibrated_by AS CalibratedBy, calibrated_at AS CalibratedAt
  FROM dbo.evaluations WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateEvaluation
  @EmployeeId UNIQUEIDENTIFIER,
  @ManagerId UNIQUEIDENTIFIER,
  @ReviewCycleId UNIQUEIDENTIFIER,
  @Status NVARCHAR(50) = 'not_started',
  @InitiatedAppraisalId UNIQUEIDENTIFIER = NULL
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.evaluations
    (id, employee_id, manager_id, review_cycle_id, status, initiated_appraisal_id, created_at, updated_at, show_notes_to_employee)
  VALUES
    (@Id, @EmployeeId, @ManagerId, @ReviewCycleId, @Status, @InitiatedAppraisalId, SYSDATETIME(), SYSDATETIME(), 0);
  
  EXEC dbo.GetEvaluation @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateEvaluation
  @Id UNIQUEIDENTIFIER,
  @SelfEvaluationData NVARCHAR(MAX) = NULL,
  @SelfEvaluationSubmittedAt DATETIME2 = NULL,
  @ManagerEvaluationData NVARCHAR(MAX) = NULL,
  @ManagerEvaluationSubmittedAt DATETIME2 = NULL,
  @OverallRating INT = NULL,
  @Status NVARCHAR(50) = NULL,
  @MeetingScheduledAt DATETIME2 = NULL,
  @MeetingNotes NVARCHAR(MAX) = NULL,
  @MeetingCompletedAt DATETIME2 = NULL,
  @FinalizedAt DATETIME2 = NULL,
  @ShowNotesToEmployee BIT = NULL,
  @CalibratedRating INT = NULL,
  @CalibrationRemarks NVARCHAR(MAX) = NULL,
  @CalibratedBy UNIQUEIDENTIFIER = NULL,
  @CalibratedAt DATETIME2 = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.evaluations
  SET self_evaluation_data = COALESCE(@SelfEvaluationData, self_evaluation_data),
      self_evaluation_submitted_at = COALESCE(@SelfEvaluationSubmittedAt, self_evaluation_submitted_at),
      manager_evaluation_data = COALESCE(@ManagerEvaluationData, manager_evaluation_data),
      manager_evaluation_submitted_at = COALESCE(@ManagerEvaluationSubmittedAt, manager_evaluation_submitted_at),
      overall_rating = COALESCE(@OverallRating, overall_rating),
      status = COALESCE(@Status, status),
      meeting_scheduled_at = COALESCE(@MeetingScheduledAt, meeting_scheduled_at),
      meeting_notes = COALESCE(@MeetingNotes, meeting_notes),
      meeting_completed_at = COALESCE(@MeetingCompletedAt, meeting_completed_at),
      finalized_at = COALESCE(@FinalizedAt, finalized_at),
      show_notes_to_employee = COALESCE(@ShowNotesToEmployee, show_notes_to_employee),
      calibrated_rating = COALESCE(@CalibratedRating, calibrated_rating),
      calibration_remarks = COALESCE(@CalibrationRemarks, calibration_remarks),
      calibrated_by = COALESCE(@CalibratedBy, calibrated_by),
      calibrated_at = COALESCE(@CalibratedAt, calibrated_at),
      updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  EXEC dbo.GetEvaluation @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteEvaluation
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.evaluations WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetEvaluationByEmployeeAndCycle
  @EmployeeId UNIQUEIDENTIFIER,
  @ReviewCycleId UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT TOP 1
    id AS Id, employee_id AS EmployeeId, manager_id AS ManagerId,
    review_cycle_id AS ReviewCycleId, self_evaluation_data AS SelfEvaluationData,
    self_evaluation_submitted_at AS SelfEvaluationSubmittedAt,
    manager_evaluation_data AS ManagerEvaluationData,
    manager_evaluation_submitted_at AS ManagerEvaluationSubmittedAt,
    overall_rating AS OverallRating, status AS Status,
    meeting_scheduled_at AS MeetingScheduledAt, meeting_notes AS MeetingNotes,
    meeting_completed_at AS MeetingCompletedAt, finalized_at AS FinalizedAt,
    created_at AS CreatedAt, updated_at AS UpdatedAt,
    initiated_appraisal_id AS InitiatedAppraisalId,
    show_notes_to_employee AS ShowNotesToEmployee,
    calibrated_rating AS CalibratedRating, calibration_remarks AS CalibrationRemarks,
    calibrated_by AS CalibratedBy, calibrated_at AS CalibratedAt
  FROM dbo.evaluations
  WHERE employee_id = @EmployeeId AND review_cycle_id = @ReviewCycleId;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetEvaluationsByInitiatedAppraisal
  @InitiatedAppraisalId UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, employee_id AS EmployeeId, manager_id AS ManagerId,
    review_cycle_id AS ReviewCycleId, self_evaluation_data AS SelfEvaluationData,
    self_evaluation_submitted_at AS SelfEvaluationSubmittedAt,
    manager_evaluation_data AS ManagerEvaluationData,
    manager_evaluation_submitted_at AS ManagerEvaluationSubmittedAt,
    overall_rating AS OverallRating, status AS Status,
    meeting_scheduled_at AS MeetingScheduledAt, meeting_notes AS MeetingNotes,
    meeting_completed_at AS MeetingCompletedAt, finalized_at AS FinalizedAt,
    created_at AS CreatedAt, updated_at AS UpdatedAt,
    initiated_appraisal_id AS InitiatedAppraisalId,
    show_notes_to_employee AS ShowNotesToEmployee,
    calibrated_rating AS CalibratedRating, calibration_remarks AS CalibrationRemarks,
    calibrated_by AS CalibratedBy, calibrated_at AS CalibratedAt
  FROM dbo.evaluations
  WHERE initiated_appraisal_id = @InitiatedAppraisalId
  ORDER BY created_at DESC;
END
GO

-- ========================================
-- REGISTRATIONS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.GetRegistrations
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, name AS Name, company_name AS CompanyName,
    designation AS Designation, email AS Email, mobile AS Mobile,
    notification_sent AS NotificationSent, created_at AS CreatedAt,
    status AS Status, notes AS Notes, updated_at AS UpdatedAt
  FROM dbo.registrations ORDER BY created_at DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetRegistration
  @Id UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, name AS Name, company_name AS CompanyName,
    designation AS Designation, email AS Email, mobile AS Mobile,
    notification_sent AS NotificationSent, created_at AS CreatedAt,
    status AS Status, notes AS Notes, updated_at AS UpdatedAt
  FROM dbo.registrations WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateRegistration
  @Name NVARCHAR(255),
  @CompanyName NVARCHAR(255),
  @Designation NVARCHAR(255),
  @Email NVARCHAR(255),
  @Mobile NVARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.registrations
    (id, name, company_name, designation, email, mobile, notification_sent, created_at, status, updated_at)
  VALUES
    (@Id, @Name, @CompanyName, @Designation, @Email, @Mobile, 0, SYSDATETIME(), 'pending', SYSDATETIME());
  
  EXEC dbo.GetRegistration @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateRegistration
  @Id UNIQUEIDENTIFIER,
  @NotificationSent BIT = NULL,
  @Status NVARCHAR(50) = NULL,
  @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  
  UPDATE dbo.registrations
  SET notification_sent = COALESCE(@NotificationSent, notification_sent),
      status = COALESCE(@Status, status),
      notes = COALESCE(@Notes, notes),
      updated_at = SYSDATETIME()
  WHERE id = @Id;
  
  EXEC dbo.GetRegistration @Id;
END
GO

-- ========================================
-- ACCESS TOKENS
-- ========================================

CREATE OR ALTER PROCEDURE dbo.CreateAccessToken
  @Token NVARCHAR(255),
  @UserId UNIQUEIDENTIFIER,
  @EvaluationId UNIQUEIDENTIFIER,
  @TokenType NVARCHAR(100),
  @ExpiresAt DATETIME2
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Id UNIQUEIDENTIFIER = NEWID();
  
  INSERT INTO dbo.access_tokens
    (id, token, user_id, evaluation_id, token_type, expires_at, is_active, created_at)
  VALUES
    (@Id, @Token, @UserId, @EvaluationId, @TokenType, @ExpiresAt, 1, SYSDATETIME());
  
  SELECT 
    id AS Id, token AS Token, user_id AS UserId,
    evaluation_id AS EvaluationId, token_type AS TokenType,
    expires_at AS ExpiresAt, used_at AS UsedAt,
    is_active AS IsActive, created_at AS CreatedAt
  FROM dbo.access_tokens WHERE id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetAccessToken
  @Token NVARCHAR(255)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, token AS Token, user_id AS UserId,
    evaluation_id AS EvaluationId, token_type AS TokenType,
    expires_at AS ExpiresAt, used_at AS UsedAt,
    is_active AS IsActive, created_at AS CreatedAt
  FROM dbo.access_tokens
  WHERE token = @Token AND is_active = 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.MarkTokenAsUsed
  @Token NVARCHAR(255)
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE dbo.access_tokens
  SET used_at = SYSDATETIME()
  WHERE token = @Token;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeactivateToken
  @Token NVARCHAR(255)
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE dbo.access_tokens
  SET is_active = 0
  WHERE token = @Token;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetActiveTokensByUser
  @UserId UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    id AS Id, token AS Token, user_id AS UserId,
    evaluation_id AS EvaluationId, token_type AS TokenType,
    expires_at AS ExpiresAt, used_at AS UsedAt,
    is_active AS IsActive, created_at AS CreatedAt
  FROM dbo.access_tokens
  WHERE user_id = @UserId AND is_active = 1
  ORDER BY created_at DESC;
END
GO

PRINT 'Part 3 of SPs created successfully - Questionnaires, Reviews, Evaluations, Registrations, Access Tokens';
GO
