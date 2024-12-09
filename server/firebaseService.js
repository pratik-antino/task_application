import admin from 'firebase-admin';
import { readFileSync } from 'fs';
import path from 'path';

// Define the path to your service account key file
const serviceAccountPath = path.resolve('C:/task_application/server/serviceAccountKey.json');

// Parse the service account key JSON file
const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf8'));

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  try {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    console.log('Firebase Admin initialized successfully');
  } catch (error) {
    console.error('Error initializing Firebase Admin:', error.message);
  }
} else {
  console.log('Firebase Admin is already initialized');
}

export default admin;
