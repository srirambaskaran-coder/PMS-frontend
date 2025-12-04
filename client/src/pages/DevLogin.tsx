import { useState } from "react";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Users, Building, Shield, UserCheck, User, ArrowLeft } from "lucide-react";
import { MOCK_USERS, mockLoginById } from "@/lib/mockAuth";
import { useAuth } from "@/hooks/useAuth";
import { Link } from "wouter";

const roleIcons = {
  super_admin: Shield,
  admin: Building,
  hr_manager: Users,
  manager: UserCheck,
  employee: User,
};

const roleColors = {
  super_admin: "bg-red-500",
  admin: "bg-purple-500",
  hr_manager: "bg-blue-500",
  manager: "bg-green-500",
  employee: "bg-gray-500",
};

const roleDescriptions = {
  super_admin: "Full system access. Manage companies, users, and all settings.",
  admin: "Company administrator. Manage users, departments, levels, and grades.",
  hr_manager: "HR functions. Initiate appraisals, manage groups, view progress.",
  manager: "Team management. Review direct reports, submit evaluations.",
  employee: "Self evaluation. Complete assigned questionnaires and view feedback.",
};

export default function DevLogin() {
  const [selectedUser, setSelectedUser] = useState<string | null>(null);
  const [isLoggingIn, setIsLoggingIn] = useState(false);
  const { refreshAuth } = useAuth();

  const handleLogin = async (userId: string) => {
    setSelectedUser(userId);
    setIsLoggingIn(true);
    
    // Simulate a brief loading state
    await new Promise(resolve => setTimeout(resolve, 300));
    
    const user = mockLoginById(userId);
    if (user) {
      refreshAuth();
      window.location.href = "/";
    } else {
      setIsLoggingIn(false);
      setSelectedUser(null);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-background to-muted/20 flex items-center justify-center p-4">
      <div className="w-full max-w-5xl">
        <div className="text-center mb-8">
          <div className="flex justify-center mb-4">
            <div className="w-16 h-16 bg-primary rounded-2xl flex items-center justify-center">
              <Building className="h-8 w-8 text-primary-foreground" />
            </div>
          </div>
          <h1 className="text-3xl font-bold mb-2">Quick Login - Development Mode</h1>
          <p className="text-muted-foreground mb-4">
            Select a role to instantly login and explore the system
          </p>
          <Link href="/">
            <Button variant="outline" size="sm">
              <ArrowLeft className="h-4 w-4 mr-2" />
              Back to Landing Page
            </Button>
          </Link>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
          {MOCK_USERS.map((user) => {
            const Icon = roleIcons[user.role as keyof typeof roleIcons] || User;
            const isLoading = isLoggingIn && selectedUser === user.id;
            const color = roleColors[user.role as keyof typeof roleColors] || "bg-gray-500";
            const description = roleDescriptions[user.role as keyof typeof roleDescriptions] || "";

            return (
              <Card
                key={user.id}
                className={`hover:shadow-lg transition-all cursor-pointer border-2 ${
                  selectedUser === user.id ? "border-primary" : "border-transparent"
                }`}
                onClick={() => !isLoggingIn && handleLogin(user.id)}
                data-testid={`login-card-${user.role}`}
              >
                <CardHeader className="pb-3">
                  <div className="flex items-center gap-3">
                    <div
                      className={`w-12 h-12 rounded-xl flex items-center justify-center ${color}`}
                    >
                      <Icon className="h-6 w-6 text-white" />
                    </div>
                    <div>
                      <CardTitle className="text-lg">
                        {user.firstName} {user.lastName}
                      </CardTitle>
                      <CardDescription className="text-xs">
                        {user.email}
                      </CardDescription>
                    </div>
                  </div>
                </CardHeader>
                <CardContent>
                  <Badge variant="secondary" className="mb-3">
                    {user.role?.replace("_", " ").toUpperCase()}
                  </Badge>
                  <p className="text-sm text-muted-foreground mb-4">
                    {description}
                  </p>
                  <Button
                    className="w-full"
                    disabled={isLoggingIn}
                    data-testid={`login-button-${user.role}`}
                  >
                    {isLoading ? (
                      <>
                        <span className="animate-spin mr-2">⏳</span>
                        Logging in...
                      </>
                    ) : (
                      "Login as this user"
                    )}
                  </Button>
                </CardContent>
              </Card>
            );
          })}
        </div>

        <div className="text-center">
          <Card className="max-w-2xl mx-auto">
            <CardHeader>
              <CardTitle className="text-lg">Test Credentials</CardTitle>
              <CardDescription>
                You can also use these credentials on the main login page
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="bg-muted rounded-lg p-4 text-left">
                <p className="font-mono text-sm mb-3">
                  <strong>Test Accounts:</strong>
                </p>
                <div className="space-y-1 text-sm font-mono">
                  <div>• superadmin@pms.dev / SuperAdmin@2024!</div>
                  <div>• admin@pms.dev / CompanyAdmin@2024!</div>
                  <div>• hr@pms.dev / HRManager@2024!</div>
                  <div>• manager@pms.dev / TeamManager@2024!</div>
                  <div>• employee@pms.dev / Employee@2024!</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
