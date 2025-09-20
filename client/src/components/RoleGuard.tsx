import { useAuth } from "@/hooks/useAuth";
import { useEffect } from "react";
import { useToast } from "@/hooks/use-toast";

interface RoleGuardProps {
  allowedRoles: string[];
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

export function RoleGuard({ allowedRoles, children, fallback }: RoleGuardProps) {
  const { user, isLoading, isAuthenticated } = useAuth();
  const { toast } = useToast();

  useEffect(() => {
    if (!isLoading && isAuthenticated && user && !allowedRoles.includes(user.role || "")) {
      toast({
        title: "Access Denied",
        description: "You don't have permission to access this page.",
        variant: "destructive",
      });
    }
  }, [isLoading, isAuthenticated, user, allowedRoles, toast]);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    );
  }

  if (!isAuthenticated || !user) {
    return fallback || (
      <div className="text-center p-8">
        <p className="text-muted-foreground">You need to be logged in to access this page.</p>
      </div>
    );
  }

  if (!allowedRoles.includes(user.role || "")) {
    return fallback || (
      <div className="text-center p-8">
        <p className="text-muted-foreground">You don't have permission to access this page.</p>
      </div>
    );
  }

  return <>{children}</>;
}
