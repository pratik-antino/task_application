import express from 'express';
import jwt from 'jsonwebtoken';
import User from '../models/User.js';
import { authenticateUser } from '../middleware/auth.js';

const router = express.Router();

// User signup
router.post('/signup', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    
    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists' });
    }

    const user = new User({ name, email, password });
    await user.save();

    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET);
    res.status(201).json({ user: { id: user._id, name: user.name, email: user.email }, token });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// User login (unchanged)
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log(`Email: ${email}, Password: ${password}`); // Log received data

    const user = await User.findOne({ email });
    if (!user) {
      console.log('User not found');
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const isPasswordCorrect = await user.comparePassword(password);
    if (!isPasswordCorrect) {
      console.log('Incorrect password');
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET,);
    res.json({ user: { id: user._id, name: user.name, email: user.email }, token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'An error occurred' });
  }
});
// Get all users (unchanged)
router.get('/', authenticateUser, async (req, res) => {
  try {
    const users = await User.find({}, 'name email');
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;

