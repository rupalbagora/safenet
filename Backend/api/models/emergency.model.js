import mongoose from 'mongoose';

// Emergency contact schema
const emergencySchema = mongoose.Schema({
  userEmail: {
    type: String,
    required: [true, 'User email is required'],
    ref: 'user_collection',  // Reference to User model (email will be used instead of userId)
    trim: true,
    lowercase: true,  // Ensure email is always in lowercase
  },
  name: {
    type: String,
    required: [true, 'Name is required'],
    trim: true,
  },
  relation: {
    type: String,
    required: [true, 'Relation is required'],
    trim: true,
  },
  mobile: {
    type: String,
    required: [true, 'Mobile number is required'],
    trim: true,
    minlength: 10,
    maxlength: 10,
  },
  info: {
    type: String,
    default: Date.now,  // Default to the current timestamp
  }
});

// Create the model for Emergency Contact
const emergencySchemaModel = mongoose.model('emergency_collection', emergencySchema);

export default emergencySchemaModel;
