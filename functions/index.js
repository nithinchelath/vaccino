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

exports.scheduleNotification = functions.firestore
    .document('bookings/{bookingId}')
    .onCreate(async (snap, context) => {
      const bookingData = snap.data();
      const bookedDate = new Date(bookingData.date);
      const notificationDate = new Date(bookedDate.getTime() - 24 * 60 * 60 * 1000); // One day before

      // Schedule a notification
      const payload = {
        notification: {
          title: 'Reminder for Your Vaccination',
          body: `You have a booking for ${bookingData.vaccineName} on ${bookingData.date} at ${bookingData.timeSlot} at ${bookingData.center}.`,
        },
        token: bookingData.userId, // Assuming you have the user's FCM token
      };

      // Schedule the notification
      return admin.messaging().send(payload);
    });


    const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.deleteOldConsultations = functions.pubsub.schedule('every 5 minutes').onRun(async (context) => {
  const now = admin.firestore.Timestamp.now();
  const nextDay = new admin.firestore.Timestamp(now.seconds + 86400, now.nanoseconds); // 86400 seconds in a day

  const query = admin.firestore().collection('consultations').where('date', '<=', nextDay);
  const batch = admin.firestore().batch();

  const snapshot = await query.get();
  snapshot.docs.forEach(doc => {
    batch.delete(doc.ref);
  });

  await batch.commit();
  console.log(`Deleted ${snapshot.docs.length} old consultations.`);
});
