import { storage } from './storage';

interface CalendarEvent {
  subject: string;
  description: string;
  startDateTime: Date;
  endDateTime: Date;
  location?: string;
  attendees: Array<{
    email: string;
    name: string;
  }>;
}

interface CalendarProvider {
  type: 'google' | 'outlook' | 'ics';
  credentials?: any;
}

class CalendarService {
  
  /**
   * Detect which calendar service is configured and available for a specific company
   */
  async detectCalendarProvider(companyId: string): Promise<CalendarProvider> {
    try {
      // Check for Google Calendar credentials and verify token validity
      const googleConfig = await this.getGoogleCalendarConfig(companyId);
      if (googleConfig && await this.verifyGoogleToken(googleConfig)) {
        return { type: 'google', credentials: googleConfig };
      }
      
      // Check for Outlook credentials and verify token validity
      const outlookConfig = await this.getOutlookCalendarConfig(companyId);
      if (outlookConfig && await this.verifyOutlookToken(outlookConfig)) {
        return { type: 'outlook', credentials: outlookConfig };
      }
      
      // Fallback to ICS attachments
      return { type: 'ics' };
    } catch (error) {
      console.log('Calendar provider detection failed, falling back to ICS:', error);
      return { type: 'ics' };
    }
  }

  /**
   * Create a calendar event using the appropriate service for a specific company
   */
  async createCalendarEvent(event: CalendarEvent, companyId: string): Promise<{ success: boolean; eventId?: string; error?: string; provider: string }> {
    const provider = await this.detectCalendarProvider(companyId);
    
    try {
      switch (provider.type) {
        case 'google':
          const googleResult = await this.createGoogleCalendarEvent(event, provider.credentials);
          return { ...googleResult, provider: 'google' };
        case 'outlook':
          const outlookResult = await this.createOutlookCalendarEvent(event, provider.credentials);
          return { ...outlookResult, provider: 'outlook' };
        case 'ics':
        default:
          // Return success for ICS fallback (will be handled by email service)
          return { success: true, eventId: 'ics-fallback', provider: 'ics' };
      }
    } catch (error) {
      console.error('Calendar event creation failed:', error);
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Unknown error',
        provider: provider.type
      };
    }
  }

  /**
   * Google Calendar API integration
   */
  private async createGoogleCalendarEvent(event: CalendarEvent, credentials: any): Promise<{ success: boolean; eventId?: string; error?: string }> {
    try {
      const { google } = await import('googleapis');
      
      // Set up OAuth2 client
      const oauth2Client = new google.auth.OAuth2(
        credentials.clientId,
        credentials.clientSecret,
        credentials.redirectUri
      );
      
      oauth2Client.setCredentials({
        access_token: credentials.accessToken,
        refresh_token: credentials.refreshToken,
      });

      const calendar = google.calendar({ version: 'v3', auth: oauth2Client });

      const googleEvent = {
        summary: event.subject,
        description: event.description,
        start: {
          dateTime: event.startDateTime.toISOString(),
          timeZone: 'UTC',
        },
        end: {
          dateTime: event.endDateTime.toISOString(),
          timeZone: 'UTC',
        },
        location: event.location,
        attendees: event.attendees.map(attendee => ({
          email: attendee.email,
          displayName: attendee.name,
        })),
        sendUpdates: 'all', // Send email notifications to attendees
      };

      const response = await calendar.events.insert({
        calendarId: 'primary',
        requestBody: googleEvent,
      });

      return {
        success: true,
        eventId: response.data.id || undefined,
      };
    } catch (error) {
      console.error('Google Calendar API error:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Google Calendar API error',
      };
    }
  }

  /**
   * Microsoft Graph API (Outlook) integration
   */
  private async createOutlookCalendarEvent(event: CalendarEvent, credentials: any): Promise<{ success: boolean; eventId?: string; error?: string }> {
    try {
      // Microsoft Graph API call
      const outlookEvent = {
        subject: event.subject,
        body: {
          contentType: 'HTML',
          content: event.description,
        },
        start: {
          dateTime: event.startDateTime.toISOString(),
          timeZone: 'UTC',
        },
        end: {
          dateTime: event.endDateTime.toISOString(),
          timeZone: 'UTC',
        },
        location: {
          displayName: event.location || '',
        },
        attendees: event.attendees.map(attendee => ({
          emailAddress: {
            address: attendee.email,
            name: attendee.name,
          },
          type: 'required',
        })),
      };

      const response = await fetch('https://graph.microsoft.com/v1.0/me/calendar/events', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${credentials.accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(outlookEvent),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(`Outlook API error: ${errorData.error?.message || response.statusText}`);
      }

      const result = await response.json();
      return {
        success: true,
        eventId: result.id,
      };
    } catch (error) {
      console.error('Outlook Calendar API error:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Outlook Calendar API error',
      };
    }
  }

  /**
   * Verify and refresh Google Calendar token if needed
   */
  private async verifyGoogleToken(config: any): Promise<boolean> {
    try {
      // If we have a valid access token, check if it works
      if (config.accessToken) {
        const response = await fetch('https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=' + config.accessToken);
        if (response.ok) {
          return true;
        }
      }

      // If access token is invalid or missing, try to refresh using refresh token
      if (config.refreshToken && config.clientId && config.clientSecret) {
        const refreshed = await this.refreshGoogleToken(config);
        if (refreshed) {
          // Update config with new access token
          config.accessToken = refreshed.accessToken;
          return true;
        }
      }

      return false;
    } catch (error) {
      console.error('Google token verification failed:', error);
      return false;
    }
  }

  /**
   * Verify and refresh Outlook token if needed
   */
  private async verifyOutlookToken(config: any): Promise<boolean> {
    try {
      // If we have a valid access token, check if it works
      if (config.accessToken) {
        const response = await fetch('https://graph.microsoft.com/v1.0/me/calendar', {
          headers: { 'Authorization': `Bearer ${config.accessToken}` }
        });
        if (response.ok) {
          return true;
        }
      }

      // If access token is invalid or missing, try to refresh using refresh token
      if (config.refreshToken && config.clientId && config.clientSecret) {
        const refreshed = await this.refreshOutlookToken(config);
        if (refreshed) {
          // Update config with new access token
          config.accessToken = refreshed.accessToken;
          return true;
        }
      }

      return false;
    } catch (error) {
      console.error('Outlook token verification failed:', error);
      return false;
    }
  }

  /**
   * Refresh Google Calendar access token and persist to database
   */
  private async refreshGoogleToken(config: any): Promise<{ accessToken: string } | null> {
    try {
      const response = await fetch('https://oauth2.googleapis.com/token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
          client_id: config.clientId,
          client_secret: config.clientSecret,
          refresh_token: config.refreshToken,
          grant_type: 'refresh_token',
        }),
      });

      if (response.ok) {
        const data = await response.json();
        const newAccessToken = data.access_token;
        const expiresIn = data.expires_in; // seconds
        const expiresAt = expiresIn ? new Date(Date.now() + expiresIn * 1000) : undefined;

        // Persist the new token to database
        await storage.updateCalendarCredentialTokens(
          config.companyId,
          'google',
          newAccessToken,
          undefined, // Google doesn't rotate refresh tokens
          expiresAt
        );

        return { accessToken: newAccessToken };
      }

      return null;
    } catch (error) {
      console.error('Google token refresh failed:', error);
      return null;
    }
  }

  /**
   * Refresh Outlook access token and persist to database
   */
  private async refreshOutlookToken(config: any): Promise<{ accessToken: string } | null> {
    try {
      const response = await fetch(`https://login.microsoftonline.com/common/oauth2/v2.0/token`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
          client_id: config.clientId,
          client_secret: config.clientSecret,
          refresh_token: config.refreshToken,
          grant_type: 'refresh_token',
          scope: 'https://graph.microsoft.com/Calendars.ReadWrite offline_access',
        }),
      });

      if (response.ok) {
        const data = await response.json();
        const newAccessToken = data.access_token;
        const newRefreshToken = data.refresh_token; // Microsoft rotates refresh tokens
        const expiresIn = data.expires_in; // seconds
        const expiresAt = expiresIn ? new Date(Date.now() + expiresIn * 1000) : undefined;

        // Persist the new tokens to database (including rotated refresh token)
        await storage.updateCalendarCredentialTokens(
          config.companyId,
          'outlook',
          newAccessToken,
          newRefreshToken, // Microsoft rotates refresh tokens
          expiresAt
        );

        return { accessToken: newAccessToken };
      }

      return null;
    } catch (error) {
      console.error('Outlook token refresh failed:', error);
      return null;
    }
  }

  /**
   * Get Google Calendar configuration from database for a specific company
   */
  private async getGoogleCalendarConfig(companyId: string): Promise<any | null> {
    try {
      const credential = await storage.getCalendarCredential(companyId, 'google');
      if (!credential) {
        return null;
      }

      return {
        id: credential.id,
        clientId: credential.clientId,
        clientSecret: credential.clientSecret,
        refreshToken: credential.refreshToken,
        accessToken: credential.accessToken,
        redirectUri: 'urn:ietf:wg:oauth:2.0:oob',
        companyId: credential.companyId,
      };
    } catch (error) {
      console.error('Error getting Google Calendar config:', error);
      return null;
    }
  }

  /**
   * Get Outlook Calendar configuration from database for a specific company
   */
  private async getOutlookCalendarConfig(companyId: string): Promise<any | null> {
    try {
      const credential = await storage.getCalendarCredential(companyId, 'outlook');
      if (!credential) {
        return null;
      }

      return {
        id: credential.id,
        accessToken: credential.accessToken,
        refreshToken: credential.refreshToken,
        clientId: credential.clientId,
        clientSecret: credential.clientSecret,
        companyId: credential.companyId,
      };
    } catch (error) {
      console.error('Error getting Outlook Calendar config:', error);
      return null;
    }
  }

  /**
   * Helper method to convert meeting details to CalendarEvent format
   */
  convertMeetingToCalendarEvent(
    employeeName: string,
    managerName: string,
    employeeEmail: string,
    managerEmail: string,
    meetingDate: Date,
    duration: number = 60,
    location?: string,
    notes?: string
  ): CalendarEvent {
    const endDateTime = new Date(meetingDate.getTime() + duration * 60 * 1000);
    
    let description = `One-on-one performance review meeting between ${employeeName} and ${managerName}`;
    if (notes) {
      description += `\n\nNotes: ${notes}`;
    }

    return {
      subject: `Performance Review Meeting - ${employeeName} (${duration}min)`,
      description,
      startDateTime: meetingDate,
      endDateTime,
      location,
      attendees: [
        { email: employeeEmail, name: employeeName },
        { email: managerEmail, name: managerName },
      ],
    };
  }
}

const calendarService = new CalendarService();

/**
 * Create a calendar event for a performance review meeting
 */
export async function createPerformanceReviewMeeting(
  employeeName: string,
  managerName: string,
  employeeEmail: string,
  managerEmail: string,
  meetingDate: Date,
  companyId: string,
  duration?: number,
  location?: string,
  notes?: string
): Promise<{ success: boolean; eventId?: string; error?: string; provider: string }> {
  const calendarEvent = calendarService.convertMeetingToCalendarEvent(
    employeeName,
    managerName,
    employeeEmail,
    managerEmail,
    meetingDate,
    duration,
    location,
    notes
  );

  const result = await calendarService.createCalendarEvent(calendarEvent, companyId);
  
  return result;
}

export { CalendarService };