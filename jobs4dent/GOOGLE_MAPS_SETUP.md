# Google Maps Setup Instructions

## Overview

The location picker feature uses Google Maps to allow clinic owners to select precise branch locations. This requires Google Maps API configuration for both Android and iOS platforms.

## Prerequisites

1. Google Cloud Console account
2. Google Maps API key with Maps SDK enabled

## Step 1: Create Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API (optional, for address lookup)
4. Go to "Credentials" and create an API key
5. Restrict the API key to your app (recommended for security)

## Step 2: Android Configuration

### Add API Key to Android Manifest

1. Open `android/app/src/main/AndroidManifest.xml`
2. Add the following inside the `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="API Key" />
```

### Example:

```xml
<application
    android:label="jobs4dent"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">

    <!-- Google Maps API Key -->
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="API Key" />

    <activity
        android:name=".MainActivity"
        android:exported="true"
        android:launchMode="singleTop"
        android:theme="@style/LaunchTheme"
        android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
        android:hardwareAccelerated="true"
        android:windowSoftInputMode="adjustResize">
        <!-- Other activity configurations -->
    </activity>
</application>
```

## Step 3: iOS Configuration

### Add API Key to iOS

1. Open `ios/Runner/AppDelegate.swift`
2. Import GoogleMaps and add the API key:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Update iOS Deployment Target

1. Open `ios/Podfile`
2. Ensure minimum deployment target is iOS 11.0:

```ruby
platform :ios, '11.0'
```

## Step 4: Permissions Setup

### Android Permissions

The following permissions are already configured in `android/app/src/main/AndroidManifest.xml`:

- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`

### iOS Permissions

Add location permissions to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to help you select branch locations on the map.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to help you select branch locations on the map.</string>
```

## Step 5: Test the Setup

1. Run `flutter clean`
2. Run `flutter pub get`
3. Run the app and test the location picker functionality

## Security Best Practices

1. **Restrict API Key**: In Google Cloud Console, restrict your API key to specific apps
2. **Use Application Restrictions**: Set up Android app signing certificate fingerprint and iOS bundle ID
3. **API Restrictions**: Limit the API key to only the necessary Google Maps services

## Troubleshooting

### Common Issues:

1. **Map not loading**: Check if API key is correctly configured
2. **Permission denied**: Ensure location permissions are properly set
3. **Build errors**: Run `flutter clean` and `flutter pub get`

### Debug Steps:

1. Check API key validity in Google Cloud Console
2. Verify API restrictions are not too restrictive
3. Check device location services are enabled
4. Review app permissions in device settings

## Feature Usage

Once configured, users can:

- Tap "คลิกเพื่อปักหมุดตำแหน่ง" to open map picker
- Select location by tapping on the map
- Use current location button for convenience
- Edit or remove selected locations
- Save coordinates to Firestore with branch data

## Database Storage

Selected locations are stored in Firestore as:

```json
{
  "coordinates": {
    "_latitude": 13.7563,
    "_longitude": 100.5018
  }
}
```

The coordinates are automatically saved when creating or updating branch information.
