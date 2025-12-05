/**
 * Shared Schema Types for Frontend
 * This file contains TypeScript types and Zod validation schemas
 * used by the frontend application.
 * 
 * Note: This is a frontend-only version. The backend maintains
 * the full database schema with drizzle-orm.
 */

import { z } from "zod";

// ========================================
// Enum Types
// ========================================

export type UserRole = 'super_admin' | 'admin' | 'hr_manager' | 'employee' | 'manager';
export type Status = 'active' | 'inactive';
export type Category = 'employee' | 'manager';
export type PublishType = 'now' | 'as_per_calendar';
export type AppraisalType = 'questionnaire_based' | 'kpi_based' | 'mbo_based' | 'okr_based';
export type AppraisalCycleStatus = 'draft' | 'active' | 'closed' | 'cancelled';
export type CalendarProvider = 'google' | 'outlook';

// ========================================
// Entity Types
// ========================================

export interface User {
  id: string;
  email: string | null;
  firstName: string | null;
  lastName: string | null;
  profileImageUrl: string | null;
  createdAt: Date | null;
  updatedAt: Date | null;
  code: string | null;
  designation: string | null;
  department: string | null;
  dateOfJoining: Date | null;
  mobileNumber: string | null;
  reportingManagerId: string | null;
  locationId: string | null;
  companyId: string | null;
  levelId: string | null;
  gradeId: string | null;
  role: UserRole | null;
  roles: string[] | null;
  status: Status | null;
  createdById: string | null;
}

export type SafeUser = Omit<User, 'passwordHash'>;

export interface Company {
  id: string;
  name: string;
  address: string | null;
  clientContact: string | null;
  email: string | null;
  contactNumber: string | null;
  gstNumber: string | null;
  logoUrl: string | null;
  url: string | null;
  companyUrl: string | null;
  status: Status | null;
  createdAt: Date | null;
  updatedAt: Date | null;
}

export interface Location {
  id: string;
  code: string;
  name: string;
  state: string | null;
  country: string | null;
  status: Status | null;
  createdAt: Date | null;
  updatedAt: Date | null;
}

export interface QuestionnaireTemplate {
  id: string;
  name: string;
  description: string | null;
  targetRole: UserRole;
  applicableCategory: Category | null;
  applicableLevelId: string | null;
  applicableGradeId: string | null;
  applicableLocationId: string | null;
  sendOnMail: boolean | null;
  questions: unknown;
  year: number | null;
  status: Status | null;
  createdAt: Date | null;
  updatedAt: Date | null;
  createdById: string | null;
}

export interface ReviewCycle {
  id: string;
  name: string;
  description: string | null;
  startDate: Date;
  endDate: Date;
  questionnaireTemplateId: string;
  status: Status | null;
  createdAt: Date | null;
  updatedAt: Date | null;
}

export interface Evaluation {
  id: string;
  employeeId: string;
  managerId: string;
  reviewCycleId: string;
  initiatedAppraisalId: string | null;
  selfEvaluationData: unknown | null;
  selfEvaluationSubmittedAt: Date | null;
  managerEvaluationData: unknown | null;
  managerEvaluationSubmittedAt: Date | null;
  overallRating: number | null;
  status: string | null;
  meetingScheduledAt: Date | null;
  meetingNotes: string | null;
  showNotesToEmployee: boolean | null;
  meetingCompletedAt: Date | null;
  finalizedAt: Date | null;
  createdAt: Date | null;
  updatedAt: Date | null;
}

export interface EmailTemplate {
  id: string;
  name: string;
  subject: string;
  body: string;
  templateType: string;
  createdAt: Date | null;
  updatedAt: Date | null;
}

export interface EmailConfig {
  id: string;
  smtpHost: string;
  smtpPort: number;
  smtpUsername: string;
  smtpPassword: string;
  fromEmail: string;
  fromName: string;
  isActive: boolean | null;
  createdAt: Date | null;
  updatedAt: Date | null;
}

export interface Registration {
  id: string;
  name: string;
  companyName: string;
  designation: string;
  email: string;
  mobile: string;
  status: string | null;
  notificationSent: boolean | null;
  notes: string | null;
  createdAt: Date | null;
  updatedAt: Date | null;
}

export interface AccessToken {
  id: string;
  token: string;
  userId: string;
  evaluationId: string;
  tokenType: string;
  expiresAt: Date;
  usedAt: Date | null;
  isActive: boolean | null;
  createdAt: Date | null;
}

export interface CalendarCredential {
  id: string;
  companyId: string;
  provider: CalendarProvider;
  clientId: string;
  clientSecret: string;
  accessToken: string | null;
  refreshToken: string;
  expiresAt: Date | null;
  scope: string | null;
  isActive: boolean | null;
  createdAt: Date | null;
  updatedAt: Date | null;
}

export interface Level {
  id: string;
  code: string;
  description: string;
  status: Status | null;
  createdAt: Date | null;
  updatedAt: Date | null;
  createdById: string;
}

export interface Grade {
  id: string;
  code: string;
  description: string;
  status: Status | null;
  createdAt: Date | null;
  updatedAt: Date | null;
  createdById: string;
}

export interface Department {
  id: string;
  code: string;
  description: string;
  status: Status | null;
  createdAt: Date | null;
  updatedAt: Date | null;
  createdById: string;
}

export interface AppraisalCycle {
  id: string;
  code: string;
  description: string;
  fromDate: Date;
  toDate: Date;
  status: Status | null;
  createdAt: Date | null;
  updatedAt: Date | null;
  createdById: string;
}

export interface ReviewFrequency {
  id: string;
  code: string;
  description: string;
  status: Status | null;
  createdAt: Date | null;
  updatedAt: Date | null;
  createdById: string;
}

export interface FrequencyCalendar {
  id: string;
  code: string;
  description: string;
  appraisalCycleId: string;
  reviewFrequencyId: string;
  status: Status | null;
  createdAt: Date | null;
  updatedAt: Date | null;
  createdById: string;
}

export interface FrequencyCalendarDetails {
  id: string;
  frequencyCalendarId: string;
  displayName: string;
  startDate: Date;
  endDate: Date;
  status: Status | null;
  createdAt: Date | null;
  updatedAt: Date | null;
  createdById: string;
}

export interface PublishQuestionnaire {
  id: string;
  code: string;
  displayName: string;
  templateId: string;
  frequencyCalendarId: string | null;
  status: Status | null;
  publishType: PublishType | null;
  createdAt: Date | null;
  updatedAt: Date | null;
  createdById: string;
}

export interface AppraisalGroup {
  id: string;
  name: string;
  description: string | null;
  createdById: string;
  companyId: string | null;
  status: Status | null;
  createdAt: Date | null;
  updatedAt: Date | null;
}

export interface AppraisalGroupMember {
  id: string;
  appraisalGroupId: string;
  userId: string;
  addedById: string;
  addedAt: Date | null;
}

export interface InitiatedAppraisal {
  id: string;
  appraisalGroupId: string;
  appraisalType: AppraisalType;
  questionnaireTemplateIds: string[] | null;
  documentUrl: string | null;
  frequencyCalendarId: string | null;
  daysToInitiate: number | null;
  daysToClose: number | null;
  numberOfReminders: number | null;
  excludeTenureLessThanYear: boolean | null;
  excludedEmployeeIds: string[] | null;
  status: AppraisalCycleStatus | null;
  makePublic: boolean | null;
  publishType: PublishType | null;
  createdById: string;
  createdAt: Date | null;
  updatedAt: Date | null;
}

export interface InitiatedAppraisalDetailTiming {
  id: string;
  initiatedAppraisalId: string;
  frequencyCalendarDetailId: string;
  daysToInitiate: number;
  daysToClose: number;
  numberOfReminders: number;
  createdAt: Date | null;
  updatedAt: Date | null;
}

export interface ScheduledAppraisalTask {
  id: string;
  initiatedAppraisalId: string;
  frequencyCalendarDetailId: string;
  scheduledDate: Date;
  status: string;
  executedAt: Date | null;
  error: string | null;
  createdAt: Date | null;
  updatedAt: Date | null;
}

// ========================================
// Zod Validation Schemas
// ========================================

// User schemas
export const insertUserSchema = z.object({
  email: z.string().email().optional(),
  firstName: z.string().optional(),
  lastName: z.string().optional(),
  profileImageUrl: z.string().optional(),
  code: z.string().optional(),
  designation: z.string().optional(),
  department: z.string().optional(),
  dateOfJoining: z.preprocess((val) => val ? new Date(val as string) : undefined, z.date().optional()),
  mobileNumber: z.string().optional(),
  reportingManagerId: z.string().optional(),
  locationId: z.string().optional(),
  companyId: z.string().optional(),
  levelId: z.string().optional(),
  gradeId: z.string().optional(),
  role: z.enum(['super_admin', 'admin', 'hr_manager', 'employee', 'manager']).optional(),
  roles: z.array(z.enum(['super_admin', 'admin', 'hr_manager', 'employee', 'manager'])).optional().default(['employee']),
  status: z.enum(['active', 'inactive']).optional(),
  password: z.string().min(8, "Password must be at least 8 characters").optional(),
  confirmPassword: z.string().optional(),
}).refine((data) => {
  if (data.password || data.confirmPassword) {
    return data.password === data.confirmPassword;
  }
  return true;
}, {
  message: "Passwords do not match",
  path: ["confirmPassword"],
});

export const updateUserSchema = z.object({
  email: z.string().email().optional(),
  firstName: z.string().optional(),
  lastName: z.string().optional(),
  profileImageUrl: z.string().optional(),
  code: z.string().optional(),
  designation: z.string().optional(),
  department: z.string().optional(),
  dateOfJoining: z.preprocess((val) => val ? new Date(val as string) : undefined, z.date().optional()),
  mobileNumber: z.string().optional(),
  reportingManagerId: z.string().optional(),
  locationId: z.string().optional(),
  companyId: z.string().optional(),
  levelId: z.string().optional(),
  gradeId: z.string().optional(),
  role: z.enum(['super_admin', 'admin', 'hr_manager', 'employee', 'manager']).optional(),
  roles: z.array(z.enum(['super_admin', 'admin', 'hr_manager', 'employee', 'manager'])).optional(),
  status: z.enum(['active', 'inactive']).optional(),
}).partial().strict();

export const passwordUpdateSchema = z.object({
  password: z.string().min(8, "Password must be at least 8 characters"),
  confirmPassword: z.string()
}).strict().refine((data) => data.password === data.confirmPassword, {
  message: "Passwords do not match",
  path: ["confirmPassword"],
});

export const roleUpdateSchema = z.object({
  role: z.enum(['super_admin', 'admin', 'hr_manager', 'employee', 'manager']).optional(),
  roles: z.array(z.enum(['super_admin', 'admin', 'hr_manager', 'employee', 'manager'])).optional()
}).strict();

// Company schema
export const insertCompanySchema = z.object({
  name: z.string().min(1, "Company name is required"),
  address: z.string().optional(),
  clientContact: z.string().optional(),
  email: z.string().email().optional(),
  contactNumber: z.string().optional(),
  gstNumber: z.string().optional(),
  logoUrl: z.string().optional(),
  url: z.string().optional(),
  companyUrl: z.string().optional(),
  status: z.enum(['active', 'inactive']).optional(),
});

// Location schema
export const insertLocationSchema = z.object({
  code: z.string().min(1, "Location code is required"),
  name: z.string().min(1, "Location name is required"),
  state: z.string().optional(),
  country: z.string().optional(),
  status: z.enum(['active', 'inactive']).optional(),
});

// Level schema
export const insertLevelSchema = z.object({
  code: z.string().min(1, "Level code is required"),
  description: z.string().min(1, "Description is required"),
  status: z.enum(['active', 'inactive']).optional(),
});

// Grade schema
export const insertGradeSchema = z.object({
  code: z.string().min(1, "Grade code is required"),
  description: z.string().min(1, "Description is required"),
  status: z.enum(['active', 'inactive']).optional(),
});

// Department schema
export const insertDepartmentSchema = z.object({
  code: z.string().min(1, "Department code is required"),
  description: z.string().min(1, "Description is required"),
  status: z.enum(['active', 'inactive']).optional(),
});

// Appraisal Cycle schema
export const insertAppraisalCycleSchema = z.object({
  code: z.string().min(1, "Appraisal cycle code is required"),
  description: z.string().min(1, "Description is required"),
  fromDate: z.preprocess((val) => new Date(val as string), z.date()),
  toDate: z.preprocess((val) => new Date(val as string), z.date()),
  status: z.enum(['active', 'inactive']).optional(),
});

// Review Frequency schema
export const insertReviewFrequencySchema = z.object({
  code: z.string().min(1, "Review frequency code is required"),
  description: z.string().min(1, "Description is required"),
  status: z.enum(['active', 'inactive']).optional(),
});

// Frequency Calendar schema
export const insertFrequencyCalendarSchema = z.object({
  code: z.string().min(1, "Frequency calendar code is required"),
  description: z.string().min(1, "Description is required"),
  appraisalCycleId: z.string().min(1, "Appraisal cycle is required"),
  reviewFrequencyId: z.string().min(1, "Review frequency is required"),
  status: z.enum(['active', 'inactive']).optional(),
});

// Frequency Calendar Details schema
export const insertFrequencyCalendarDetailsSchema = z.object({
  frequencyCalendarId: z.string().min(1, "Frequency calendar is required"),
  displayName: z.string().min(1, "Display name is required"),
  startDate: z.preprocess((val) => new Date(val as string), z.date()),
  endDate: z.preprocess((val) => new Date(val as string), z.date()),
  status: z.enum(['active', 'inactive']).optional(),
});

// Questionnaire Template schema
export const insertQuestionnaireTemplateSchema = z.object({
  name: z.string().min(1, "Template name is required"),
  description: z.string().optional(),
  targetRole: z.enum(['super_admin', 'admin', 'hr_manager', 'employee', 'manager']),
  applicableCategory: z.enum(['employee', 'manager']).optional(),
  applicableLevelId: z.string().optional(),
  applicableGradeId: z.string().optional(),
  applicableLocationId: z.string().optional(),
  sendOnMail: z.boolean().optional(),
  questions: z.unknown(),
  year: z.number().optional(),
  status: z.enum(['active', 'inactive']).optional(),
});

// Review Cycle schema
export const insertReviewCycleSchema = z.object({
  name: z.string().min(1, "Review cycle name is required"),
  description: z.string().optional(),
  startDate: z.preprocess((val) => new Date(val as string), z.date()),
  endDate: z.preprocess((val) => new Date(val as string), z.date()),
  questionnaireTemplateId: z.string().min(1, "Questionnaire template is required"),
  status: z.enum(['active', 'inactive']).optional(),
});

// Evaluation schema
export const insertEvaluationSchema = z.object({
  employeeId: z.string().min(1, "Employee ID is required"),
  managerId: z.string().min(1, "Manager ID is required"),
  reviewCycleId: z.string().min(1, "Review cycle is required"),
  initiatedAppraisalId: z.string().optional(),
  selfEvaluationData: z.unknown().optional(),
  managerEvaluationData: z.unknown().optional(),
  overallRating: z.number().optional(),
  status: z.string().optional(),
  meetingScheduledAt: z.date().optional(),
  meetingNotes: z.string().optional(),
  showNotesToEmployee: z.boolean().optional(),
});

// Publish Questionnaire schema
export const insertPublishQuestionnaireSchema = z.object({
  code: z.string().min(1, "Publish code is required"),
  displayName: z.string().min(1, "Display name is required"),
  templateId: z.string().min(1, "Template is required"),
  frequencyCalendarId: z.string().optional(),
  status: z.enum(['active', 'inactive']).optional(),
  publishType: z.enum(['now', 'as_per_calendar']).optional(),
});

// Appraisal Group schema
export const insertAppraisalGroupSchema = z.object({
  name: z.string().min(1, "Group name is required"),
  description: z.string().optional(),
  createdById: z.string().optional(),
  companyId: z.string().optional(),
  status: z.enum(['active', 'inactive']).optional(),
});

// Appraisal Group Member schema
export const insertAppraisalGroupMemberSchema = z.object({
  appraisalGroupId: z.string().min(1, "Appraisal group is required"),
  userId: z.string().min(1, "User is required"),
  addedById: z.string().optional(),
});

// Initiated Appraisal schema
export const insertInitiatedAppraisalSchema = z.object({
  appraisalGroupId: z.string().min(1, "Appraisal group is required"),
  appraisalType: z.enum(['questionnaire_based', 'kpi_based', 'mbo_based', 'okr_based']),
  questionnaireTemplateIds: z.array(z.string()).optional(),
  documentUrl: z.string().optional(),
  frequencyCalendarId: z.string().optional(),
  daysToInitiate: z.number().optional(),
  daysToClose: z.number().optional(),
  numberOfReminders: z.number().optional(),
  excludeTenureLessThanYear: z.boolean().optional(),
  excludedEmployeeIds: z.array(z.string()).optional(),
  status: z.enum(['draft', 'active', 'closed', 'cancelled']).optional(),
  makePublic: z.boolean().optional(),
  publishType: z.enum(['now', 'as_per_calendar']).optional(),
  createdById: z.string().optional(),
});

// Email Template schema
export const insertEmailTemplateSchema = z.object({
  name: z.string().min(1, "Template name is required"),
  subject: z.string().min(1, "Subject is required"),
  body: z.string().min(1, "Body is required"),
  templateType: z.string().min(1, "Template type is required"),
});

// Email Config schema
export const insertEmailConfigSchema = z.object({
  smtpHost: z.string().min(1, "SMTP host is required"),
  smtpPort: z.number().min(1, "SMTP port is required"),
  smtpUsername: z.string().min(1, "SMTP username is required"),
  smtpPassword: z.string().min(1, "SMTP password is required"),
  fromEmail: z.string().email("Valid email is required"),
  fromName: z.string().min(1, "From name is required"),
  isActive: z.boolean().optional(),
});

// Registration schema
export const insertRegistrationSchema = z.object({
  name: z.string().min(1, "Name is required"),
  companyName: z.string().min(1, "Company name is required"),
  designation: z.string().min(1, "Designation is required"),
  email: z.string().email("Valid email is required"),
  mobile: z.string().min(1, "Mobile number is required"),
});

// Send Reminder Request Schema
export const sendReminderRequestSchema = z.object({
  employeeId: z.string().min(1, "Employee ID is required"),
  initiatedAppraisalId: z.string().min(1, "Initiated Appraisal ID is required"),
}).strict();

// Initiated Appraisal Detail Timing schema
export const insertInitiatedAppraisalDetailTimingSchema = z.object({
  initiatedAppraisalId: z.string().min(1, "Initiated appraisal is required"),
  frequencyCalendarDetailId: z.string().min(1, "Frequency calendar detail is required"),
  daysToInitiate: z.number().default(0),
  daysToClose: z.number().default(30),
  numberOfReminders: z.number().default(3),
});

// Scheduled Appraisal Task schema
export const insertScheduledAppraisalTaskSchema = z.object({
  initiatedAppraisalId: z.string().min(1, "Initiated appraisal is required"),
  frequencyCalendarDetailId: z.string().min(1, "Frequency calendar detail is required"),
  scheduledDate: z.date(),
  status: z.string().default('pending'),
});

// ========================================
// Insert Types (inferred from Zod schemas)
// ========================================

export type InsertUser = z.infer<typeof insertUserSchema>;
export type InsertCompany = z.infer<typeof insertCompanySchema>;
export type InsertLocation = z.infer<typeof insertLocationSchema>;
export type InsertLevel = z.infer<typeof insertLevelSchema>;
export type InsertGrade = z.infer<typeof insertGradeSchema>;
export type InsertDepartment = z.infer<typeof insertDepartmentSchema>;
export type InsertAppraisalCycle = z.infer<typeof insertAppraisalCycleSchema>;
export type InsertReviewFrequency = z.infer<typeof insertReviewFrequencySchema>;
export type InsertFrequencyCalendar = z.infer<typeof insertFrequencyCalendarSchema>;
export type InsertFrequencyCalendarDetails = z.infer<typeof insertFrequencyCalendarDetailsSchema>;
export type InsertQuestionnaireTemplate = z.infer<typeof insertQuestionnaireTemplateSchema>;
export type InsertReviewCycle = z.infer<typeof insertReviewCycleSchema>;
export type InsertEvaluation = z.infer<typeof insertEvaluationSchema>;
export type InsertPublishQuestionnaire = z.infer<typeof insertPublishQuestionnaireSchema>;
export type InsertAppraisalGroup = z.infer<typeof insertAppraisalGroupSchema>;
export type InsertAppraisalGroupMember = z.infer<typeof insertAppraisalGroupMemberSchema>;
export type InsertInitiatedAppraisal = z.infer<typeof insertInitiatedAppraisalSchema>;
export type InsertEmailTemplate = z.infer<typeof insertEmailTemplateSchema>;
export type InsertEmailConfig = z.infer<typeof insertEmailConfigSchema>;
export type InsertRegistration = z.infer<typeof insertRegistrationSchema>;
export type InsertInitiatedAppraisalDetailTiming = z.infer<typeof insertInitiatedAppraisalDetailTimingSchema>;
export type InsertScheduledAppraisalTask = z.infer<typeof insertScheduledAppraisalTaskSchema>;
