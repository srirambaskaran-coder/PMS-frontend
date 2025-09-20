import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Building, Users, ClipboardList, BarChart3 } from "lucide-react";

export default function Landing() {
  const handleLogin = () => {
    window.location.href = "/api/login";
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-background to-muted/20">
      <div className="container mx-auto px-4 py-16">
        {/* Hero Section */}
        <div className="text-center mb-16">
          <div className="flex justify-center mb-6">
            <div className="w-16 h-16 bg-primary rounded-2xl flex items-center justify-center">
              <Building className="h-8 w-8 text-primary-foreground" />
            </div>
          </div>
          <h1 className="text-4xl md:text-6xl font-bold mb-6" data-testid="hero-title">
            Performance Hub
          </h1>
          <p className="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto">
            Streamline your employee performance evaluation process with our comprehensive 
            management system designed for modern organizations.
          </p>
          <Button size="lg" onClick={handleLogin} data-testid="login-button">
            Get Started
          </Button>
        </div>

        {/* Features Section */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-16">
          <Card className="text-center">
            <CardHeader>
              <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mx-auto mb-4">
                <Users className="h-6 w-6 text-primary" />
              </div>
              <CardTitle className="text-lg">Employee Management</CardTitle>
            </CardHeader>
            <CardContent>
              <CardDescription>
                Manage employee profiles, roles, and reporting structures with ease.
              </CardDescription>
            </CardContent>
          </Card>

          <Card className="text-center">
            <CardHeader>
              <div className="w-12 h-12 bg-accent/10 rounded-lg flex items-center justify-center mx-auto mb-4">
                <ClipboardList className="h-6 w-6 text-accent" />
              </div>
              <CardTitle className="text-lg">Performance Reviews</CardTitle>
            </CardHeader>
            <CardContent>
              <CardDescription>
                Conduct comprehensive performance evaluations with customizable templates.
              </CardDescription>
            </CardContent>
          </Card>

          <Card className="text-center">
            <CardHeader>
              <div className="w-12 h-12 bg-secondary/10 rounded-lg flex items-center justify-center mx-auto mb-4">
                <BarChart3 className="h-6 w-6 text-secondary-foreground" />
              </div>
              <CardTitle className="text-lg">Progress Tracking</CardTitle>
            </CardHeader>
            <CardContent>
              <CardDescription>
                Monitor review progress and completion rates across your organization.
              </CardDescription>
            </CardContent>
          </Card>

          <Card className="text-center">
            <CardHeader>
              <div className="w-12 h-12 bg-yellow-100 rounded-lg flex items-center justify-center mx-auto mb-4">
                <Building className="h-6 w-6 text-yellow-600" />
              </div>
              <CardTitle className="text-lg">Role-Based Access</CardTitle>
            </CardHeader>
            <CardContent>
              <CardDescription>
                Secure access control with different permissions for each user role.
              </CardDescription>
            </CardContent>
          </Card>
        </div>

        {/* Benefits Section */}
        <div className="text-center">
          <h2 className="text-3xl font-bold mb-8">Why Choose Performance Hub?</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div>
              <h3 className="text-xl font-semibold mb-4">Streamlined Process</h3>
              <p className="text-muted-foreground">
                Automate your performance review process with email notifications, 
                reminders, and approval workflows.
              </p>
            </div>
            <div>
              <h3 className="text-xl font-semibold mb-4">Data-Driven Insights</h3>
              <p className="text-muted-foreground">
                Get comprehensive analytics and reports to make informed decisions 
                about your team's performance.
              </p>
            </div>
            <div>
              <h3 className="text-xl font-semibold mb-4">Secure & Compliant</h3>
              <p className="text-muted-foreground">
                Enterprise-grade security with role-based access control and 
                data protection compliance.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
