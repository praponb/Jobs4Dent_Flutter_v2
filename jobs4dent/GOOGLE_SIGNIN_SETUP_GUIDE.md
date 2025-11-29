# Google Sign-In Setup and Troubleshooting Guide

This document covers the complete setup process for Google Sign-In and how to fix the common `ApiException: 10` error.

## Understanding ApiException: 10

This error occurs when:
- The SHA-1 fingerprint of your signing key doesn't match what's registered in Firebase Console
- The package name in your code doesn't match the Firebase app configuration
- The `google-services.json` file is outdated or incorrect

## Complete Setup Steps

### Step 1: Ensure Package Name Consistency

Your package name must be consistent across all configuration files:

1.  **`android/app/build.gradle.kts`**:
    ```kotlin
    android {
        namespace = "com.jobs4dent.jobs4dent"
        
        defaultConfig {
            applicationId = "com.jobs4dent.jobs4dent"
            // ...
        }
    }
    ```

2.  **Firebase Console**: The app must be registered with the same package name

3.  **`lib/firebase_options.dart`**: The `appId` must match the one from `google-services.json` for your package

### Step 2: Get Your SHA-1 Fingerprints

You need different SHA-1 fingerprints depending on the build type:

#### A. Debug SHA-1 (for development with `flutter run`)
```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android
```

Look for the line starting with `SHA1:` and copy the fingerprint.  
Example: `47:7D:92:6B:6A:B3:35:F4:B9:99:3F:7B:5E:81:4A:C8:65:D2:62:46`

#### B. Release SHA-1 (for release builds and AAB uploads)
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

Enter your keystore password, then copy the SHA1 fingerprint.

#### C. Google Play Signing SHA-1 (for apps distributed via Play Store)

After uploading your first AAB to Google Play Console:

1.  Go to **Google Play Console**
2.  Navigate to: **Release** > **Setup** > **App integrity**
3.  Click the **App signing** tab
4.  Copy the **SHA-1 certificate fingerprint** under "App signing key certificate"

### Step 3: Add SHA-1 Fingerprints to Firebase

1.  Open [Firebase Console](https://console.firebase.google.com/)
2.  Select your project
3.  Click the **Settings gear icon** > **Project settings**
4.  Scroll down to **Your apps** section
5.  Select the Android app with your package name (e.g., `com.jobs4dent.jobs4dent`)
6.  Click **Add fingerprint**
7.  Paste the SHA-1 fingerprint
8.  Click **Save**
9.  Repeat for each SHA-1 (Debug, Release, and Google Play if applicable)

**Important**: You should have at least 2 SHA-1 fingerprints added:
- Debug SHA-1 (for development)
- Release SHA-1 or Google Play SHA-1 (for production)

### Step 4: Download Updated google-services.json

After adding SHA-1 fingerprints:

1.  In the same **Project settings** page
2.  Find your Android app
3.  Click the **google-services.json** download button
4.  Replace the file at: `android/app/google-services.json`

### Step 5: Update firebase_options.dart

Ensure your `lib/firebase_options.dart` uses the correct App ID:

```dart
static FirebaseOptions get android => FirebaseOptions(
  apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '',
  appId: '1:693132385676:android:b2581d58b3ea312f890aa9', // Must match google-services.json
  messagingSenderId: '693132385676',
  projectId: 'flutter-jobs4dent',
  storageBucket: 'flutter-jobs4dent.firebasestorage.app',
);
```

The `appId` must match the `mobilesdk_app_id` in `google-services.json` for your package name.

### Step 6: Verify google-services.json

Open `android/app/google-services.json` and find the section with your package name:

```json
{
  "client_info": {
    "mobilesdk_app_id": "1:693132385676:android:b2581d58b3ea312f890aa9",
    "android_client_info": {
      "package_name": "com.jobs4dent.jobs4dent"
    }
  },
  "oauth_client": [
    {
      "client_id": "693132385676-gf05212q88btq3kmpq5ldvl130vt5ueo.apps.googleusercontent.com",
      "client_type": 1,
      "android_info": {
        "package_name": "com.jobs4dent.jobs4dent",
        "certificate_hash": "6a3917e3d11d47cdb372c4e9c608b85ce61f3c1c"
      }
    }
  ]
}
```

✅ Verify:
- The `package_name` matches your build.gradle.kts
- There is an `oauth_client` entry with `"client_type": 1`
- The `certificate_hash` matches one of your SHA-1 fingerprints (without colons)

### Step 7: Clean and Rebuild

```bash
flutter clean
flutter pub get
flutter run
```

### Step 8: Wait for Propagation

Firebase changes can take **5-10 minutes** to propagate. If it still doesn't work immediately:
1.  Wait 10 minutes
2.  Uninstall the app from your device
3.  Reinstall with `flutter run`

## Common Issues and Solutions

### Issue: Still Getting ApiException: 10

**Solutions:**
- ✅ Verify you added SHA-1 to the CORRECT app (check package name)
- ✅ Download `google-services.json` AFTER adding SHA-1
- ✅ Wait 10 minutes for changes to propagate
- ✅ Uninstall and reinstall the app
- ✅ Make sure you're using the right SHA-1 for your build type (debug vs release)

### Issue: Different Package Name in Different Files

Run this command to verify:
```bash
grep -r "applicationId" android/app/build.gradle.kts
```

Should output: `applicationId = "com.jobs4dent.jobs4dent"`

Check that `google-services.json` has the same package name.

### Issue: Running Release Build but Added Debug SHA-1

If you're running with `--release` or testing an APK/AAB, you need the **Release SHA-1** or **Google Play SHA-1**, not the debug one.

## Summary Checklist

- [ ] Package name is consistent everywhere
- [ ] SHA-1 fingerprints added to Firebase (debug and/or release)
- [ ] Downloaded updated `google-services.json` after adding SHA-1
- [ ] `firebase_options.dart` has correct `appId`
- [ ] Waited 5-10 minutes after making changes
- [ ] Cleaned and rebuilt the project
- [ ] Uninstalled and reinstalled the app

## Quick Reference Commands

### Get Debug SHA-1
```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android | grep SHA1
```

### Get Release SHA-1
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload | grep SHA1
```

### Clean and Run
```bash
flutter clean && flutter pub get && flutter run
```

