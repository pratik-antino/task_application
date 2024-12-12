import express from 'express';
import { google } from 'googleapis';
import dotenv from 'dotenv';

dotenv.config();

const router = express.Router();

// Set up OAuth2 client
const oauth2Client = new google.auth.OAuth2(
  process.env.GOOGLE_CLIENT_ID,
  process.env.GOOGLE_CLIENT_SECRET,
  process.env.GOOGLE_REDIRECT_URI
);

// Step 1: Redirect to Google OAuth consent screen
router.get('/auth', (req, res) => {
  const authUrl = oauth2Client.generateAuthUrl({
    access_type: 'offline', // Request offline access to get a refresh token
    scope: ['https://www.googleapis.com/auth/calendar'],
  });
  res.redirect(authUrl);
});

// Step 2: Handle callback after user grants permission
router.get('/auth/callback', async (req, res) => {
  const { code } = req.query;

  try {
    const { tokens } = await oauth2Client.getToken(code);

    // Save tokens to the database for the user (you should store tokens securely)
    // Example: await saveTokensToDatabase(tokens);

    // Return the access token to the client for use in API calls
    res.json({ access_token: tokens.access_token });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Step 3: Schedule a Google Meet (using the access token)
router.post('/meetings/schedule', async (req, res) => {
  const { summary, description, startDateTime, endDateTime, participants } = req.body;
  const { access_token } = req.headers; // The client sends the access token as a header

  oauth2Client.setCredentials({ access_token });

  try {
    const calendar = google.calendar({ version: 'v3', auth: oauth2Client });

    const event = {
      summary,
      description,
      start: { dateTime: startDateTime },
      end: { dateTime: endDateTime },
      attendees: participants.map(email => ({ email })),
      conferenceData: {
        createRequest: { 
          requestId: `${Date.now()}`, 
          conferenceSolutionKey: { type: 'hangoutsMeet' }
        },
      },
    };

    const result = await calendar.events.insert({
      calendarId: 'primary',
      resource: event,
      conferenceDataVersion: 1,
    });

    res.json({ meetingLink: result.data.hangoutLink });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Step 4: Share the meeting with participants (dummy implementation)
router.post('/meetings/share', async (req, res) => {
  const { meetingLink, participants } = req.body;

  try {
    // Here you could send an email or SMS to participants, or just log the meeting link
    console.log(`Meeting Link: ${meetingLink}, Participants: ${participants}`);

    // In a real-world scenario, you can send emails using an email service (e.g., SendGrid)
    res.status(200).json({ message: 'Meeting link shared successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Step 5: Invite participants to the meeting (dummy implementation)
router.post('/meetings/invite', async (req, res) => {
  const { meetingLink, participants } = req.body;

  try {
    // Simulate sending invitations
    console.log(`Inviting participants: ${participants.join(', ')} to ${meetingLink}`);

    // In a real-world scenario, you might send invitations via email or other services
    res.status(200).json({ message: 'Participants invited successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Step 6: View calendar events
router.get('/meetings/calendar', async (req, res) => {
  const { access_token } = req.headers; // The client sends the access token as a header

  oauth2Client.setCredentials({ access_token });

  try {
    const calendar = google.calendar({ version: 'v3', auth: oauth2Client });
    
    const events = await calendar.events.list({
      calendarId: 'primary',
      timeMin: new Date().toISOString(),
      maxResults: 10,
      singleEvents: true,
      orderBy: 'startTime',
    });

    res.json(events.data.items);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Step 7: Sync calendar with Google
router.post('/meetings/sync', async (req, res) => {
  const { access_token } = req.headers; // The client sends the access token as a header

  oauth2Client.setCredentials({ access_token });

  try {
    // Here, you would typically check for any new events and sync them with Google Calendar
    // For example, using `calendar.events.insert()` or `calendar.events.update()` for syncing.
    res.status(200).json({ message: 'Calendar synced successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
