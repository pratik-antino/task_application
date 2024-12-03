const express = require('express');
const router = express.Router();
const Event = require('../models/event');

// Get all events
router.get('/', async (req, res) => {
  try {
    const events = await Event.find();
    res.json(events);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Create a new event
router.post('/', async (req, res) => {
  const event = new Event({
    title: req.body.title,
    description: req.body.description,
    startTime: req.body.startTime,
    endTime: req.body.endTime,
  });

  try {
    const newEvent = await event.save();
    res.status(201).json(newEvent);
  } catch (err) {
    res.status(400).json({ message: err.message });
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

module.exports = router;

