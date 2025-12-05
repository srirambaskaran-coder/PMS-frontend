import { useAuth } from "@/hooks/useAuth";
import { useEffect, useRef } from "react";
import { useToast } from "@/hooks/use-toast";

interface RoleGuardProps {
  allowedRoles: string[];
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

export function RoleGuard({
  allowedRoles,
  children,
  fallback,
}: RoleGuardProps) {
  const { user, isLoading, isAuthenticated } = useAuth();
  const { toast } = useToast();
  const hasShownToast = useRef(false);

  // Use active role from session for role switching support
  const activeRole = (user as any)?.activeRole || (user as any)?.role || "";

  // Super admin should have access to everything
  const hasAccess = allowedRoles.includes(activeRole);

  useEffect(() => {
    // Reset toast flag when user or roles change
    hasShownToast.current = false;
  }, [user?.id, allowedRoles.join(",")]);

  useEffect(() => {
    if (
      !isLoading &&
      isAuthenticated &&
      user &&
      !hasAccess &&
      !hasShownToast.current
    ) {
      hasShownToast.current = true;
      toast({
        title: "Access Denied",
        description: "You don't have permission to access this page.",
        variant: "destructive",
      });
    }
  }, [isLoading, isAuthenticated, user, hasAccess]);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    );
  }

  if (!isAuthenticated || !user) {
    return (
      fallback || (
        <div className="text-center p-8">
          <p className="text-muted-foreground">
            You need to be logged in to access this page.
          </p>
        </div>
      )
    );
  }

  if (!hasAccess) {
    return (
      fallback || (
        <div className="text-center p-8">
          <p className="text-muted-foreground">
            You don't have permission to access this page.
          </p>
        </div>
      )
    );
  }

  return <>{children}</>;
}
