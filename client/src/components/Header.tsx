import { Bell, Plus } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useAuth } from "@/hooks/useAuth";

export function Header() {
  const { user } = useAuth();

  const handleStartReview = () => {
    // TODO: Implement start review cycle modal
    console.log("Start review cycle");
  };

  return (
    <header className="bg-card border-b border-border px-6 py-4" data-testid="header">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-semibold" data-testid="page-title">Performance Dashboard</h1>
          <p className="text-sm text-muted-foreground">
            Monitor and manage employee performance reviews
          </p>
        </div>

        <div className="flex items-center gap-4">
          {/* Notifications */}
          <div className="relative">
            <Button
              variant="ghost"
              size="sm"
              className="relative"
              data-testid="notifications-button"
            >
              <Bell className="h-5 w-5" />
              <span className="absolute -top-1 -right-1 w-3 h-3 bg-destructive rounded-full"></span>
            </Button>
          </div>

          {/* Quick Actions - Only show for HR Manager */}
          {user?.role === 'hr_manager' && (
            <Button onClick={handleStartReview} data-testid="start-review-button">
              <Plus className="h-4 w-4 mr-2" />
              Start Review Cycle
            </Button>
          )}
        </div>
      </div>
    </header>
  );
}
