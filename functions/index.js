/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

const functions = require("firebase-functions");
const Twilio = require("twilio");

const accountSid = "AC6062ac6f9c9ed84ba439f92a1dc057c1";
const authToken = "7a47cb13710fc867129357aba3801352";
const client = new Twilio(accountSid, authToken);

exports.sendSMS = functions.https.onCall((data, context) => {
  return client.messages
      .create({
        body: data.message,
        to: data.to, // Text this number
        from: "+19497102088", // From a valid Twilio number
      })
      .then((message) => {
        console.log(message.sid);
        return {success: true};
      })
      .catch((error) => {
        console.error(error);
        return {success: false};
      });
});


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
