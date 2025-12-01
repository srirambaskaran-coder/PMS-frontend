USE [YourDatabaseName];
GO
SET XACT_ABORT ON;
GO

/**********************************************************
 * 1. CORE MASTER TABLES
 **********************************************************/

-- Companies
CREATE TABLE dbo.companies (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_companies PRIMARY KEY DEFAULT NEWID(),

    name NVARCHAR(255) NOT NULL,
    address NVARCHAR(MAX),
    client_contact NVARCHAR(255),
    email NVARCHAR(255),
    contact_number NVARCHAR(50),
    gst_number NVARCHAR(50),
    logo_url NVARCHAR(500),

    status NVARCHAR(20) NOT NULL DEFAULT 'active'
        CONSTRAINT CH_companies_status CHECK (status IN ('active', 'inactive')),

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    url NVARCHAR(500),
    company_url NVARCHAR(500),

    CONSTRAINT UQ_companies_company_url UNIQUE (company_url)
);
GO

-- Users
CREATE TABLE dbo.users (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_users PRIMARY KEY DEFAULT NEWID(),

    email NVARCHAR(255) NULL,
    first_name NVARCHAR(255) NULL,
    last_name NVARCHAR(255) NULL,
    profile_image_url NVARCHAR(500) NULL,

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    code NVARCHAR(100) NULL,
    designation NVARCHAR(255) NULL,

    date_of_joining DATETIME2 NULL,
    mobile_number NVARCHAR(50) NULL,

    reporting_manager_id UNIQUEIDENTIFIER NULL,
    location_id UNIQUEIDENTIFIER NULL,
    company_id UNIQUEIDENTIFIER NULL,

    role NVARCHAR(50) NOT NULL DEFAULT 'employee'
        CONSTRAINT CH_users_role CHECK (role IN ('super_admin','admin','hr_manager','employee','manager')),

    status NVARCHAR(20) NOT NULL DEFAULT 'active'
        CONSTRAINT CH_users_status CHECK (status IN ('active','inactive')),

    department NVARCHAR(255) NULL,

    roles NVARCHAR(MAX) NULL,              -- from text[] (can store JSON array)

    password_hash NVARCHAR(255) NULL,

    created_by_id UNIQUEIDENTIFIER NULL,
    level_id UNIQUEIDENTIFIER NULL,
    grade_id UNIQUEIDENTIFIER NULL,

    CONSTRAINT UQ_users_code UNIQUE (code),
    CONSTRAINT UQ_users_email UNIQUE (email)
);
GO

CREATE INDEX users_created_by_id_idx ON dbo.users (created_by_id);
GO

-- Levels
CREATE TABLE dbo.levels (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_levels PRIMARY KEY DEFAULT NEWID(),

    code NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,

    status NVARCHAR(20) NOT NULL DEFAULT 'active'
        CONSTRAINT CH_levels_status CHECK (status IN ('active', 'inactive')),

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    created_by_id UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT UQ_levels_created_by_id_code UNIQUE (created_by_id, code)
);
GO

CREATE INDEX levels_created_by_id_idx ON dbo.levels (created_by_id);
GO

-- Grades
CREATE TABLE dbo.grades (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_grades PRIMARY KEY DEFAULT NEWID(),

    code NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,

    status NVARCHAR(20) NOT NULL DEFAULT 'active'
        CONSTRAINT CH_grades_status CHECK (status IN ('active','inactive')),

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    created_by_id UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT UQ_grades_created_by_id_code UNIQUE (created_by_id, code)
);
GO

CREATE INDEX grades_created_by_id_idx ON dbo.grades (created_by_id);
GO

-- Locations
CREATE TABLE dbo.locations (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_locations PRIMARY KEY DEFAULT NEWID(),

    code NVARCHAR(100) NOT NULL,
    name NVARCHAR(255) NOT NULL,

    state NVARCHAR(100) NULL,
    country NVARCHAR(100) NULL,

    status NVARCHAR(20) NOT NULL DEFAULT 'active'
        CONSTRAINT CH_locations_status CHECK (status IN ('active', 'inactive')),

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT UQ_locations_code UNIQUE (code)
);
GO

-- Departments
CREATE TABLE dbo.departments (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_departments PRIMARY KEY DEFAULT NEWID(),

    code NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,

    status NVARCHAR(20) NOT NULL DEFAULT 'active'
        CONSTRAINT CH_departments_status CHECK (status IN ('active','inactive')),

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    created_by_id UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT UQ_departments_created_by_id_code UNIQUE (created_by_id, code)
);
GO

CREATE INDEX departments_created_by_id_idx ON dbo.departments (created_by_id);
GO


/**********************************************************
 * 2. CONFIG / SUPPORT TABLES
 **********************************************************/

-- Email Config
CREATE TABLE dbo.email_config (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_email_config PRIMARY KEY DEFAULT NEWID(),

    smtp_host NVARCHAR(255) NOT NULL,
    smtp_port INT NOT NULL,
    smtp_username NVARCHAR(255) NOT NULL,
    smtp_password NVARCHAR(255) NOT NULL,
    from_email NVARCHAR(255) NOT NULL,
    from_name NVARCHAR(255) NOT NULL,

    is_active BIT NOT NULL DEFAULT 1,

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

-- Email Templates
CREATE TABLE dbo.email_templates (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_email_templates PRIMARY KEY DEFAULT NEWID(),

    name NVARCHAR(255) NOT NULL,
    subject NVARCHAR(500) NOT NULL,
    body NVARCHAR(MAX) NOT NULL,
    template_type NVARCHAR(100) NOT NULL,

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

-- Sessions
CREATE TABLE dbo.sessions (
    sid NVARCHAR(255) NOT NULL
        CONSTRAINT PK_sessions PRIMARY KEY,

    sess NVARCHAR(MAX) NOT NULL,      -- JSON stored as text
    expire DATETIME2 NOT NULL
);
GO

CREATE INDEX IDX_session_expire ON dbo.sessions (expire);
GO

-- Registrations
CREATE TABLE dbo.registrations (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_registrations PRIMARY KEY DEFAULT NEWID(),

    name NVARCHAR(255) NOT NULL,
    company_name NVARCHAR(255) NOT NULL,
    designation NVARCHAR(255) NOT NULL,
    email NVARCHAR(255) NOT NULL,
    mobile NVARCHAR(50) NOT NULL,

    notification_sent BIT NOT NULL DEFAULT 0,

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    status NVARCHAR(50) NOT NULL DEFAULT 'pending',

    notes NVARCHAR(MAX) NULL,

    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO


/**********************************************************
 * 3. REVIEW / QUESTIONNAIRE STRUCTURE
 **********************************************************/

-- Review Frequencies
CREATE TABLE dbo.review_frequencies (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_review_frequencies PRIMARY KEY DEFAULT NEWID(),

    code NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,

    status NVARCHAR(20) NOT NULL DEFAULT 'active'
        CONSTRAINT CH_review_frequencies_status CHECK (status IN ('active','inactive')),

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    created_by_id UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT UQ_review_frequencies_created_by_id_code 
        UNIQUE (created_by_id, code)
);
GO

CREATE INDEX review_frequencies_created_by_id_idx
    ON dbo.review_frequencies (created_by_id);
GO

-- Appraisal Cycles
CREATE TABLE dbo.appraisal_cycles (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_appraisal_cycles PRIMARY KEY DEFAULT NEWID(),

    code NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,

    from_date DATETIME2 NOT NULL,
    to_date DATETIME2 NOT NULL,

    status NVARCHAR(20) NOT NULL DEFAULT 'active'
        CONSTRAINT CH_appraisal_cycles_status CHECK (status IN ('active', 'inactive')),

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    created_by_id UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT UQ_appraisal_cycles_created_by_id_code 
        UNIQUE (created_by_id, code),

    CONSTRAINT CK_appraisal_cycles_date CHECK (from_date <= to_date)
);
GO

CREATE INDEX appraisal_cycles_created_by_id_idx
    ON dbo.appraisal_cycles (created_by_id);
GO

-- Questionnaire Templates
CREATE TABLE dbo.questionnaire_templates (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_questionnaire_templates PRIMARY KEY DEFAULT NEWID(),

    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX) NULL,

    target_role NVARCHAR(50) NOT NULL
        CONSTRAINT CH_questionnaire_templates_target_role
            CHECK (target_role IN ('super_admin','admin','hr_manager','employee','manager')),

    questions NVARCHAR(MAX) NOT NULL,   -- from jsonb

    year INT NULL,

    status NVARCHAR(20) NOT NULL DEFAULT 'active'
        CONSTRAINT CH_questionnaire_templates_status CHECK (status IN ('active','inactive')),

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    applicable_category NVARCHAR(20) NULL
        CONSTRAINT CH_questionnaire_templates_applicable_category
            CHECK (applicable_category IN ('employee','manager')),

    applicable_level_id UNIQUEIDENTIFIER NULL,
    applicable_grade_id UNIQUEIDENTIFIER NULL,
    applicable_location_id UNIQUEIDENTIFIER NULL,

    send_on_mail BIT NOT NULL DEFAULT 0,

    created_by_id UNIQUEIDENTIFIER NULL
);
GO

CREATE INDEX questionnaire_templates_created_by_id_idx
    ON dbo.questionnaire_templates (created_by_id);
GO

-- Review Cycles
CREATE TABLE dbo.review_cycles (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_review_cycles PRIMARY KEY DEFAULT NEWID(),

    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX) NULL,

    start_date DATETIME2 NOT NULL,
    end_date DATETIME2 NOT NULL,

    questionnaire_template_id UNIQUEIDENTIFIER NOT NULL,

    status NVARCHAR(20) NOT NULL DEFAULT 'active'
        CONSTRAINT CH_review_cycles_status CHECK (status IN ('active','inactive')),

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

-- Frequency Calendars
CREATE TABLE dbo.frequency_calendars (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_frequency_calendars PRIMARY KEY DEFAULT NEWID(),

    code NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,

    appraisal_cycle_id UNIQUEIDENTIFIER NOT NULL,
    review_frequency_id UNIQUEIDENTIFIER NOT NULL,

    status NVARCHAR(20) NOT NULL DEFAULT 'active'
        CONSTRAINT CH_frequency_calendars_status CHECK (status IN ('active','inactive')),

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    created_by_id UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT UQ_frequency_calendars_created_by_id_code UNIQUE (created_by_id, code)
);
GO

CREATE INDEX frequency_calendars_created_by_id_idx
    ON dbo.frequency_calendars (created_by_id);
GO

-- Frequency Calendar Details
CREATE TABLE dbo.frequency_calendar_details (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_frequency_calendar_details PRIMARY KEY DEFAULT NEWID(),

    frequency_calendar_id UNIQUEIDENTIFIER NOT NULL,
    display_name NVARCHAR(255) NOT NULL,

    start_date DATETIME2 NOT NULL,
    end_date DATETIME2 NOT NULL,

    status NVARCHAR(20) NOT NULL DEFAULT 'active'
        CONSTRAINT CH_frequency_calendar_details_status CHECK (status IN ('active', 'inactive')),

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    created_by_id UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT CK_frequency_calendar_details_date CHECK (start_date <= end_date)
);
GO

CREATE INDEX frequency_calendar_details_created_by_id_idx
    ON dbo.frequency_calendar_details (created_by_id);
GO


/**********************************************************
 * 4. APPRAISAL GROUPS & INITIATED APPRAISALS
 **********************************************************/

-- Appraisal Groups
CREATE TABLE dbo.appraisal_groups (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_appraisal_groups PRIMARY KEY DEFAULT NEWID(),

    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX) NULL,

    created_by_id UNIQUEIDENTIFIER NOT NULL,
    company_id UNIQUEIDENTIFIER NULL,

    status NVARCHAR(20) NOT NULL DEFAULT 'active'
        CONSTRAINT CH_appraisal_groups_status CHECK (status IN ('active','inactive')),

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE INDEX appraisal_groups_created_by_id_idx
    ON dbo.appraisal_groups (created_by_id);
GO

CREATE INDEX appraisal_groups_company_id_idx
    ON dbo.appraisal_groups (company_id);
GO

-- Appraisal Group Members
CREATE TABLE dbo.appraisal_group_members (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_appraisal_group_members PRIMARY KEY DEFAULT NEWID(),

    appraisal_group_id UNIQUEIDENTIFIER NOT NULL,
    user_id UNIQUEIDENTIFIER NOT NULL,
    added_by_id UNIQUEIDENTIFIER NOT NULL,

    added_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT UQ_appraisal_group_members_group_user UNIQUE (appraisal_group_id, user_id)
);
GO

CREATE INDEX appraisal_group_members_group_id_idx
    ON dbo.appraisal_group_members (appraisal_group_id);
GO

CREATE INDEX appraisal_group_members_user_id_idx
    ON dbo.appraisal_group_members (user_id);
GO

-- Initiated Appraisals
CREATE TABLE dbo.initiated_appraisals (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_initiated_appraisals PRIMARY KEY DEFAULT NEWID(),

    appraisal_group_id UNIQUEIDENTIFIER NOT NULL,

    appraisal_type NVARCHAR(50) NOT NULL
        CONSTRAINT CH_initiated_appraisals_appraisal_type 
            CHECK (appraisal_type IN ('questionnaire_based', 'kpi_based', 'mbo_based', 'okr_based')),

    questionnaire_template_id UNIQUEIDENTIFIER NULL,

    document_url NVARCHAR(500) NULL,

    frequency_calendar_id UNIQUEIDENTIFIER NULL,

    days_to_initiate INT NOT NULL DEFAULT 0,
    days_to_close INT NOT NULL DEFAULT 30,
    number_of_reminders INT NOT NULL DEFAULT 3,

    exclude_tenure_less_than_year BIT NOT NULL DEFAULT 0,

    excluded_employee_ids NVARCHAR(MAX) NULL,      -- from text[] (store JSON/CSV)

    status NVARCHAR(20) NOT NULL DEFAULT 'draft'
        CONSTRAINT CH_initiated_appraisals_status 
            CHECK (status IN ('draft', 'active', 'closed', 'cancelled')),

    make_public BIT NOT NULL DEFAULT 0,

    publish_type NVARCHAR(20) NOT NULL DEFAULT 'now'
        CONSTRAINT CH_initiated_appraisals_publish_type 
            CHECK (publish_type IN ('now', 'as_per_calendar')),

    created_by_id UNIQUEIDENTIFIER NOT NULL,

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    questionnaire_template_ids NVARCHAR(MAX) NULL   -- from text[]
);
GO

CREATE INDEX initiated_appraisals_created_by_id_idx
    ON dbo.initiated_appraisals (created_by_id);
GO

CREATE INDEX initiated_appraisals_group_id_idx
    ON dbo.initiated_appraisals (appraisal_group_id);
GO

-- Initiated Appraisal Detail Timings
CREATE TABLE dbo.initiated_appraisal_detail_timings (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_initiated_appraisal_detail_timings PRIMARY KEY DEFAULT NEWID(),

    initiated_appraisal_id UNIQUEIDENTIFIER NOT NULL,
    frequency_calendar_detail_id UNIQUEIDENTIFIER NOT NULL,

    days_to_initiate INT NOT NULL DEFAULT 0,
    days_to_close INT NOT NULL DEFAULT 30,
    number_of_reminders INT NOT NULL DEFAULT 3,

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT UQ_initiated_appraisal_detail_timings UNIQUE (initiated_appraisal_id, frequency_calendar_detail_id)
);
GO

CREATE INDEX initiated_appraisal_detail_timings_appraisal_id_idx
    ON dbo.initiated_appraisal_detail_timings (initiated_appraisal_id);
GO

CREATE INDEX initiated_appraisal_detail_timings_detail_id_idx
    ON dbo.initiated_appraisal_detail_timings (frequency_calendar_detail_id);
GO


/**********************************************************
 * 5. EVALUATIONS & SCHEDULED TASKS
 **********************************************************/

-- Evaluations
CREATE TABLE dbo.evaluations (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_evaluations PRIMARY KEY DEFAULT NEWID(),

    employee_id UNIQUEIDENTIFIER NOT NULL,
    manager_id UNIQUEIDENTIFIER NOT NULL,
    review_cycle_id UNIQUEIDENTIFIER NOT NULL,

    self_evaluation_data NVARCHAR(MAX) NULL,      -- from jsonb
    self_evaluation_submitted_at DATETIME2 NULL,

    manager_evaluation_data NVARCHAR(MAX) NULL,   -- from jsonb
    manager_evaluation_submitted_at DATETIME2 NULL,

    overall_rating INT NULL,

    status NVARCHAR(50) NOT NULL DEFAULT 'not_started',

    meeting_scheduled_at DATETIME2 NULL,
    meeting_notes NVARCHAR(MAX) NULL,
    meeting_completed_at DATETIME2 NULL,
    finalized_at DATETIME2 NULL,

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    initiated_appraisal_id UNIQUEIDENTIFIER NULL,

    show_notes_to_employee BIT NOT NULL DEFAULT 0,

    calibrated_rating INT NULL,
    calibration_remarks NVARCHAR(MAX) NULL,
    calibrated_by UNIQUEIDENTIFIER NULL,
    calibrated_at DATETIME2 NULL
);
GO

-- Scheduled Appraisal Tasks
CREATE TABLE dbo.scheduled_appraisal_tasks (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_scheduled_appraisal_tasks PRIMARY KEY DEFAULT NEWID(),

    initiated_appraisal_id UNIQUEIDENTIFIER NOT NULL,
    frequency_calendar_detail_id UNIQUEIDENTIFIER NOT NULL,

    scheduled_date DATETIME2 NOT NULL,

    status NVARCHAR(50) NOT NULL DEFAULT 'pending',

    executed_at DATETIME2 NULL,
    error NVARCHAR(MAX) NULL,

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE INDEX scheduled_appraisal_tasks_appraisal_id_idx
    ON dbo.scheduled_appraisal_tasks (initiated_appraisal_id);
GO

CREATE INDEX scheduled_appraisal_tasks_date_idx
    ON dbo.scheduled_appraisal_tasks (scheduled_date);
GO

CREATE INDEX scheduled_appraisal_tasks_status_idx
    ON dbo.scheduled_appraisal_tasks (status);
GO


/**********************************************************
 * 6. PUBLISHING & CALENDAR CREDS
 **********************************************************/

-- Publish Questionnaires
CREATE TABLE dbo.publish_questionnaires (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_publish_questionnaires PRIMARY KEY DEFAULT NEWID(),

    code NVARCHAR(100) NOT NULL,
    display_name NVARCHAR(255) NOT NULL,

    template_id UNIQUEIDENTIFIER NOT NULL,
    frequency_calendar_id UNIQUEIDENTIFIER NULL,

    status NVARCHAR(20) NOT NULL DEFAULT 'active'
        CONSTRAINT CH_publish_questionnaires_status CHECK (status IN ('active', 'inactive')),

    publish_type NVARCHAR(20) NOT NULL DEFAULT 'now'
        CONSTRAINT CH_publish_questionnaires_publish_type CHECK (publish_type IN ('now','as_per_calendar')),

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    created_by_id UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT UQ_publish_questionnaires_created_by_id_code 
        UNIQUE (created_by_id, code),

    CONSTRAINT CH_publish_questionnaires_calendar 
        CHECK (
            publish_type = 'now'
            OR (publish_type = 'as_per_calendar' AND frequency_calendar_id IS NOT NULL)
        )
);
GO

CREATE INDEX publish_questionnaires_created_by_id_idx
    ON dbo.publish_questionnaires (created_by_id);
GO

-- Calendar Credentials
CREATE TABLE dbo.calendar_credentials (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_calendar_credentials PRIMARY KEY DEFAULT NEWID(),

    company_id UNIQUEIDENTIFIER NOT NULL,
    provider NVARCHAR(20) NOT NULL,

    client_id NVARCHAR(255) NOT NULL,
    client_secret NVARCHAR(255) NOT NULL,
    access_token NVARCHAR(MAX),
    refresh_token NVARCHAR(MAX),
    expires_at DATETIME2 NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    scope NVARCHAR(MAX),
    is_active BIT NOT NULL DEFAULT 1,

    CONSTRAINT UQ_calendar_credentials_company_provider UNIQUE (company_id, provider),

    CONSTRAINT CH_calendar_credentials_provider CHECK (provider IN ('google', 'outlook'))
);
GO


/**********************************************************
 * 7. TOKENS & MISC
 **********************************************************/

-- Access Tokens
CREATE TABLE dbo.access_tokens (
    id UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_access_tokens PRIMARY KEY DEFAULT NEWID(),

    token NVARCHAR(255) NOT NULL,
    user_id UNIQUEIDENTIFIER NOT NULL,
    evaluation_id UNIQUEIDENTIFIER NOT NULL,
    token_type NVARCHAR(100) NOT NULL,

    expires_at DATETIME2 NOT NULL,
    used_at DATETIME2 NULL,

    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT UQ_access_tokens_token UNIQUE (token)
);
GO


/**********************************************************
 * 8. FOREIGN KEYS (INFERRED FROM NAMES)
 **********************************************************/

ALTER TABLE dbo.calendar_credentials
    ADD CONSTRAINT FK_calendar_credentials_company
        FOREIGN KEY (company_id) REFERENCES dbo.companies(id);
GO


PRINT 'Schema creation completed.';
GO
