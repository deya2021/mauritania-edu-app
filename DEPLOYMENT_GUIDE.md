# Deployment Guide - Mauritania Educational App

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Firebase Setup](#firebase-setup)
3. [Android Deployment](#android-deployment)
4. [iOS Deployment](#ios-deployment)
5. [Testing](#testing)
6. [Production Checklist](#production-checklist)
7. [Maintenance](#maintenance)

---

## Prerequisites

### Required Tools
- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: 3.0.0 or higher
- **Android Studio**: Latest version with Android SDK
- **Xcode**: Latest version (macOS only, for iOS)
- **Firebase CLI**: Install via `npm install -g firebase-tools`
- **Git**: For version control

### Accounts Needed
- Google Account (for Firebase)
- Google Play Console account (for Android)
- Apple Developer account (for iOS)

---

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add Project**
3. Enter project name: `mauritania-edu-app`
4. Disable Google Analytics (optional for MVP)
5. Click **Create Project**

### 2. Enable Authentication

1. In Firebase Console, click **Authentication**
2. Click **Get Started**
3. Enable **Phone** sign-in method
4. Configure test phone numbers (for testing):
   - Add: `+222 12 34 56 78` with code `123456`

### 3. Create Firestore Database

1. Click **Firestore Database**
2. Click **Create Database**
3. Select **Start in test mode** (will update rules later)
4. Choose location: `eur3 (Europe)` or closest to Mauritania
5. Click **Enable**

### 4. Deploy Security Rules

```bash
cd mauritania_edu_app
firebase init firestore
# Select existing project: mauritania-edu-app
# Use default filenames (firestore.rules, firestore.indexes.json)

firebase deploy --only firestore:rules
```

### 5. Seed Initial Data

**Option A: Manual Import via Console**
1. Open `seed_data.json`
2. For each collection, manually create documents in Firebase Console

**Option B: Script Import**
Create a Node.js script:

```javascript
// import_data.js
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
const seedData = require('./seed_data.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function importData() {
  for (const [collection, documents] of Object.entries(seedData)) {
    console.log(`Importing ${collection}...`);
    for (const doc of documents) {
      const { id, ...data } = doc;
      await db.collection(collection).doc(id).set(data);
    }
  }
  console.log('Import complete!');
}

importData();
```

Run:
```bash
node import_data.js
```

---

## Android Deployment

### 1. Add Android App to Firebase

1. In Firebase Console, click **Project Settings**
2. Click **Add App** → Android icon
3. Enter package name: `com.mauritania.edu.app`
4. Download `google-services.json`
5. Place file in: `android/app/google-services.json`

### 2. Update Android Configuration

Edit `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        applicationId "com.mauritania.edu.app"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
    }
}
```

### 3. Generate Signing Key

```bash
cd android/app
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Save passwords in `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 4. Build Release APK

```bash
flutter clean
flutter pub get
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### 5. Build App Bundle (for Play Store)

```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### 6. Upload to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app
3. Fill in app details:
   - **Name**: Mauritania Edu
   - **Category**: Education
   - **Languages**: Arabic, French
4. Upload `app-release.aab`
5. Complete store listing:
   - Screenshots (phone + tablet)
   - App icon (512x512)
   - Feature graphic (1024x500)
   - Description in Arabic and French
6. Set content rating
7. Submit for review

---

## iOS Deployment

### 1. Add iOS App to Firebase

1. In Firebase Console, click **Add App** → iOS icon
2. Enter bundle ID: `com.mauritania.edu.app`
3. Download `GoogleService-Info.plist`
4. Open Xcode: `open ios/Runner.xcworkspace`
5. Drag `GoogleService-Info.plist` into `Runner` folder

### 2. Update iOS Configuration

Edit `ios/Runner/Info.plist` (already configured in template)

### 3. Configure Xcode Project

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** project
3. Set **Bundle Identifier**: `com.mauritania.edu.app`
4. Set **Display Name**: Mauritania Edu
5. Set **Version**: 1.0.0
6. Set **Build**: 1

### 4. Configure Signing

1. In Xcode, select **Signing & Capabilities**
2. Check **Automatically manage signing**
3. Select your development team
4. Xcode will create provisioning profile

### 5. Build Release IPA

```bash
flutter clean
flutter pub get
flutter build ios --release

# Open in Xcode for archiving
open ios/Runner.xcworkspace
```

In Xcode:
1. Select **Product** → **Archive**
2. Once complete, **Distribute App**
3. Choose **App Store Connect**
4. Follow prompts to upload

### 6. App Store Connect Submission

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new app
3. Fill in app information:
   - **Name**: Mauritania Edu
   - **Category**: Education
   - **Languages**: Arabic, French
4. Upload screenshots (required sizes)
5. Add app description in both languages
6. Set pricing (Free)
7. Submit for review

---

## Testing

### Test Modes

**1. Phone Authentication Test Mode**
```
Phone: +222 12 34 56 78
Code: 123456
```

**2. Firestore Emulator (Optional)**
```bash
firebase emulators:start --only firestore
```

Update Firebase config to use emulator during development.

### Testing Checklist

- [ ] Phone auth with real number
- [ ] Phone auth with test number
- [ ] Year selection persists
- [ ] Subjects load correctly
- [ ] Lesson unlock logic works
- [ ] 24-hour rule enforced
- [ ] 70% completion unlock works
- [ ] Exercises submit correctly
- [ ] Progress syncs to Firestore
- [ ] Ads display and open URLs
- [ ] Language switching works
- [ ] RTL layout correct for Arabic
- [ ] Offline mode caches lessons
- [ ] App doesn't crash on poor network

### Beta Testing

**Android (Internal Testing)**
1. Google Play Console → Internal Testing
2. Add testers by email
3. Share test link

**iOS (TestFlight)**
1. App Store Connect → TestFlight
2. Add internal testers
3. Send invites

---

## Production Checklist

### Before Launch

- [ ] Firebase security rules deployed
- [ ] All test data removed
- [ ] Real content imported
- [ ] Ad slots configured
- [ ] Privacy policy uploaded
- [ ] Terms of service prepared
- [ ] Support email configured
- [ ] App icon finalized (all sizes)
- [ ] Screenshots captured (all required sizes)
- [ ] Store descriptions written (Arabic + French)
- [ ] Test on multiple devices
- [ ] Test on slow networks
- [ ] Verify all permissions needed
- [ ] Set up crash reporting (optional)
- [ ] Configure analytics (optional)

### Firebase Configuration

Update `firebase_options.dart` with production values:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_API_KEY',
  appId: 'YOUR_ACTUAL_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'mauritania-edu-app',
  storageBucket: 'mauritania-edu-app.appspot.com',
);
```

### Security

1. Enable Firebase App Check (optional but recommended)
2. Set up rate limiting for authentication
3. Review and tighten Firestore rules
4. Enable Firebase Security Rules monitoring

---

## Maintenance

### Regular Tasks

**Daily:**
- Monitor crash reports
- Check user feedback
- Verify ad displays

**Weekly:**
- Review analytics
- Update content as needed
- Check Firebase quota usage

**Monthly:**
- Security audit
- Performance review
- Update dependencies

### Updating the App

**Version Numbering:**
- Major: 1.0.0 → 2.0.0 (major changes)
- Minor: 1.0.0 → 1.1.0 (new features)
- Patch: 1.0.0 → 1.0.1 (bug fixes)

**Release Process:**
1. Update version in `pubspec.yaml`
2. Update CHANGELOG.md
3. Build new release
4. Test thoroughly
5. Upload to stores
6. Submit for review

### Rollback Plan

If critical bug found:
1. Previous APK/IPA stored in version control
2. Firebase console has data backups
3. Can push emergency release within 24-48 hours

---

## Troubleshooting

### Common Issues

**Firebase Connection Failed**
- Check `google-services.json` / `GoogleService-Info.plist` present
- Verify package name / bundle ID matches Firebase config
- Check internet permissions in manifest

**Phone Auth Not Working**
- Enable phone auth in Firebase Console
- Add test numbers for development
- Check SHA-1 fingerprint registered (Android)

**Build Failures**
- Run `flutter clean && flutter pub get`
- Check Gradle/CocoaPods versions
- Verify all dependencies compatible

---

## Support & Resources

- **Flutter Docs**: https://docs.flutter.dev
- **Firebase Docs**: https://firebase.google.com/docs
- **Play Store Help**: https://support.google.com/googleplay
- **App Store Help**: https://developer.apple.com/support

---

## Deployment Timeline

**Estimated Timeline:**
- Firebase setup: 2 hours
- Content import: 4 hours
- Android build & test: 2 hours
- iOS build & test: 2 hours
- Store submissions: 1 hour
- Review wait time: 1-7 days
- **Total**: ~2-8 days

---

**Deployment Guide Version**: 1.0  
**Last Updated**: 2026-01-07
