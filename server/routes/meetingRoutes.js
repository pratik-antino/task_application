import express from 'express';
import { google } from 'googleapis';
import { authenticateUser } from '../middleware/auth.js';

const router = express.Router();

// Schedule a Google Meet meeting
router.post('/schedule', authenticateUser, async (req, res) => {
  try {
    // This is a simplified version. In a real-world scenario, you'd need to set up OAuth2 for Google Calendar API
    const { summary, description, startDateTime, endDateTime, attendees } = req.body;

    const auth = new google.auth.OAuth2(
      process.env.GOOGLE_CLIENT_ID,
      process.env.GOOGLE_CLIENT_SECRET,
      process.env.GOOGLE_REDIRECT_URI
    );

    // Set credentials (you'd typically get these from a database after user authorization)
    auth.setCredentials({
      refresh_token: process.env.GOOGLE_REFRESH_TOKEN,
    });

    const calendar = google.calendar({ version: 'v3', auth });

    const event = {
      summary,
      description,
      start: { dateTime: startDateTime },
      end: { dateTime: endDateTime },
      attendees: attendees.map(email => ({ email })),
      conferenceData: {
        createRequest: { requestId: `${Date.now()}`, conferenceSolutionKey: { type: 'hangoutsMeet' } },
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

export default router;

