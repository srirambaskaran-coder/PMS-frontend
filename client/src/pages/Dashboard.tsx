import { useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Badge } from "@/components/ui/badge";
import { useAuth } from "@/hooks/useAuth";
import { 
  Users, 
  ClipboardCheck, 
  TrendingUp, 
  Clock,
  Download,
  Filter,
} from "lucide-react";

interface DashboardMetrics {
  totalEmployees: number;
  activeReviews: number;
  completionRate: number;
  pendingApprovals: number;
}

export default function Dashboard() {
  const { user } = useAuth();
  
  const { data: metrics, isLoading } = useQuery<DashboardMetrics>({
    queryKey: ["/api/dashboard/metrics"],
  });

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {[...Array(4)].map((_, i) => (
            <Card key={i} className="animate-pulse">
              <CardContent className="p-6">
                <div className="h-16 bg-muted rounded"></div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6" data-testid="dashboard">
      {/* Key Metrics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-muted-foreground">Total Employees</p>
                <p className="text-2xl font-bold" data-testid="total-employees">
                  {metrics?.totalEmployees || 0}
                </p>
              </div>
              <div className="w-10 h-10 bg-primary/10 rounded-full flex items-center justify-center">
                <Users className="h-5 w-5 text-primary" />
              </div>
            </div>
            <div className="mt-4 flex items-center gap-2">
              <span className="text-xs text-accent">↗ 12%</span>
              <span className="text-xs text-muted-foreground">from last month</span>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-muted-foreground">Active Reviews</p>
                <p className="text-2xl font-bold" data-testid="active-reviews">
                  {metrics?.activeReviews || 0}
                </p>
              </div>
              <div className="w-10 h-10 bg-accent/10 rounded-full flex items-center justify-center">
                <ClipboardCheck className="h-5 w-5 text-accent" />
              </div>
            </div>
            <div className="mt-4">
              <span className="text-xs text-muted-foreground">Due this week</span>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-muted-foreground">Completion Rate</p>
                <p className="text-2xl font-bold" data-testid="completion-rate">
                  {metrics?.completionRate || 0}%
                </p>
              </div>
              <div className="w-10 h-10 bg-yellow-100 rounded-full flex items-center justify-center">
                <TrendingUp className="h-5 w-5 text-yellow-600" />
              </div>
            </div>
            <div className="mt-4">
              <Progress value={metrics?.completionRate || 0} className="h-2" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-muted-foreground">Pending Approvals</p>
                <p className="text-2xl font-bold" data-testid="pending-approvals">
                  {metrics?.pendingApprovals || 0}
                </p>
              </div>
              <div className="w-10 h-10 bg-orange-100 rounded-full flex items-center justify-center">
                <Clock className="h-5 w-5 text-orange-600" />
              </div>
            </div>
            <div className="mt-4">
              <span className="text-xs text-destructive">Needs attention</span>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Review Progress and Activities */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Review Progress */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <div>
              <CardTitle>Review Progress</CardTitle>
              <CardDescription>Department-wise completion status</CardDescription>
            </div>
            <Button variant="outline" size="sm">
              <Filter className="h-4 w-4 mr-2" />
              Filter
            </Button>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between p-3 bg-muted/30 rounded-lg">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 bg-primary rounded-full flex items-center justify-center text-xs font-medium text-primary-foreground">
                  ENG
                </div>
                <div>
                  <p className="font-medium">Engineering</p>
                  <p className="text-sm text-muted-foreground">45 employees</p>
                </div>
              </div>
              <div className="text-right">
                <p className="font-medium">85%</p>
                <Progress value={85} className="w-20 h-2 mt-1" />
              </div>
            </div>

            <div className="flex items-center justify-between p-3 bg-muted/30 rounded-lg">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 bg-accent rounded-full flex items-center justify-center text-xs font-medium text-accent-foreground">
                  MKT
                </div>
                <div>
                  <p className="font-medium">Marketing</p>
                  <p className="text-sm text-muted-foreground">28 employees</p>
                </div>
              </div>
              <div className="text-right">
                <p className="font-medium">72%</p>
                <Progress value={72} className="w-20 h-2 mt-1" />
              </div>
            </div>

            <div className="flex items-center justify-between p-3 bg-muted/30 rounded-lg">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 bg-secondary rounded-full flex items-center justify-center text-xs font-medium text-secondary-foreground">
                  SAL
                </div>
                <div>
                  <p className="font-medium">Sales</p>
                  <p className="text-sm text-muted-foreground">32 employees</p>
                </div>
              </div>
              <div className="text-right">
                <p className="font-medium">91%</p>
                <Progress value={91} className="w-20 h-2 mt-1" />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Recent Activities */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <div>
              <CardTitle>Recent Activities</CardTitle>
              <CardDescription>Latest performance review updates</CardDescription>
            </div>
            <Button variant="ghost" size="sm">
              View all
            </Button>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-start gap-3">
              <div className="w-2 h-2 bg-accent rounded-full mt-2 flex-shrink-0"></div>
              <div className="flex-1">
                <p className="text-sm">
                  <span className="font-medium">John Smith</span> completed self-evaluation for Q4 2023
                </p>
                <p className="text-xs text-muted-foreground mt-1">2 hours ago</p>
              </div>
            </div>

            <div className="flex items-start gap-3">
              <div className="w-2 h-2 bg-yellow-500 rounded-full mt-2 flex-shrink-0"></div>
              <div className="flex-1">
                <p className="text-sm">
                  <span className="font-medium">Emily Chen</span> submitted manager review for Michael Johnson
                </p>
                <p className="text-xs text-muted-foreground mt-1">4 hours ago</p>
              </div>
            </div>

            <div className="flex items-start gap-3">
              <div className="w-2 h-2 bg-primary rounded-full mt-2 flex-shrink-0"></div>
              <div className="flex-1">
                <p className="text-sm">
                  <span className="font-medium">Sarah Johnson</span> initiated review cycle for Marketing team
                </p>
                <p className="text-xs text-muted-foreground mt-1">1 day ago</p>
              </div>
            </div>

            <div className="flex items-start gap-3">
              <div className="w-2 h-2 bg-destructive rounded-full mt-2 flex-shrink-0"></div>
              <div className="flex-1">
                <p className="text-sm">
                  Review deadline reminder sent to 12 employees
                </p>
                <p className="text-xs text-muted-foreground mt-1">2 days ago</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Quick Actions - Role-based */}
      {user?.role === 'hr_manager' && (
        <Card>
          <CardHeader>
            <CardTitle>Quick Actions</CardTitle>
            <CardDescription>Frequently used HR management tasks</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex gap-4">
              <Button data-testid="send-reviews-button">
                Send Performance Reviews
              </Button>
              <Button variant="outline" data-testid="export-data-button">
                <Download className="h-4 w-4 mr-2" />
                Export Data
              </Button>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
