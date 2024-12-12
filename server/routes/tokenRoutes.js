import express from 'express';
import User from '../models/User.js';
import { authenticateUser } from '../middleware/auth.js';

const router = express.Router();
// Save or Update FCM Token
router.post('/save-token', authenticateUser, async (req, res) => {
  try {
    const { fcmToken } = req.body;
    console.log('save token called$fcm');

    if (!fcmToken) {
      return res.status(400).json({ message: 'FCM token is required' });
    }

    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Only add the token if it's not already in the list (case-insensitive check)
    if (!user.fcmTokens.includes(fcmToken)) {
      user.fcmTokens.push(fcmToken);
      await user.save();
      console.log(`Token added: ${fcmToken}`);
    } else {
      console.log(`Token already exists: ${fcmToken}`);
    }

    res.status(200).json({ message: 'FCM token updated successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'An error occurred' });
  }
});

// Retrieve FCM Token for a User
router.get('/get-token/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await User.findOne({ userId });

    if (user && user.fcmToken) {
      return res.status(200).json({ fcmToken: user.fcmToken });
    } else {
      return res.status(404).json({ message: 'User or FCM Token not found' });
    }
  } catch (error) {
    console.error('Error retrieving FCM token:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});


export default router;