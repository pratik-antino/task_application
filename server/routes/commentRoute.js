import express from 'express';
import Comment from '../models/comment.js';
import Task from "../models/task.js";
import { authenticateUser } from '../middleware/auth.js';

const router = express.Router();

// Add a comment to a task
router.post('/:taskId',authenticateUser, async (req, res) => {
  try {
    const { taskId } = req.params;
    const { content } = req.body;

    // Validate task existence
    const task = await Task.findById(taskId);
    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    // Create comment
    const comment = new Comment({
      content,
      taskId,
      createdBy: req.user._id,
    });
    await comment.save();

    // Add comment to task
    task.comments.push(comment._id);
    await task.save();

    res.status(201).json(comment);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get all comments for a task
router.get('/:taskId', authenticateUser, async (req, res) => {
  try {
    const { taskId } = req.params;

    // Fetch comments for the task
    const comments = await Comment.find({ taskId }).populate('createdBy', 'name email');

    res.json(comments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete a comment
router.delete('/:id', authenticateUser, async (req, res) => {
  try {
    const { id } = req.params;

    const comment = await Comment.findById(id);
    if (!comment) {
      return res.status(404).json({ message: 'Comment not found' });
    }

    // Only allow the comment creator to delete
    if (comment.createdBy.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Unauthorized action' });
    }

    // Remove comment from the task
    await Task.updateOne(
      { _id: comment.taskId },
      { $pull: { comments: comment._id } }
    );

    await comment.remove();
    res.json({ message: 'Comment deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
