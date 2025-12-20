# Fixing "Wrong Signing Key" Error in Google Play Console

## Error Message

```
Your Android App Bundle is signed with the wrong key.
```

This error occurs when you try to upload an AAB signed with a different certificate than the one Google Play expects.

## Understanding the Issue

When you first upload an app to Google Play, the platform remembers the signing certificate's fingerprint. All future uploads **must** be signed with the same certificate, otherwise Google Play rejects them for security reasons.

## Finding Out Which Key is Expected

The error message shows:

- **Expected SHA-1**: The fingerprint of the certificate Google Play is expecting
- **Received SHA-1**: The fingerprint of the certificate you just used to sign your AAB

Example:

```
Expected: FB:04:C8:4C:33:EA:61:4D:EB:10:9F:AE:F9:BB:38:EA:1C:0C:29:D1
Received: 6A:39:17:E3:D1:1D:47:CD:B3:72:C4:E9:C6:08:B8:5C:E6:1F:3C:1C
```

## Solutions

### Option 1: Find and Use the Original Keystore (Recommended)

The original keystore might be located:

- On a backup drive or cloud storage
- On another computer you used for development
- In a different project folder
- Shared with your team members

**Steps:**

1. Search your computer for `.jks` or `.keystore` files:

   ```bash
   find ~ -name "*.jks" -o -name "*.keystore" 2>/dev/null
   ```

2. Check the SHA-1 of each keystore you find:

   ```bash
   keytool -list -v -keystore path/to/keystore.jks -alias your_alias
   ```

3. When you find the one matching the **expected SHA-1**, copy it to `android/app/upload-keystore.jks`

4. Update `android/key.properties` with the correct password and alias

5. Rebuild and upload:
   ```bash
   flutter build appbundle
   ```

### Option 2: Request Upload Key Reset (If Using Google Play App Signing)

If you're enrolled in **Google Play App Signing**, you can request a new upload key:

**Steps:**

1. Go to **Google Play Console**
2. Select your app
3. Navigate to **Release** > **Setup** > **App integrity**
4. Click the **App signing** tab
5. Scroll down to find **"Request upload key reset"** or similar option
6. Follow the instructions to request a reset
7. Google will review your request (can take several days)

**Note**: This only works if you're using Google Play App Signing. Check the "App signing" tab to see if you're enrolled.

### Option 3: Use Debug Keystore Temporarily (Internal Testing Only)

If you're in very early internal testing and just need to test quickly:

**⚠️ Warning**: This is NOT secure for production and should ONLY be used for internal testing.

1. Get your debug keystore SHA-1:

   ```bash
   keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android
   ```

2. If this matches the **expected SHA-1**, it means your first upload was accidentally signed with the debug key

3. You would need to either:
   - Continue using debug key (NOT RECOMMENDED)
   - Delete the app and start over with proper release key
   - Request upload key reset from Google

### Option 4: Create New App Listing (Last Resort)

If you're in early testing with no users yet:

**Steps:**

1. Delete all releases from the current app (internal/closed testing)
2. Delete the app from Google Play Console (only possible if never published to production)
3. Create a new app
4. Upload your AAB signed with the current keystore
5. Set up testing tracks again

## Preventing This in the Future

### 1. Back Up Your Keystore

- Store keystore in multiple secure locations
- Use password-protected cloud storage
- Keep passwords in a secure password manager
- Document the keystore location in your team documentation

### 2. Use Google Play App Signing

Enable Google Play App Signing for all new apps:

- Google manages the app signing key
- You only need to manage the upload key
- Google can reset your upload key if you lose it
- More secure and easier to manage

### 3. Version Control for Key Properties

Add to your repository (in `.gitignore`):

```
android/app/upload-keystore.jks
android/key.properties
```

But document:

- Where the keystore is backed up
- Key alias name
- Instructions to obtain passwords from team lead

## Checking Your Current Keystore

To see which keystore you're currently using:

```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

Compare the SHA-1 with what Google Play expects.

## Quick Checklist

- [ ] Search for the original keystore file
- [ ] Check if enrolled in Google Play App Signing
- [ ] Request upload key reset if eligible
- [ ] Consider recreating app if in early testing
- [ ] Set up proper keystore backup system
- [ ] Document keystore location for team

## Need Help?

If none of these solutions work:

1. Contact Google Play Console support
2. Provide proof of app ownership
3. Request assistance with certificate issue
