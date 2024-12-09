import express from 'express';
import Task from "../models/task.js";
import User from '../models/User.js';
import { authenticateUser } from '../middleware/auth.js';
import cron from 'node-cron';
import admin from 'firebase-admin';

const router = express.Router();

// Create a new task
router.post('/', authenticateUser, async (req, res) => {
  try {
    const { title, description, assignedTo, priority, status, dueDate } = req.body;

    // Check if the assigned user exists
    const assignedUser = await User.findById(assignedTo);
    if (!assignedUser) {
      return res.status(400).json({ message: 'Assigned user not  found' });
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


     // Populate the assignedTo field to get the FCM token
     const fcmTokens = assignedUser.fcmTokens.filter(token => token);

     // Send notification to assignee
     const notificationTitle = `New Task: ${title}`;
     const notificationBody = description || 'You have been assigned a new task!';
     sendNotification(fcmTokens, notificationTitle, notificationBody);
 
     // Schedule a reminder 10 minutes before the due date
     const reminderTime = new Date(new Date(dueDate).getTime() - 10 * 60 * 1000); // 10 minutes before the due date
     const currentTime = new Date();
 
     if (reminderTime > currentTime) {
       const cronExpression = `${reminderTime.getMinutes()} ${reminderTime.getHours()} ${reminderTime.getDate()} ${reminderTime.getMonth() + 1} *`;
       cron.schedule(cronExpression, async () => {
         const reminderTitle = `Reminder: ${title}`;
         const reminderBody = `Your task "${title}" is due soon.`;
         sendNotification(fcmTokens, reminderTitle, reminderBody);
       });
     }
  // Send overdue alerts if the task is overdue
  const overdueTime = new Date(new Date(dueDate).getTime());
  const overdueCronExpression = `${overdueTime.getMinutes()} ${overdueTime.getHours()} ${overdueTime.getDate()} ${overdueTime.getMonth() + 1} *`;
  cron.schedule(overdueCronExpression, async () => {
    const overdueTitle = `Overdue Task: ${title}`;
    const overdueBody = `The task "${title}" is overdue. Please complete it as soon as possible.`;
    sendNotification(fcmTokens, overdueTitle, overdueBody);
  });

  
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

router.post('/register-fcm-token', authenticateUser, async (req, res) => {
  const { fcmToken } = req.body;

  try {
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (!user.fcmTokens.includes(fcmToken)) {
      user.fcmTokens.push(fcmToken);
      await user.save();
    }

    res.status(200).json({ message: 'FCM token registered successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Helper function to send notifications
const sendNotification = async (tokens, title, body) => {
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
            console.error(`Failed to send notification to token: ${tokens[index]}, Error: ${res.error.message}`);
          }
        });
      })
      .catch((error) => {
        console.error('Error sending notifications:', error);
      });
  }
};

export default router;

