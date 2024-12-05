import express from 'express';
import Event from '../models/event.js';
import { authenticateUser } from '../middleware/auth.js';

const router = express.Router();

// Get all events
// Get all events
router.get('/', authenticateUser, async (req, res) => {
  try {
    const events = await Event.find().sort({ startTime: 1 }); // Sort by start time (earliest first)
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
    res.status(201).json(newEvent);
  } catch (err) {
    res.status(400).json({ message: `Error creating event: ${err.message}` });
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
});

export default router;

