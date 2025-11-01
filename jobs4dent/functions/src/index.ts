/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

admin.initializeApp();

interface NotificationRequest {
  clinicId: string;
  deviceTokens: string[];
  title?: string;
  body?: string;
  data?: Record<string, string>;
}

/**
 * Cloud Function to send push notifications when a dentist applies for a job
 * Called from the Flutter app via HTTPS callable function
 * Region set to asia-southeast1 to match Firestore location
 */
export const sendJobApplicationNotification = functions
  .region("asia-southeast1")
  .https.onCall(async (data: NotificationRequest, context) => {
    // Verify that the user is authenticated
    if (!context || !context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "The function must be called while authenticated."
      );
    }

    const {
      clinicId,
      deviceTokens,
      title,
      body,
      data: notificationData,
    } = data;

    // Validate input
    if (
      !clinicId ||
      !deviceTokens ||
      !Array.isArray(deviceTokens) ||
      deviceTokens.length === 0
    ) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "clinicId and deviceTokens (non-empty array) are required."
      );
    }

    try {
      // Prepare the notification payload
      const message = {
        notification: {
          title: title || "มีผู้สมัครงานใหม่",
          body: body || "มีผู้สมัครงานใหม่สำหรับงานของคุณ",
        },
        data: {
          ...(notificationData || {}),
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        } as Record<string, string>,
        // Send to multiple devices
        tokens: deviceTokens,
      };

      // Send the notification
      const response = await admin.messaging().sendEachForMulticast(message);

      console.log(
        `Successfully sent message: ${response.successCount} successful, ` +
        `${response.failureCount} failed`
      );

      // Handle failed tokens (optional: remove invalid tokens)
      if (response.failureCount > 0) {
        const failedTokens: string[] = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            console.error(
              `Failed to send to token ${deviceTokens[idx]}: ` +
              `${resp.error}`
            );
            failedTokens.push(deviceTokens[idx]);
          }
        });
      }

      return {
        success: true,
        successCount: response.successCount,
        failureCount: response.failureCount,
      };
    } catch (error) {
      console.error("Error sending notification:", error);
      throw new functions.https.HttpsError(
        "internal",
        "An error occurred while sending the notification.",
        error
      );
    }
  }
  );
