/**
 * API Configuration Utility
 * 
 * Priority order:
 * 1. VITE_API_URL (manual override - highest priority)
 * 2. Auto-derived from frontend domain
 * 3. Stage-based fallback (VITE_STAGE)
 */

interface DomainMapping {
  [domain: string]: string;
}

// Map frontend domains to backend API URLs
const DOMAIN_TO_API_MAP: DomainMapping = {
  'smeqc.com': 'https://api.smeqc.com',
  'www.smeqc.com': 'https://api.smeqc.com',
  'localhost': 'http://localhost:5000',
  '127.0.0.1': 'http://localhost:5000',
  // Add more domain mappings as needed
};

// Stage-based fallback URLs
const STAGE_API_URLS = {
  local: import.meta.env.VITE_API_URL_LOCAL || 'http://localhost:5000',
  dev: import.meta.env.VITE_API_URL_DEV || 'http://192.168.11.187:5000',
  qc: import.meta.env.VITE_API_URL_QC || 'https://qc.api.yourdomain.com',
  prod: import.meta.env.VITE_API_URL_PROD || 'https://api.yourdomain.com',
};

/**
 * Get the base API URL based on configuration priority
 */
export function getApiBaseUrl(): string {
  // Priority 1: Explicit override via VITE_API_URL
  const explicitUrl = import.meta.env.VITE_API_URL;
  if (explicitUrl && explicitUrl.trim()) {
    return explicitUrl.trim();
  }

  // Priority 2: Auto-derive from current frontend domain
  const hostname = window.location.hostname;
  
  // Check exact domain match
  if (DOMAIN_TO_API_MAP[hostname]) {
    return DOMAIN_TO_API_MAP[hostname];
  }

  // Check if it's a subdomain and try to derive API URL
  // e.g., app.smeqc.com -> api.smeqc.com
  const parts = hostname.split('.');
  if (parts.length >= 2) {
    const baseDomain = parts.slice(-2).join('.'); // Get last two parts (domain.tld)
    if (DOMAIN_TO_API_MAP[baseDomain]) {
      return DOMAIN_TO_API_MAP[baseDomain];
    }
    
    // Try replacing subdomain with 'api'
    const apiDomain = `api.${baseDomain}`;
    // Check if we're on https, use https for API too
    const protocol = window.location.protocol;
    return `${protocol}//${apiDomain}`;
  }

  // Priority 3: Fall back to stage-based configuration
  const stage = (import.meta.env.VITE_STAGE || 'dev') as keyof typeof STAGE_API_URLS;
  return STAGE_API_URLS[stage] || STAGE_API_URLS.dev;
}

/**
 * Get the full API URL by appending path to base URL
 */
export function getApiUrl(path: string): string {
  const baseUrl = getApiBaseUrl();
  // Remove trailing slash from base and leading slash from path to avoid double slashes
  const cleanBase = baseUrl.replace(/\/$/, '');
  const cleanPath = path.replace(/^\//, '');
  return `${cleanBase}/${cleanPath}`;
}

/**
 * Get API base URL without any path
 * Useful for displaying current API configuration
 */
export function getCurrentApiBase(): string {
  return getApiBaseUrl();
}

// Log the current API configuration in development
if (import.meta.env.DEV) {
  console.log('🔧 API Configuration:', {
    baseUrl: getApiBaseUrl(),
    source: import.meta.env.VITE_API_URL 
      ? 'VITE_API_URL (manual override)' 
      : `Auto-derived from ${window.location.hostname}`,
    stage: import.meta.env.VITE_STAGE || 'dev',
  });
}
