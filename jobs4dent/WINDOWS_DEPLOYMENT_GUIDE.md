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

3.  **Prepare Configuration Files (.env & Firebase)**:

    Because you are changing the Package Name (Step 3), you cannot simply copy the project files. You need to register a **NEW** Android app in Firebase matching your new package name and provide the correct configuration files.

    **This requires coordination between the Original Developer (Mac) and the Windows User.**

    #### Part A: Get the SHA-1
    **Role: Windows User**
    1.  Skip ahead briefly to **Step 4 (Keystore & Signing)** to generate your `upload-keystore.jks`.
    2.  Run the command in Step 4 to view your **SHA-1 Fingerprint**.
    3.  **Send this SHA-1 Fingerprint to the Original Developer.**
    4.  Also tell them your chosen **New Package Name** (e.g., `com.yourcompany.jobs4dent`).

    #### Part B: Generate Files
    **Role: Mac User (Original Developer)**
    
    > [!NOTE]
    > Only the Original Developer (Mac User) can do this because they own the Firebase project.

    1.  Go to the [Firebase Console](https://console.firebase.google.com/).
    2.  Open the project.
    3.  Go to **Project Settings > General > Your apps**.
    4.  Click **"Add app" (Android)**.
    5.  Enter the **New Package Name** (from Windows user).
    6.  Enter the **SHA-1 Fingerprint** (from Windows user).
    7.  Click **Register app**.
    8.  **Download `google-services.json`** to your **MacBook**.
    9.  **Generate `lib/firebase_options.dart` (On MacBook)**:
        *   You need to update this file to include the details of the new Android App you just created.
        *   Run this command **on your MacBook** terminal (root of the project):
            ```bash
            flutterfire configure
            ```
        *   Select your project.
        *   When asked about platforms, ensure **android** is selected.
        *   **Important**: It should detect the new package name (`com.yourcompany.jobs4dent`) and ask if you want to use the existing app (that you just registered in step 7) or create a new one. **Link it to the one you just created.**
        *   This will automatically update `lib/firebase_options.dart` with the correct `appId` and `messagingSenderId`.
        
        > [!IMPORTANT]
        > **About the App ID**: You might see an **App ID** in the Firebase Console (like `1:693132385676:android:...`).
        > *   **Yes, you should concern about this.**
        > *   This ID is **unique** to this new app.
        > *   **How the Windows User gets the ID**: They do *not* need to manually type this ID on the Windows laptop. It is **automatically included** inside the `google-services.json` and `firebase_options.dart` files you (Mac User) are generating right now.
        > *   **Why your role matters**: By running this command and sending the files, you ensure the Windows build uses the correct ID.
    10. **Prepare `.env`**:
        *   Copy your existing `.env` file content. The keys can usually be reused.
        *   Example content:
            ```ini
            # Firebase API Keys (Safe to copy from original project)
            FIREBASE_WEB_API_KEY=AIzaSyCw1Qa62VGHN0aEF46rmkQWLLlz_PxoMFA
            FIREBASE_ANDROID_API_KEY=AIzaSyBAUkkfFwTmmaiH6WALVE7nwTcGeWCZLFc
            FIREBASE_IOS_API_KEY=AIzaSyDXdEu1PvH_yroPHFXixS7mxG36BynbeIo

            # Google AI Studio API Key
            GOOGLE_AI_STUDIO_APIKEY=your_ai_studio_key_here

            # Google Maps API Key
            GOOGLE_MAPS_API_KEY=your_maps_api_key_here
            ```

            <details>
            <summary><strong>Need to find these keys again? (Click to expand)</strong></summary>

             *  **Google AI Studio API Key**:
                1.  Go to [Google AI Studio (MakerSuite)](https://aistudio.google.com/app/apikey).
                2.  Click **Create API key**.
                3.  Select your project (or create a new one) and copy the key.

             *  **Google Maps API Key**:
                1.  Go to the [Google Cloud Console](https://console.cloud.google.com/).
                2.  Select your project.
                3.  Navigate to **APIs & Services > Library**.
                4.  Search for and enable **Maps SDK for Android**.
                5.  Go to **APIs & Services > Credentials**.
                6.  Click **Create Credentials > API key**.
                7.  (Important) Restrict the key to "Android apps" using the **New Package Name** (from Part A, Step 4) and the **Windows SHA-1 Fingerprint** (from Part A, Step 2).
            </details>
    11. **Send 3 Files to the Windows User**:
        *   `.env`
        *   `google-services.json`
        *   `lib/firebase_options.dart` (The updated version)

        > [!TIP]
        > **Who owns the Cloud Account?**
        > *   **YOU (Mac User)** own the Firebase/Google Cloud project.
        > *   **Aunnop (Windows User)** does **NOT** need to enable APIs or use his own Google Cloud account.
        > *   **Why this works**: By adding Aunnop's **SHA-1** to **your** Firebase project (Part B, Step 6), you have authorized his specific laptop to talk to **your** backend. All "Enabled APIs" (like App Check) on your screen will automatically work for the app he builds.

    #### Part C: Place Files
    **Role: Windows User**
    
    Receive the files from the Mac User and place them **exactly** here:

    *   **`.env`** -> Paste into the **root** folder (same level as `pubspec.yaml`).
    *   **`google-services.json`** -> Paste into `android/app/`.
    *   **`firebase_options.dart`** -> Paste into `lib/` (replace the existing one).

    ### Troubleshooting `.env` Issues
    If the build fails with an error like "Could not find property 'GOOGLE_MAPS_API_KEY'" or "Missing .env file":

    1.  **Verify File Location**: Ensure the file is named exactly `.env` (with the dot prefix) and is located in the **root** folder (the folder containing `pubspec.yaml`, `android`, `ios`, etc.), NOT inside `android/` or `lib/`.
    2.  **Verify File Extension**: Windows sometimes hides extensions. Make sure it isn't named `.env.txt`. In File Explorer, go to View > Show > File name extensions to check.
    3.  **Verify Content**: Open the file and ensure the variable names match exactly (`GOOGLE_MAPS_API_KEY` and `GOOGLE_AI_STUDIO_APIKEY`).
    4.  **Reload**: If you just created the file, you might need to stop the build process completely and run `flutter clean` before trying again.

---

## 3. App Identity Verification (Package Name & SHA-1)

**CRITICAL STEP**: You must determine the **Package Name** and obtain the **SHA-1 Fingerprint** so the Mac developer can register the app in Firebase.

### 3.1. Package Name (Application ID)
**Role: Windows User**

Google Play treats the `applicationId` as the unique identity of the app.

*   **Current ID**: `com.jobs4dent.jobs4dent2`
*   **Action Required**:
    *   If the original developer **HAS** uploaded `com.jobs4dent.jobs4dent2` to their Play Console (even as a draft), **YOU MUST CHANGE IT**.
    *   If they haven't (or if this is a fresh retry), you might be able to use it.
    *   **Recommendation**: Change it to be safe (e.g., `com.yourcompany.jobs4dent`).

#### How to Rename (If needed)
**Note**: You do NOT need a tool to "generate" this. You simply **invent** a unique name.
*   **Format**: `com.yourname.projectname` (lowercase, no spaces, no special characters).
*   **Example**: `com.johnsmith.jobs4dent`

**Step-by-Step Change (Windows User):**

1.  Open `android/app/build.gradle.kts` **(On Windows)**.
2.  Find the `defaultConfig` block (around line 60):
    ```kotlin
    defaultConfig {
        applicationId = "com.jobs4dent.jobs4dent2" // <--- DELETE THIS LINE
        applicationId = "com.yourunique.newname"   // <--- WRITE YOUR NEW NAME HERE
        ...
    }
    ```
3.  **Important**: Do **NOT** change the `namespace` line (around line 36). Leave it as `com.jobs4dent.jobs4dent2`.
    *   *Why?* changing `namespace` requires moving folders and updating code imports. changing `applicationId` is handled automatically by the build system and is sufficient for the Google Play Store identity.
4.  Run `flutter clean` in the terminal.

### 3.2. Get SHA-1 Fingerprint (Release Key)
**Role: Windows User**

Use the release keystore (`upload-keystore.jks`) to generate the SHA-1.

> [!IMPORTANT]
> You must have completed **Step 4 (Keystore & Signing)** first to have the `upload-keystore.jks` file. If you haven't, go do Step 4A now, then come back here.

1.  Open **PowerShell** in your project root.
2.  Run this command:
    ```powershell
    keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
    ```
3.  Enter the password you created (e.g., `11223344`).
4.  Look for **Certificate fingerprints:** > **SHA1:**.
5.  **Copy this SHA-1** (e.g., `DA:39:A3:EE:5E:6B:4B:0D:32:55:BF:EF:95:60:18:90:AF:D8:07:09`).

**Final Output for Mac Developer** (Role: Windows User -> Send to Mac User):
Send these two things to the Mac developer so they can generate the `google-services.json`:
1.  **Package Name**: `com.yourunique.newname` (or the existing one if not changed)
2.  **SHA-1 Fingerprint**: `DA:39:A3...`

---

## 4. Keystore & Signing (Windows)

The original keystore (`upload-keystore.jks`) is **ignored** by Git for security. You must generate your **OWN** keystore since you are the new publisher.

### A. Generate a New Keystore
1.  Open PowerShell inside `android/app/`. 
    
    > **IMPORTANT**: Make sure you are in the `android/app` directory!
    > Run `pwd` or look at your prompt to confirm it ends in `\android\app`.
    > If you are in `jobs4dent`, run: `cd android/app`

2.  Run the generation command:
    ```powershell
    keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
    ```

3.  **Password**: Create a strong password (e.g., `11223344`). **Remember this!**
4.  **Questions**: Answer Name, Org, City, etc. (Can be anything reasonable).
5.  **Result**: A file named `upload-keystore.jks` will be created in `android/app/`.

### B. Verify SHA-1 Immediately
Now that you have created the key, get the SHA-1 fingerprint right away so you can send it to the developer.

1.  Run the list command:
    ```powershell
    keytool -list -v -keystore upload-keystore.jks -alias upload
    ```
2.  Enter the password you just created.
3.  Copy the **SHA1** line and send it to the developer.

### C. Create `key.properties`
The build script expects a `key.properties` file in the `android/` folder to tell it where the keystore is and what the password is.

1.  Go to the `android/` folder (run `cd ..`).
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

    *   **Monitor for Errors**:
        *   If the build finishes successfully: Great! Move to Step 5.
        *   If the build fails with an error mentioning **"FontAsset"** or **"Tree Shaking"**, run this alternative command:
            ```powershell
            flutter build appbundle --release --no-tree-shake-icons
            ```

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
> If you get an error saying "The package name com.jobs4dent.jobs4dent2 is already used by another application", you **MUST** go back to **Section 3. Package Name (Application ID) Verification**, rename the ID to something unique, rebuild, and upload again.

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

