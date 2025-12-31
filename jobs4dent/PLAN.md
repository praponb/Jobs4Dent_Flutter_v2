# Android Compatibility Implementation Plan

## Goal
Ensure Jobs4Dent application is fully compatible with Android 14 (API 34), Android 15, and future-proofed for Android 16.

## Proposed Changes

### 1. Update Gradle Build Configuration
**Files:** `android/app/build.gradle.kts`
*   [ ] Explicitly set `compileSdk = 34` (or `flutter.compileSdkVersion` if verified to be 34).
*   [ ] Ensure `minSdk` is appropriate (e.g., 21 or 23).
*   [ ] Upgrade `ndkVersion` if necessary for Flutter 3.22+ compatibility.

### 2. Update Android Manifest
**File:** `android/app/src/main/AndroidManifest.xml`
*   [ ] Add Granular Media Permissions (Android 13+ support):
    ```xml
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" /> 
    ```
*   [ ] Add Foreground Service Permission (Android 14 requirement):
    *   Since `Geolocator` is used, add `FOREGROUND_SERVICE_LOCATION` to prevent crashes if the service is promoted to foreground.
    ```xml
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
    ```

### 3. Verify Code Logic (Dart)
**File:** `lib/screens/profile/location_picker_screen.dart`
*   [ ] Verify `Geolocator.getCurrentPosition` handles permission denial gracefully on Android 14.
*   [ ] Ensure no background location streams are active without notification.

**File:** `lib/main.dart`
*   [ ] Implement Edge-to-Edge support for Android 15.
    ```dart
    // In main()
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));
    ```

### 4. Dependency Updates
**File:** `pubspec.yaml`
*   [ ] Ensure `geolocator`, `image_picker`, `permission_handler` are at latest versions to bundle correct Android manifest merges.

## Verification Plan

### Automated Tests
*   Run `flutter build apk` to verify build success with `compileSdk 34`.

### Manual Verification
1.  **Permission Test (Android 14 Device)**:
    *   Install app on Android 14 Emulator/Device.
    *   Navigate to "Profile Photo Upload". Verify Photo Picker launches and works.
    *   Navigate to "Location Picker". Verify "Allow Location" prompt appears and location is fetched.
2.  **Edge-to-Edge Test (Android 15 Device)**:
    *   Install on Android 15 Emulator.
    *   Verify status bar and navigation bar are transparent/immersive.
3.  **Background Test**:
    *   Start "Current Location" fetch and background the app. Ensure no crash (Foreground Service exception).
