import mongoose from 'mongoose';

const eventCommentSchema = new mongoose.Schema(
  {
    content: {
      type: String,
      required: [true, 'Comment content is required'],
    },
    eventId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Event',
      required: [true, 'Event ID is required'],
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'User ID is required'],
    },
  },
  { timestamps: true } // Automatically adds `createdAt` and `updatedAt` fields
);

const eventComment = mongoose.model('eventComment', eventCommentSchema);
export default eventComment;
