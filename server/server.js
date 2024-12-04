import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import dotenv from 'dotenv';
import taskRoutes from './routes/taskRoutes.js';
import userRoutes from './routes/userRoutes.js';
import meetingRoutes from './routes/meetingRoutes.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

mongoose.connect("mongodb+srv://pratik-16:pratik-16@pratikcluster.bgr4e.mongodb.net/task_maangement_data?retryWrites=true&w=majority&appName=PratikCluster")
.then(() => console.log('Connected to MongoDB'))
.catch((error) => console.error('MongoDB connection error:', error));

app.use('/api/tasks', taskRoutes);
app.use('/api/users', userRoutes);
app.use('/api/meetings', meetingRoutes);

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

