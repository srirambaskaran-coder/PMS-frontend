import type { User, UserRole } from "@shared/schema";

// Mock users for development - one for each role
export const MOCK_USERS: User[] = [
  {
    id: "super-admin-001",
    email: "superadmin@pms.dev",
    firstName: "Super",
    lastName: "Admin",
    profileImageUrl: null,
    createdAt: new Date(),
    updatedAt: new Date(),
    code: "SA001",
    designation: "System Administrator",
    department: "IT",
    dateOfJoining: new Date("2020-01-01"),
    mobileNumber: "9999999901",
    reportingManagerId: null,
    locationId: "loc-001",
    companyId: "company-001",
    levelId: "level-001",
    gradeId: "grade-001",
    role: "super_admin",
    roles: ["super_admin"],
    status: "active",
    createdById: null,
  },
  {
    id: "admin-001",
    email: "admin@pms.dev",
    firstName: "Company",
    lastName: "Admin",
    profileImageUrl: null,
    createdAt: new Date(),
    updatedAt: new Date(),
    code: "AD001",
    designation: "Administrator",
    department: "Administration",
    dateOfJoining: new Date("2021-01-01"),
    mobileNumber: "9999999902",
    reportingManagerId: "super-admin-001",
    locationId: "loc-001",
    companyId: "company-001",
    levelId: "level-002",
    gradeId: "grade-002",
    role: "admin",
    roles: ["admin"],
    status: "active",
    createdById: "super-admin-001",
  },
  {
    id: "hr-manager-001",
    email: "hr@pms.dev",
    firstName: "HR",
    lastName: "Manager",
    profileImageUrl: null,
    createdAt: new Date(),
    updatedAt: new Date(),
    code: "HR001",
    designation: "HR Manager",
    department: "Human Resources",
    dateOfJoining: new Date("2021-06-01"),
    mobileNumber: "9999999903",
    reportingManagerId: "admin-001",
    locationId: "loc-001",
    companyId: "company-001",
    levelId: "level-003",
    gradeId: "grade-003",
    role: "hr_manager",
    roles: ["hr_manager"],
    status: "active",
    createdById: "admin-001",
  },
  {
    id: "manager-001",
    email: "manager@pms.dev",
    firstName: "Team",
    lastName: "Manager",
    profileImageUrl: null,
    createdAt: new Date(),
    updatedAt: new Date(),
    code: "MG001",
    designation: "Engineering Manager",
    department: "Engineering",
    dateOfJoining: new Date("2022-01-01"),
    mobileNumber: "9999999904",
    reportingManagerId: "hr-manager-001",
    locationId: "loc-001",
    companyId: "company-001",
    levelId: "level-004",
    gradeId: "grade-004",
    role: "manager",
    roles: ["manager"],
    status: "active",
    createdById: "admin-001",
  },
  {
    id: "employee-001",
    email: "employee@pms.dev",
    firstName: "John",
    lastName: "Employee",
    profileImageUrl: null,
    createdAt: new Date(),
    updatedAt: new Date(),
    code: "EMP001",
    designation: "Software Engineer",
    department: "Engineering",
    dateOfJoining: new Date("2023-01-01"),
    mobileNumber: "9999999905",
    reportingManagerId: "manager-001",
    locationId: "loc-001",
    companyId: "company-001",
    levelId: "level-005",
    gradeId: "grade-005",
    role: "employee",
    roles: ["employee"],
    status: "active",
    createdById: "admin-001",
  },
];

// Mock credentials (email -> password)
// NOTE: Change these if exposing publicly via dev tunnel!
export const MOCK_CREDENTIALS: Record<string, string> = {
  "superadmin@pms.dev": "SuperAdmin@2024!",
  "admin@pms.dev": "CompanyAdmin@2024!",
  "hr@pms.dev": "HRManager@2024!",
  "manager@pms.dev": "TeamManager@2024!",
  "employee@pms.dev": "Employee@2024!",
};

const AUTH_STORAGE_KEY = "pms_mock_auth_user";

// Get the currently logged in user from localStorage
export function getMockAuthUser(): User | null {
  try {
    const stored = localStorage.getItem(AUTH_STORAGE_KEY);
    if (stored) {
      const user = JSON.parse(stored);
      // Convert date strings back to Date objects
      user.createdAt = user.createdAt ? new Date(user.createdAt) : null;
      user.updatedAt = user.updatedAt ? new Date(user.updatedAt) : null;
      user.dateOfJoining = user.dateOfJoining ? new Date(user.dateOfJoining) : null;
      return user;
    }
  } catch (e) {
    console.error("Error reading auth user from storage:", e);
  }
  return null;
}

// Set the logged in user in localStorage
export function setMockAuthUser(user: User | null): void {
  if (user) {
    localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(user));
  } else {
    localStorage.removeItem(AUTH_STORAGE_KEY);
  }
}

// Mock login function
export function mockLogin(email: string, password: string): User | null {
  const expectedPassword = MOCK_CREDENTIALS[email.toLowerCase()];
  if (expectedPassword && expectedPassword === password) {
    const user = MOCK_USERS.find(u => u.email?.toLowerCase() === email.toLowerCase());
    if (user) {
      setMockAuthUser(user);
      return user;
    }
  }
  return null;
}

// Mock login by user ID (for quick role switching)
export function mockLoginById(userId: string): User | null {
  const user = MOCK_USERS.find(u => u.id === userId);
  if (user) {
    setMockAuthUser(user);
    return user;
  }
  return null;
}

// Mock logout function
export function mockLogout(): void {
  setMockAuthUser(null);
}

// Get user by role
export function getMockUserByRole(role: UserRole): User | undefined {
  return MOCK_USERS.find(u => u.role === role);
}
