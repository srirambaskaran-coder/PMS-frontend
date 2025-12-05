import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Users, Building, Shield, UserCheck, User } from "lucide-react";
import { MOCK_USERS, mockLoginById } from "@/lib/mockAuth";

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

export default function DevLogin() {
  const [selectedUser, setSelectedUser] = useState<string | null>(null);
  const [isLoggingIn, setIsLoggingIn] = useState(false);

  // Convert MOCK_USERS to test users format
  const testUsers = MOCK_USERS.map(user => ({
    id: user.id,
    role: user.role || "employee",
    email: user.email || "",
    name: `${user.firstName} ${user.lastName}`,
  }));

  const handleLogin = (userId: string) => {
    setSelectedUser(userId);
    setIsLoggingIn(true);
    
    const user = mockLoginById(userId);
    if (user) {
      // Small delay to show loading state
      setTimeout(() => {
        window.location.href = "/";
      }, 300);
    } else {
      setIsLoggingIn(false);
      setSelectedUser(null);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-background to-muted/20 flex items-center justify-center p-4">
      <div className="w-full max-w-4xl">
        <div className="text-center mb-8">
          <div className="flex justify-center mb-4">
            <div className="w-16 h-16 bg-primary rounded-2xl flex items-center justify-center">
              <Building className="h-8 w-8 text-primary-foreground" />
            </div>
          </div>
          <h1 className="text-3xl font-bold mb-2">Development Login</h1>
          <p className="text-muted-foreground">
            Choose a test user role to login and explore the system
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {testUsers.map((user) => {
            const Icon = roleIcons[user.role as keyof typeof roleIcons] || User;
            const isLoading = isLoggingIn && selectedUser === user.id;
            
            return (
              <Card 
                key={user.id} 
                className="hover:shadow-lg transition-shadow cursor-pointer"
                onClick={() => !isLoggingIn && handleLogin(user.id)}
                data-testid={`login-card-${user.role}`}
              >
                <CardHeader className="text-center">
                  <div className="flex justify-center mb-3">
                    <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${roleColors[user.role as keyof typeof roleColors]}`}>
                      <Icon className="h-6 w-6 text-white" />
                    </div>
                  </div>
                  <CardTitle className="text-lg">{user.name}</CardTitle>
                  <CardDescription>{user.email}</CardDescription>
                </CardHeader>
                <CardContent className="text-center">
                  <Badge variant="secondary" className="mb-4">
                    {user.role.replace('_', ' ').toUpperCase()}
                  </Badge>
                  <Button 
                    className="w-full"
                    disabled={isLoggingIn}
                    data-testid={`login-button-${user.role}`}
                  >
                    {isLoading ? "Logging in..." : "Login as this user"}
                  </Button>
                </CardContent>
              </Card>
            );
          })}
        </div>

        <div className="mt-8 text-center">
          <Card className="max-w-2xl mx-auto">
            <CardHeader>
              <CardTitle className="text-lg">Frontend Demo Mode</CardTitle>
              <CardDescription>
                This is a frontend-only demo version. Select any role above to explore the UI.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground">
                All data shown is mock data for demonstration purposes. 
                Backend functionality will be connected separately.
              </p>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}