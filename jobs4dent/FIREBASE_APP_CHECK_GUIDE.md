# How to Register Firebase App Check Debug Token

Since you are running the app on an Emulator (or a physical device in debug mode), Firebase App Check blocks the connection by default because it doesn't look like a "legitimate" version of your app from the Play Store. To fix this, you need to tell Firebase that this specific emulator is safe to access your database.

## Prerequisites
*   Keep your debug console open where you saw the error logs.
*   You need the **Debug Token** from your logs.
    *   *Look for a line like this in your logs:*
        `Enter this debug secret into the allow list in the Firebase Console for your project: c7fbd624-531f-47a8-9b1c-48363f0f53bf`
    *   (Note: The token changes if you wipe the emulator or run on a different device).

## Step-by-Step Instructions

1.  **Open Firebase Console**
    *   Go to [https://console.firebase.google.com/](https://console.firebase.google.com/)
    *   Sign in with your Google account.

2.  **Select Your Project**
    *   Click on your project name (e.g., **flutter-jobs4dent**).

3.  **Navigate to App Check**
    *   On the left-side menu, look for the **Build** section.
    *   Click on **App Check**.

4.  **Go to the "Apps" Tab**
    *   You will see a few tabs like "Product", "Apps", "Token Usage".
    *   Click on the **Apps** tab.

5.  **Expand Your Android App**
    *   Locate your Android app in the list (Package Name: `com.jobs4dent.jobs4dent2`).
    *   Click on the name or the arrow to expand its details.

6.  **Manage Debug Tokens**
    *   On the right side of the expanded row, you will see a button (or 3 dots menu) that usually says **Manage debug tokens**. Click it.
    *   *Note: If you haven't set up Play Integrity yet, it might ask you to register; ignore that for now and look specifically for "Manage debug tokens" menu.*

7.  **Add Your Token**
    *   A popup window will appear title "Manage debug tokens".
    *   Click the **Add debug token** button.
    *   **Name**: Give it a name to remember (e.g., `My Mac Emulator` or `Android Studio Debug`).
    *   **Value**: Paste the UUID you copied from the logs (e.g., `c7fbd624-531f-47a8-9b1c-48363f0f53bf`).

8.  **Save**
    *   Click **Save**.
    *   Wait about 30 seconds for changes to propagate.

9.  **Restart Your App**
    *   Stop the app in your terminal/IDE.
    *   Run `flutter run` or `flutter build apk --debug` again.
    *   The 403 error should disappear, and you should see successful Firestore/Storage operations.
