import express from 'express';
import Event from '../models/event.js';
import User from '../models/User.js';
import cron from 'node-cron';
import admin from 'firebase-admin';
import { authenticateUser } from '../middleware/auth.js';
const router = express.Router();

// Get all events
// Get all events
router.get('/', authenticateUser, async (req, res) => {
  try {
    const events = await Event.find().sort({ startTime: 1 }).populate({
      path: 'comments',
      populate: {
        path: 'createdBy', // Populate the creator of each comment
        select: 'name email', // Select fields to populate
      }}) .populate({
        path: 'sharedWith', // Populate participants
        select: 'name email', // Include participant name and email
      }); // Populate comments
     // Sort by start time (earliest first)
    res.status(200).json(events);
  } catch (err) {
    res.status(500).json({ message: `Error fetching events: ${err.message}` });
  }
});

// Create a new event
router.post('/', authenticateUser, async (req, res) => {
  const { title, description, startTime, endTime, participants, sharedWith } = req.body;

  if (!title || !startTime || !endTime) {
    return res.status(400).json({ message: 'Title, start time, and end time are required.' });
  }

  try {
    const newEvent = new Event({
      title,
      description,
      startTime,
      endTime,
      participants,
      sharedWith,
      ownerId: req.user._id, // Use the authenticated user's ID for ownerId
    });

    await newEvent.save();
    console.log('pratiertete2')

    const users = await User.find({ _id: { $in: participants } });
console.log('Users fetched:', users); // Check if users are fetched correctly
const fcmTokens = users.map(user => user.fcmTokens).flat().filter(token => token);
console.log('FCM Tokens:', fcmTokens); // Ch
 
     // Notify participants about the new event
     const notificationTitle = `New Event: ${title}`;
     const notificationBody = description || 'You have been invited to an event!';
    //  if (fcmTokens.length > 0) {
      sendNotification(fcmTokens, notificationTitle, notificationBody);
    console.log('pratiertete')

    //  }
     // Schedule a reminder 10 minutes before the event starts
     const reminderTime = new Date(new Date(startTime).getTime() - 10 * 60 * 1000); // 10 minutes before
     const currentTime = new Date();
 
     if (reminderTime > currentTime) {
       const cronExpression = `${reminderTime.getMinutes()} ${reminderTime.getHours()} ${reminderTime.getDate()} ${reminderTime.getMonth() + 1} *`;
       cron.schedule(cronExpression, async () => {
         const reminderTitle = `Reminder: ${title}`;
         const reminderBody = `Your event "${title}" is starting soon.`;
       await  sendNotification(fcmTokens, reminderTitle, reminderBody);
       });
     }
    res.status(201).json(newEvent);
  } catch (err) {
    res.status(400).json({ message: `Error  creating event: ${err.message}` });
  }
});

// Update an event
router.patch('/:id', async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);
    if (req.body.title) {
      event.title = req.body.title;
    }
    if (req.body.description) {
      event.description = req.body.description;
    }
    if (req.body.startTime) {
      event.startTime = req.body.startTime;
    }
    if (req.body.endTime) {
      event.endTime = req.body.endTime;
    }
    const updatedEvent = await event.save();
    res.json(updatedEvent);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Delete an event
router.delete('/:id', async (req, res) => {
  try {
    await Event.findByIdAndDelete(req.params.id);
    res.json({ message: 'Event deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
})

// Helper function to send notifications
const sendNotification = async (tokens, title, body) => {
  console.log('tdhtfygukhjn')
 
    if (tokens.length > 0) {
      const message = {
        notification: { title, body },
        tokens,
      };
      console.log('Sending message:', message);
      admin
      .messaging()
      .sendEachForMulticast(message)
      .then((response) => {
        console.log(`${response.successCount} messages were sent successfully`);
        console.log(`${response.failureCount} messages failed to send`);
    
        response.responses.forEach((res, index) => {
          if (res.success) {
            console.log(`Notification sent successfully to token: ${tokens[index]}`);
          } else {
            console.error(
              `Failed to send notification to token: ${tokens[index]}, Error: ${res.error.message}`
            );
          }
        });
      })
      .catch((error) => {
        console.error('Error sending notifications:', error);
      });
    }
};


export default router;

