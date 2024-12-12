import mongoose from 'mongoose';

const eventSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Event title is required'],
  },
  description: {
    type: String,
    default: '',
  },
  startTime: {
    type: Date,
    required: [true, 'Start time is required'],
  },
  endTime: {
    type: Date,
    required: [true, 'End time is required'],
  },
  participants: {
    type: [String], // Array of participant email strings
    default: [],
  },
  sharedWith: {
    type: [mongoose.Schema.Types.ObjectId], // Array of user IDs the event is shared with
    ref: 'User',
    default: [],
  },
  ownerId: {
    type: mongoose.Schema.Types.ObjectId, // Owner of the event
    ref: 'User',
    required: [true, 'Owner ID is required'],
  },
  comments: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'eventComment',
    },
  ],
}, { timestamps: true }); // Automatically adds `createdAt` and `updatedAt` fields

const Event = mongoose.model('Event', eventSchema);
export default Event;
