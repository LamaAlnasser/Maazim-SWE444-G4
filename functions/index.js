/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendEditNotification = functions.firestore
  .document('events/{eventId}')
  .onUpdate(async (change, context) => {
    const eventData = change.after.data();
    const inviteesTokens = eventData.inviteesTokens; // Ensure this aligns with your data structure

    const message = {
      notification: {
        title: 'Event Updated',
        body: `${eventData.eventName} has been updated. Check out the new details!`
      },
      tokens: inviteesTokens,
    };

    try {
      const response = await admin.messaging().sendMulticast(message);
      console.log('Notification sent successfully:', response);
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  });

exports.sendDeleteEventNotification = functions.firestore
  .document('events/{eventId}')
  .onDelete(async (snap, context) => {
    const eventData = snap.data();
    const inviteesTokens = eventData.inviteesTokens; // Ensure this aligns with your data structure

    const message = {
      notification: {
        title: 'Event Cancelled',
        body: 'An event you were invited to has been cancelled.'
      },
      tokens: inviteesTokens,
    };

    try {
      const response = await admin.messaging().sendMulticast(message);
      console.log('Successfully sent notification:', response);
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  });
