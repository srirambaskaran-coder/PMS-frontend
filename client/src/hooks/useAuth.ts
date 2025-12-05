import { useState, useEffect, useCallback } from "react";
import { type SafeUser } from "@shared/schema";
import { getMockAuthUser, setMockAuthUser, mockLogout as doMockLogout } from "@/lib/mockAuth";

export function useAuth() {
  const [user, setUser] = useState<SafeUser | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Load user from localStorage on mount
  useEffect(() => {
    const storedUser = getMockAuthUser();
    if (storedUser) {
      // Convert to SafeUser (omit password)
      const { ...safeUser } = storedUser;
      setUser(safeUser as SafeUser);
    }
    setIsLoading(false);
  }, []);

  // Listen for storage changes (for multi-tab support)
  useEffect(() => {
    const handleStorageChange = (e: StorageEvent) => {
      if (e.key === "pms_mock_auth_user") {
        const storedUser = getMockAuthUser();
        if (storedUser) {
          const { ...safeUser } = storedUser;
          setUser(safeUser as SafeUser);
        } else {
          setUser(null);
        }
      }
    };

    window.addEventListener("storage", handleStorageChange);
    return () => window.removeEventListener("storage", handleStorageChange);
  }, []);

  const login = useCallback((userData: SafeUser) => {
    setMockAuthUser(userData as any);
    setUser(userData);
  }, []);

  const logout = useCallback(() => {
    doMockLogout();
    setUser(null);
    window.location.href = "/";
  }, []);

  const refreshUser = useCallback(() => {
    const storedUser = getMockAuthUser();
    if (storedUser) {
      const { ...safeUser } = storedUser;
      setUser(safeUser as SafeUser);
    }
  }, []);

  return {
    user,
    isLoading,
    isAuthenticated: !!user,
    login,
    logout,
    refreshUser,
  };
}
