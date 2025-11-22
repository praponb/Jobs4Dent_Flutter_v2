# Android Release Instructions

This guide explains how to generate a release keystore and build an Android App Bundle (AAB) for uploading to the Google Play Store.

## Prerequisites

Ensure you have the Java Development Kit (JDK) installed and accessible via the command line. The `keytool` command comes with the JDK.

## Step 1: Generate the Keystore File

You need to generate a private key to sign your app.

1.  Open your terminal in the project root.
2.  Run the following command to generate the keystore file. You can customize the alias (`upload`) if you wish, but make sure to update it in Step 2 as well.

    ```bash
    keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
    ```

3.  **Password**: Create a strong password when prompted. You will need this for the `key.properties` file.
4.  **Details**: Answer the questions (Name, Organization, etc.) or press Enter to skip.
5.  **Confirmation**: Type `yes` when asked if the details are correct.

This creates a file named `upload-keystore.jks` in `android/app/`.

**Important**: Keep this file safe and private. Do not commit it to version control.

## Step 2: Create the `key.properties` File

1.  Create a new file named `key.properties` in the `android/` directory.
2.  Add the following content, replacing `YOUR_PASSWORD_HERE` with the password you created in Step 1:

    ```properties
    storePassword=YOUR_PASSWORD_HERE
    keyPassword=YOUR_PASSWORD_HERE
    keyAlias=upload
    storeFile=../app/upload-keystore.jks
    ```

**Note**: This file contains sensitive information and is already excluded from version control via `.gitignore`.

## Step 3: Build the App Bundle (AAB)

1.  Run the following command in your project root to build the release bundle:

    ```bash
    flutter build appbundle
    ```

2.  Once the build finishes, your AAB file will be located at:
    `build/app/outputs/bundle/release/app-release.aab`

## Step 4: Upload to Google Play Console

Upload the generated `app-release.aab` file to the Google Play Console to release your app.

