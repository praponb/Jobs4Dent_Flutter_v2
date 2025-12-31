# Android Compatibility Testing Instructions

## 1. Environment Setup
*   Ensure you have the latest Flutter SDK (3.22+ recommended).
*   Ensure you have Android Studio with **complete Android SDK command-line tools**.
*   Install Android System Images for:
    *   **Android 14 (API 34)** - UpsideDownCake
    *   **Android 15 (API 35)** - VanillaIceCream
    *   **Android 16 (Preview)** - Baklava (if available, otherwise rely on Android 15 testing for deprecations).

## 2. Build Verification
Run the following command to ensure the build configuration is correct:
```bash
flutter clean
flutter pub get
flutter build apk --debug
```
*   **Success Criteria**: Build completes without errors related to `compileSdk` or manifest merges.

## 3. Functionality Testing (Manual)

### Test A: Android 14 (API 34) - Permissions & Services
**Device**: Android 14 Emulator or Physical Device.
1.  **Install App**: `flutter run -d <android-14-device-id>`
2.  **Location Permission**:
    *   Go to **Profile > Branch Location** (or where location picker is used).
    *   Tap "Current Location" button.
    *   **Verify**: Prompt appears ("Allow Jobs4Dent to access this device's location?").
    *   Select "While using the app".
    *   **Verify**: Location is fetched and map updates. **No crash**.
3.  **Photo Picker (Partial Access works)**:
    *   Go to **Profile > Edit Profile**.
    *   Tap on Profile Picture to upload.
    *   **Verify**: System Photo Picker opens (instead of old file manager if supported) or standard gallery.
    *   Select a photo.
    *   **Verify**: Photo uploads successfully.

### Test B: Android 15 (API 35) - Edge-to-Edge
**Device**: Android 15 Emulator.
1.  **Install App**.
2.  **UI Check**:
    *   Launch app.
    *   **Verify**: Status bar (top) and Navigation bar (bottom) are transparent or translucent. Content should flow behind them (or look seamlessly integrated).
    *   **Verify**: Nothing is obscured by the camera cutout or gesture bar.
    *   **Verify**: Keyboard opening does not break layout (check "Login" screen).

### Test C: Android 16 (Preview) - Future Proofing
**Device**: Android 16 Emulator (if available).
1.  **Photo Picker Enforcement**:
    *   Android 16 requires the Photo Picker. verify `image_picker` launches it correctly.

## 4. Troubleshooting
*   **Merge Conflicts**: If build fails with `Manifest merger failed`, check `android/app/src/main/AndroidManifest.xml` for duplicate permissions or conflicting `minsdk` in plugins.
*   **Crash on Location**: If app crashes when getting location, check Logcat for `SecurityException: Foreground service type not defined`. (This shouldn't happen as we added `FOREGROUND_SERVICE_LOCATION` and `geolocator` typically handles this, but verify usage).
