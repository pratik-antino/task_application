// notificationRoutes.js
import express from 'express';
import admin from '../firebaseService.js';
import User from '../models/User.js';  // Your user model to access FCM tokens
import { authenticateUser } from '../middleware/auth.js'; // A middleware to check if the user is authenticated

const router = express.Router();

// Route to send a push notification to a user
router.post('/send-notification', authenticateUser, async (req, res) => {
  const { userId, title, body } = req.body;  // Data for notification (to be sent from frontend)

  try {
    // Find the user from the database
    console.log('scheduling')
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Check if the user has any FCM tokens
    if (user.fcmTokens.length === 0) {
      return res.status(400).json({ message: 'User does not have an FCM token' });
    }

    // Prepare message payload for FCM
    const message = {
      notification: {
        title: title,
        body: body,
      },
      tokens: user.fcmTokens,  // Send notification to the user's registered FCM tokens
    };

    // Send push notification using Firebase Admin SDK
    const response = await admin.messaging().sendMulticast(message);

    // Handle failure of sending notification to some tokens
    if (response.failureCount > 0) {
      console.log('Failed tokens:', response.responses.filter(res => !res.success));
    }

    res.status(200).json({ message: 'Notification sent successfully', response });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error occurred while sending notification' });
  }
});

export default router;
