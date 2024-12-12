import express from 'express';
import eventComment from '../models/eventComment.js';
import Event from '../models/event.js';
import { authenticateUser } from '../middleware/auth.js';

const router = express.Router();

// Add a comment to an event
router.post('/:eventId', authenticateUser, async (req, res) => {
  try {
    const { eventId } = req.params;
    const { content } = req.body;

    // Validate event existence
    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    // Create comment
    const comment = new eventComment({
      content,
      eventId,
      createdBy: req.user._id,
    });
    await comment.save();
    event.comments.push(comment._id)
   await  event.save();

    res.status(201).json(comment);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get all comments for an event
router.get('/:eventId', authenticateUser, async (req, res) => {
  try {
    const { eventId } = req.params;

    // Fetch comments for the event
    const comments = await Comment.find({ eventId }).populate('createdBy', 'name email');

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

    await comment.remove();
    res.json({ message: 'Comment deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
