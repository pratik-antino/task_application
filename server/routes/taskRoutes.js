import express from 'express';
import Task from '../models/Task.js';
import User from '../models/User.js';
import { authenticateUser } from '../middleware/auth.js';

const router = express.Router();

// Create a new task
router.post('/', authenticateUser, async (req, res) => {
  try {
    const { title, description, assignedTo, priority, status, dueDate } = req.body;

    // Check if the assigned user exists
    const assignedUser = await User.findById(assignedTo);
    if (!assignedUser) {
      return res.status(400).json({ message: 'Assigned user not found' });
    }

    const task = new Task({
      title,
      description,
      assignedTo,
      createdBy: req.user._id,
      priority,
      status,
      dueDate: new Date(dueDate),
    });

    await task.save();

    // Populate the assignedTo and createdBy fields
    await task.populate('assignedTo', 'name email');
    await task.populate('createdBy', 'name email');

    res.status(201).json(task);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Get all tasks
router.get('/', authenticateUser, async (req, res) => {
  try {
    const tasks = await Task.find({ $or: [{ assignedTo: req.user._id }, { createdBy: req.user._id }] })
      .populate('assignedTo', 'name email')
      .populate('createdBy', 'name email');
    res.json(tasks);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;

