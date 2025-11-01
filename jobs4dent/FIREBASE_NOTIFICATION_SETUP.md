# Firebase Push Notifications Setup Guide

This guide will help you set up Firebase Cloud Messaging (FCM) for sending push notifications to clinic mobile phones when dentists apply for jobs.

## Prerequisites

- Firebase project already set up for your app
- Firebase CLI installed
- Node.js installed (for Cloud Functions)

## Step 1: Enable Firebase Cloud Messaging

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project (`flutter-jobs4dent`)
3. Navigate to **Project Settings** > **Cloud Messaging**
4. Enable **Cloud Messaging API** if not already enabled

## Step 2: Set Up Cloud Functions for Sending Notifications

### 2.1 Install Firebase CLI

**Option A: Using npx (Recommended - No installation required)**

```bash
# Use npx to run firebase-tools without global installation
npx firebase-tools --version
```

**Option B: Install globally with sudo (if you prefer)**

```bash
sudo npm install -g firebase-tools
```

**Option C: Fix npm permissions (Alternative)**

```bash
# Create a directory for global packages
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
npm install -g firebase-tools
```

### 2.2 Initialize Cloud Functions

```bash
# Navigate to your project root
cd /path/to/jobs4dent

# Initialize Firebase Functions (if not already done)
# If using npx, prefix commands with "npx"
npx firebase-tools init functions

# Or if installed globally:
firebase init functions

# Select:
# - Use an existing project: flutter-jobs4dent
# - Language: JavaScript or TypeScript (recommended: TypeScript)
# - ESLint: Yes
# - Install dependencies: Yes
```

### 2.2 Install Required Dependencies

```bash
cd functions
npm install firebase-admin
npm install firebase-functions
# If using TypeScript
npm install --save-dev @types/node typescript
```

### 2.3 Create the Cloud Function

Create or update `functions/index.js` (or `functions/index.ts` for TypeScript):

#### JavaScript Version (`functions/index.js`):

```javascript
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Cloud Function to send push notifications when a dentist applies for a job
 * Called from the Flutter app via HTTPS callable function
 */
exports.sendJobApplicationNotification = functions.https.onCall(
  async (data, context) => {
    // Verify that the user is authenticated
    if (!context.auth) {
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
          ...notificationData,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        // Send to multiple devices
        tokens: deviceTokens,
      };

      // Send the notification
      const response = await admin.messaging().sendEachForMulticast(message);

      console.log(
        `Successfully sent message: ${response.successCount} successful, ${response.failureCount} failed`
      );

      // Handle failed tokens (optional: remove invalid tokens)
      if (response.failureCount > 0) {
        const failedTokens = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            console.error(
              `Failed to send to token ${deviceTokens[idx]}: ${resp.error}`
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
```

#### TypeScript Version (`functions/src/index.ts`):

```typescript
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

export const sendJobApplicationNotification = functions.https.onCall(
  async (data: NotificationRequest, context) => {
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
              `Failed to send to token ${deviceTokens[idx]}: ` + `${resp.error}`
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
```

**Note:** If you're using TypeScript, the file should be in `functions/src/index.ts` (not `functions/index.ts`). The TypeScript compiler will build it to `functions/lib/index.js`.

### 2.4 Deploy the Cloud Function

```bash
# If using npx, prefix commands with "npx firebase-tools"
# Deploy all functions
npx firebase-tools deploy --only functions

# Or if installed globally:
firebase deploy --only functions

# Or deploy only this function
npx firebase-tools deploy --only functions:sendJobApplicationNotification
# Or: firebase deploy --only functions:sendJobApplicationNotification
```

## Step 3: Update Firestore Security Rules

Add rules to allow users to read their device tokens. The rules should be added to the **`firestore.rules`** file in your project root directory (not a JavaScript file - it's a special Firestore rules format file).

**File location:** `firestore.rules` (in the root of your project)

Add the following rules to your `firestore.rules` file:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read their own document (including deviceTokens)
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Allow Cloud Functions to read user documents
    match /users/{userId} {
      allow read: if request.auth.token.admin == true;
    }

    // Notifications collection
    match /notifications/{notificationId} {
      allow read: if request.auth != null &&
                     resource.data.clinicId == request.auth.uid;
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
                       resource.data.clinicId == request.auth.uid;
    }
  }
}
```

**Note:** This is not a JavaScript file, but a Firestore Security Rules file with `.rules` extension. The syntax is similar to JavaScript but specific to Firestore security rules.

Deploy the rules:

```bash
# If using npx:
npx firebase-tools deploy --only firestore:rules

# Or if installed globally:
firebase deploy --only firestore:rules
```

## Step 4: Set Up Device Token Collection in Flutter App

You need to collect and store device tokens when users log in. Create a helper class or add to your auth service:

### 4.1 Add Device Token to User Document Structure

The `users` collection should have a `deviceTokens` array field:

```javascript
{
  userId: "user123",
  email: "clinic@example.com",
  userType: "clinic",
  deviceTokens: ["token1", "token2"], // Array of FCM tokens
  lastDeviceTokenUpdate: Timestamp
}
```

### 4.2 How to Get FCM Tokens

**FCM Token Overview:**
An FCM (Firebase Cloud Messaging) token is a unique identifier for each device installation. It's required to send push notifications to that specific device. The token:

- Is generated automatically by Firebase when the app requests it
- Is unique per app installation per device
- Can change (e.g., when app is reinstalled, app data is cleared, or token is refreshed)
- Must be stored in Firestore to send notifications to that device

**When to Get the Token:**
You should retrieve and save the FCM token:

1. **After user successfully logs in** - Once authenticated, get the token for that user's device
2. **When the app starts** - If user is already logged in, retrieve the token on app startup
3. **When token refreshes** - Listen for token refresh events and update Firestore

**Step-by-Step Process:**

1. **Request Permission (iOS only):**

   - iOS requires explicit permission to show notifications
   - Android automatically grants permission (for apps targeting API 33+ you may need to request)

2. **Get the Token:**

   - Call `FirebaseMessaging.instance.getToken()`
   - This returns a `String?` - the FCM token for this device
   - The token is a long string that looks like: `"dX7k...example...token"`

3. **Save Token to Firestore:**

   - Store the token in the user's document in the `deviceTokens` array
   - Use the `NotificationService.saveDeviceToken()` method (already implemented)

4. **Handle Token Refresh:**
   - FCM tokens can refresh periodically
   - Listen to `onTokenRefresh` stream to update Firestore when token changes

### 4.3 Initialize Firebase Messaging in Flutter

**Recommended Implementation:**

Create a helper method or add this to your `AuthProvider` or a dedicated notification initialization service. Here's where and how to implement it:

**Option A: In AuthProvider (Recommended)**

Add this to your `lib/providers/auth_provider.dart` after successful login:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';

// Add this method to AuthProvider class
Future<void> initializeFCMToken() async {
  try {
    final messaging = FirebaseMessaging.instance;

    // Request permission for iOS
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false, // Set to true if you want provisional authorization (iOS 12+)
    );

    debugPrint('📱 FCM Permission status: ${settings.authorizationStatus}');

    // Check if permission is granted
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {

      // Get the FCM token for this device
      String? token = await messaging.getToken();

      if (token != null && _userModel != null) {
        debugPrint('📱 FCM Token retrieved: ${token.substring(0, 20)}...');

        // Save token to Firestore
        final notificationService = NotificationService();
        await notificationService.saveDeviceToken(
          userId: _userModel!.userId,
          deviceToken: token,
        );

        debugPrint('✅ FCM Token saved to Firestore');
      } else if (token == null) {
        debugPrint('⚠️ FCM Token is null');
      } else {
        debugPrint('⚠️ User model is null, cannot save token');
      }

      // Listen for token refresh events
      // When token changes (e.g., app reinstall, token rotation), update Firestore
      messaging.onTokenRefresh.listen((String newToken) async {
        debugPrint('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');

        if (_userModel != null) {
          final notificationService = NotificationService();
          await notificationService.saveDeviceToken(
            userId: _userModel!.userId,
            deviceToken: newToken,
          );
          debugPrint('✅ Refreshed FCM Token saved to Firestore');
        }
      });
    } else {
      debugPrint('❌ Notification permission not granted: ${settings.authorizationStatus}');
    }
  } catch (e) {
    debugPrint('❌ Error initializing FCM token: $e');
  }
}
```

Then call this method after successful authentication:

```dart
// In AuthProvider, after successful login (e.g., in signInWithEmail, signInWithGoogle)
Future<bool> signInWithEmail({...}) async {
  // ... existing sign-in logic ...

  if (authResult.success) {
    await _loadUserModel();

    // Initialize FCM token after user is authenticated
    await initializeFCMToken();

    // ... rest of the code ...
  }
}
```

**Option B: In main.dart (Alternative)**

If you prefer to initialize in `main.dart`, add this:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'services/notification_service.dart';

Future<void> initializeNotifications() async {
  final messaging = FirebaseMessaging.instance;

  // Request permission for iOS
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    // Get the FCM token
    String? token = await messaging.getToken();

    if (token != null) {
      debugPrint('📱 FCM Token: $token');
      // Note: You'll need access to AuthProvider here to get userId
      // This is why Option A (in AuthProvider) is recommended
    }

    // Listen for token refresh
    messaging.onTokenRefresh.listen((String newToken) {
      debugPrint('🔄 FCM Token refreshed: $newToken');
      // Update token in Firestore
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Note: Only call this if user is already logged in
  // Otherwise, call it after login in AuthProvider

  runApp(const Jobs4DentApp());
}
```

**Important Notes:**

1. **Token Format:** The FCM token is a string that typically looks like:

   ```
   "dX7k_AbC123XyZ...example_token...789mNqR"
   ```

   It's usually 100+ characters long.

2. **Token Storage:** The token is stored in Firestore as part of an array:

   ```json
   {
     "deviceTokens": ["token1", "token2", "token3"]
   }
   ```

   Multiple tokens allow sending notifications to multiple devices for the same user.

3. **When Token Changes:**

   - App is reinstalled
   - App data is cleared
   - Firebase rotates tokens for security
   - Device is restored from backup (iOS)
   - Token expires (rare, but possible)

4. **Testing:**
   - Print the token to console to verify it's being retrieved
   - Check Firestore to confirm token is saved in `deviceTokens` array
   - Use Firebase Console > Cloud Messaging > Send test message with the token

## Step 5: Handle Notifications in Flutter App

Add notification handlers in your `main.dart`:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

// In your app initialization:
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Got a message whilst in the foreground!');
  print('Message data: ${message.data}');

  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
    // Show local notification or update UI
  }
});

FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  print('A new onMessageOpenedApp event was published!');
  // Navigate to relevant screen based on notification data
});
```

## Step 6: Android Configuration

### 6.1 Update `android/app/build.gradle`

Ensure you have the Google Services plugin:

```gradle
dependencies {
    // ... other dependencies
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

### 6.2 Create/Update Notification Channel (Optional but Recommended)

Add to your `AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="job_applications" />
```

## Step 7: iOS Configuration

### 7.1 Enable Push Notifications Capability

1. Open your project in Xcode
2. Select your app target
3. Go to **Signing & Capabilities**
4. Click **+ Capability**
5. Add **Push Notifications**
6. Add **Background Modes** and enable **Remote notifications**

### 7.2 Update `ios/Runner/Info.plist`

Add notification permissions:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

### 7.3 Get APNs Authentication Key (for production)

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Go to **Keys** and create a new key
4. Enable **Apple Push Notifications service (APNs)**
5. Download the `.p8` file
6. Upload to Firebase Console under **Project Settings** > **Cloud Messaging** > **Apple app configuration**

## Step 8: Testing

1. **Test Cloud Function:**

```bash
# If using npx:
npx firebase-tools functions:shell

# Or if installed globally:
firebase functions:shell
```

Then call the function:

```javascript
sendJobApplicationNotification({
  clinicId: "test-clinic-id",
  deviceTokens: ["test-device-token"],
  title: "Test Notification",
  body: "This is a test",
  data: { type: "test" },
});
```

2. **Test from Flutter App:**
   - Apply for a job as a dentist
   - Check clinic user's device for notification
   - Verify notification appears and opens the correct screen

## Step 9: Firestore Indexes (if needed)

If you query notifications, you may need to create indexes:

```bash
# If using npx:
npx firebase-tools deploy --only firestore:indexes

# Or if installed globally:
firebase deploy --only firestore:indexes
```

## Troubleshooting

### Common Issues:

1. **Notifications not received:**

   - Check device token is saved in Firestore
   - Verify Cloud Function is deployed
   - Check Cloud Function logs:
     ```bash
     npx firebase-tools functions:log
     # Or: firebase functions:log
     ```
   - Ensure app has notification permissions

2. **Cloud Function errors:**

   - Check Firebase Console > Functions > Logs
   - Verify FCM service account has proper permissions
   - Ensure device tokens are valid
   - Test function locally:
     ```bash
     npx firebase-tools functions:shell
     # Or: firebase functions:shell
     ```

3. **iOS notifications not working:**

   - Verify APNs certificate/key is uploaded
   - Check app capabilities are enabled
   - Test with a physical device (not simulator)

4. **Android notifications not working:**
   - Ensure Google Play Services is updated
   - Check `google-services.json` is in place
   - Verify notification channel is created

## Additional Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Firebase Cloud Functions Documentation](https://firebase.google.com/docs/functions)
- [FlutterFire Messaging Plugin](https://firebase.flutter.dev/docs/messaging/overview)

## Security Notes

- Device tokens are sensitive data - ensure Firestore rules prevent unauthorized access
- Cloud Functions validate authentication before sending notifications
- Consider rate limiting for notification sending
- Implement token cleanup to remove invalid/old tokens

- Consider rate limiting for notification sending
- Implement token cleanup to remove invalid/old tokens
