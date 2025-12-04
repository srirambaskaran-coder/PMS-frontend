import { useQuery, useQueryClient } from "@tanstack/react-query";
import { type User } from "@shared/schema";
import { getMockAuthUser, mockLogout } from "@/lib/mockAuth";

export function useAuth() {
  const queryClient = useQueryClient();

  const { data: user, isLoading } = useQuery<User | null>({
    queryKey: ["auth-user"],
    queryFn: () => {
      // Use mock authentication for frontend development
      return getMockAuthUser();
    },
    retry: false,
    staleTime: Infinity,
  });

  const logout = () => {
    mockLogout();
    queryClient.setQueryData(["auth-user"], null);
    queryClient.invalidateQueries({ queryKey: ["auth-user"] });
    window.location.href = "/";
  };

  const refreshAuth = () => {
    queryClient.invalidateQueries({ queryKey: ["auth-user"] });
  };

  return {
    user,
    isLoading,
    isAuthenticated: !!user,
    logout,
    refreshAuth,
  };
}
