# Windows Deployment Guide: jobs4dent

This guide is for deploying the **Jobs4Dent** Flutter project from a **Windows 11** machine to a **new** Google Play Console account.

> [!IMPORTANT]
> Because you are deploying to a **different** Google Play account, you **MUST** ensure the Package Name (Application ID) is unique. You cannot use the same ID as the original developer if they have already uploaded it.

---

## 1. Prerequisites

Before starting, ensure your Windows environment is set up:

1.  **Git**: Standard installation.
2.  **Flutter SDK**: Installed and added to `PATH`. Run `flutter doctor` to verify.
3.  **Java JDK 17**: This project uses Java 17.
    *   Download: [Microsoft Build of OpenJDK 17](https://learn.microsoft.com/en-us/java/openjdk/download#openjdk-17) or [Eclipse Temurin 17](https://adoptium.net/temurin/releases/?version=17).
    *   Set `JAVA_HOME` environment variable to your JDK installation path.
4.  **Android Studio**: With "Android SDK Command-line Tools" installed via SDK Manager.

---

## 2. Project Setup

1.  **Clone the Repository**:
    ```powershell
    git clone <YOUR_REPO_URL>
    cd jobs4dent
    ```

2.  **Install Dependencies**:
    ```powershell
    flutter pub get
    ```

3.  **Create `.env` File**:
    The `.env` file is ignored by Git but required for the build. Create a new file named `.env` in the **root** of the project (same level as `pubspec.yaml`).
    
    ### How to Generate Required Keys
    
    *   **Google AI Studio API Key**:
        1.  Go to [Google AI Studio (MakerSuite)](https://aistudio.google.com/app/apikey).
        2.  Click **Create API key**.
        3.  Select your project (or create a new one) and copy the key.

    *   **Google Maps API Key**:
        1.  Go to the [Google Cloud Console](https://console.cloud.google.com/).
        2.  Select your project.
        3.  Navigate to **APIs & Services > Library**.
        4.  Search for and enable **Maps SDK for Android**.
        5.  Go to **APIs & Services > Credentials**.
        6.  Click **Create Credentials > API key**.
        7.  (Recommended) Restrict the key to "Android apps" using your package name and SHA-1 fingerprint.
            
            > [!IMPORTANT]
            > **Who must do this?**
            > This step MUST be done on the **Windows 11 laptop** (your friend's machine).
            > Why? The SHA-1 fingerprint is unique to the specific `upload-keystore.jks` file located on the specific machine building the app. The developer's (Mac) SHA-1 will NOT work for the release built on Windows.

            **How to find these details on Windows:**
            
            *   **Package Name**:
                Open `android/app/build.gradle.kts` **on your Windows laptop**.
                *   *Note*: Since this file is part of the source code you cloned from GitHub, it is the same as on the developer's Mac. However, you should check it here to be 100% sure which ID you are building.
                *   Look for `applicationId`. (Example: `com.jobs4dent.jobs4dent2` or your new unique ID).

            *   **SHA-1 Fingerprint**:
                > **CONFIRMATION:** You MUST run this command on the **Windows 11 laptop** where the `upload-keystore.jks` was created.

                1. Open PowerShell inside the `android/app/` folder.
                2. Run the following command:
                   ```powershell
                   keytool -list -v -keystore upload-keystore.jks -alias upload
                   ```
                3. Enter the password you created (e.g., `11223344`).
                4. Look for the line starting with `SHA1:` under "Certificate fingerprints". Copy that long string.
    
    **Content format for `.env`:**
    ```ini
    # Google AI Studio API Key
    # Get your API key from: https://makersuite.google.com/app/apikey
    GOOGLE_AI_STUDIO_APIKEY=your_ai_studio_key_here

    # Google Maps API Key
    GOOGLE_MAPS_API_KEY=your_maps_api_key_here
    ```

    ### Troubleshooting `.env` Issues
    If the build fails with an error like "Could not find property 'GOOGLE_MAPS_API_KEY'" or "Missing .env file":

    1.  **Verify File Location**: Ensure the file is named exactly `.env` (with the dot prefix) and is located in the **root** folder (the folder containing `pubspec.yaml`, `android`, `ios`, etc.), NOT inside `android/` or `lib/`.
    2.  **Verify File Extension**: Windows sometimes hides extensions. Make sure it isn't named `.env.txt`. In File Explorer, go to View > Show > File name extensions to check.
    3.  **Verify Content**: Open the file and ensure the variable names match exactly (`GOOGLE_MAPS_API_KEY` and `GOOGLE_AI_STUDIO_APIKEY`).
    4.  **Reload**: If you just created the file, you might need to stop the build process completely and run `flutter clean` before trying again.

---

## 3. Package Name (Application ID) Verification

**CRITICAL STEP**: Google Play treats the `applicationId` as the unique identity of the app. 

*   **Current ID**: `com.jobs4dent.jobs4dent2`
*   **Action Required**:
    *   If the original developer **HAS** uploaded `com.jobs4dent.jobs4dent2` to their Play Console (even as a draft), **YOU MUST CHANGE IT**.
    *   If they haven't (or if this is a fresh retry), you might be able to use it.
    *   **Recommendation**: Change it to be safe (e.g., `com.yourcompany.jobs4dent`).

### How to Rename (If needed)
1.  Open `android/app/build.gradle.kts`.
2.  Find `defaultConfig`:
    ```kotlin
    defaultConfig {
        applicationId = "com.newname.jobs4dent" // <--- CHANGE THIS
        ...
    }
    ```
3.  Open `android/app/src/main/AndroidManifest.xml` and update `package="com.newname.jobs4dent"` if it is present (in newer Flutter apps, it might not be explicitly there, but check just in case).
4.  Run `flutter clean`.

---

## 4. Keystore & Signing (Windows)

The original keystore (`upload-keystore.jks`) is **ignored** by Git for security. You must generate your **OWN** keystore since you are the new publisher.

### A. Generate a New Keystore
Open PowerShell inside `android/app/` and run:

```powershell
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

*   **Password**: Create a strong password (e.g., `11223344`). **Remember this!**
*   **Questions**: Answer Name, Org, City, etc. (Can be anything reasonable).
*   **Result**: A file named `upload-keystore.jks` will be created in `android/app/`.

### B. Create `key.properties`
The build script expects a `key.properties` file in the `android/` folder to tell it where the keystore is and what the password is.

1.  Go to the `android/` folder.
2.  Create a new file named `key.properties`.
3.  Add the following content (adjust passwords to match what you just created):

```properties
storePassword=11223344
keyPassword=11223344
keyAlias=upload
storeFile=../app/upload-keystore.jks
```

> [!TIP]
> **Windows Path Note**: By using `../app/upload-keystore.jks`, we use a **relative path**. This works perfectly on Windows (`C:\...`) and macOS alike, avoiding hardcoded paths like `/Users/name/...`.

---

## 5. Build the App Bundle (AAB)

Now you are ready to build the release file for Google Play.

1.  **Update Flutter Version** (Recommended):
    Ensure you are using the latest stable version of Flutter to match the developer's environment and avoid compatibility issues.
    ```powershell
    flutter upgrade
    ```

2.  **Clean the project** (Good practice to remove cached artifacts):
    ```powershell
    flutter clean
    ```

3.  **Get dependencies**:
    ```powershell
    flutter pub get
    ```

4.  **Build the Release Bundle**:
    ```powershell
    flutter build appbundle --release
    ```

    *   *Note*: Start with the standard command. Only use `--no-tree-shake-icons` if you encounter specific errors regarding "FontAsset" or icon tree shaking not supported.

5.  **Locate the File**:
    The file will be at:
    `build\app\outputs\bundle\release\app-release.aab`

---

## 6. Upload to Google Play Console

1.  Log in to your **Google Play Console**.
2.  Click **Create app**.
3.  Select **Closed testing** (recommended for first upload) -> **Create track**.
4.  Click **Upload** and select your `app-release.aab`.
5.  **Signing Key**: Google Play will ask about "Play App Signing". Click **Continue** (or Use Google-generated key). This is standard.

> [!NOTE]
> If you get an error saying "The package name com.jobs4dent.jobs4dent2 is already used by another application", you **MUST** go back to Step 3, rename the ID, rebuild, and upload again.

---

## Troubleshooting Common Windows Issues

*   **"FontAsset" or "Tree Shaking" errors**:
    *   If the build fails with errors about icon tree shaking, run:
        ```powershell
        flutter build appbundle --release --no-tree-shake-icons
        ```
*   **"execution failed for task ':app:signReleaseBundle'"**:
    *   Check your `key.properties` passwords. They typically must match for both store and key.
    *   Ensure `storeFile` path is correct.
*   **"Java heap space"**:
    *   Run `cd android` and then `.\gradlew clean build`.

