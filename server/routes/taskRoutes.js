import express from 'express';
import Task from "../models/task.js";
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

// Get tasks created by or assigned to the authenticated user
router.get('/', authenticateUser, async (req, res) => {
  try {
    // Fetch tasks where the authenticated user is either the creator or the assignee
    const tasks = await Task.find({
      $or: [
        { createdBy: req.user._id }, // Tasks created by the user
        { assignedTo: req.user._id } // Tasks assigned to the user
      ]
    })
    .populate('assignedTo', 'name email') // Populate the assigned user's details
    .populate('createdBy', 'name email'); // Populate the creator's details

    res.json(tasks);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch tasks', error: error.message });
  }
});

// ete a task
router.delete('/:id', async (req, res) => {
  try {
    const deletedTask = await Task.findByIdAndDelete(req.params.id);
    if (!deletedTask) {
      return res.status(404).json({ message: 'Task not found' });
    }
    res.json({ message: 'Task deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Update a task
router.patch('/:id', async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);
    if (req.body.title) {
      task.title = req.body.title;
    }
    if (req.body.description) {
      task.description = req.body.description;
    }
    if (req.body.isCompleted !== undefined) {
      task.isCompleted = req.body.isCompleted;
    }
    const updatedTask = await task.save();
    res.json(updatedTask);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});
export default router;

