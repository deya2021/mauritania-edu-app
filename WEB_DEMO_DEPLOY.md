# 🌐 Flutter Web Demo Deployment Guide

## Overview

This guide helps you deploy the Mauritania Educational App as a **web demo** using Firebase Hosting.

---

## ✨ Demo Features

### What's Included in Web Demo:
- ✅ **Demo Login** - No phone OTP required
- ✅ **Full UI Preview** - All screens accessible
- ✅ **RTL Support** - Arabic right-to-left working
- ✅ **Responsive Design** - Mobile-like layout (480px max width)
- ✅ **Sample Data** - 2 years, 2 subjects, 3 lessons
- ✅ **Progressive Unlock** - Full logic preserved
- ✅ **Exercises** - MCQ + True/False functional
- ✅ **Custom Ads** - All 4 slots visible
- ✅ **Offline Fallback** - Local data when Firestore unavailable

---

## 🚀 Quick Deploy (5 Steps)

### Prerequisites
- Flutter SDK installed
- Firebase CLI installed: `npm install -g firebase-tools`
- Firebase account

### Step 1: Build Flutter Web
```bash
cd mauritania_edu_app
flutter pub get
flutter build web --release
```

### Step 2: Firebase Setup
```bash
# Login to Firebase
firebase login

# Initialize project (if not already done)
firebase init hosting
# Select: build/web as public directory
# Configure as single-page app: Yes
# Overwrite index.html: No
```

### Step 3: Deploy
```bash
firebase deploy --only hosting
```

### Step 4: Access Your Demo
```
URL: https://mauritania-edu-demo.web.app
or: https://mauritania-edu-demo.firebaseapp.com
```

---

## 📱 Testing the Demo

### 1. Open in Browser
Visit your deployed URL

### 2. Demo Login Flow
```
Splash Screen
    ↓
Demo Login Screen
    ↓
Click "Continue as Demo User"
    ↓
Home Screen (Subjects)
```

### 3. Test Features
- ✅ View subjects
- ✅ Open lessons (unlock logic works)
- ✅ Complete exercises
- ✅ See progress tracking
- ✅ Check ads display
- ✅ Switch language (AR ↔ FR)
- ✅ Test RTL in Arabic mode

### 4. Test Responsive Design
```bash
# Open browser DevTools (F12)
# Toggle device toolbar (Ctrl+Shift+M)
# Test on:
- Mobile (375px)
- Tablet (768px)
- Desktop (1024px)
```

---

## 🔧 Configuration

### Demo Mode Settings
Located in `lib/config/demo_config.dart`:

```dart
class DemoConfig {
  static const bool DEMO_MODE = true;              // Enable demo login
  static const String DEMO_USER_ID = 'demo_user_001';
  static const String DEMO_USER_YEAR = 'year_1';  // Pre-selected year
  static const bool USE_ANONYMOUS_AUTH = true;     // Firebase anonymous auth
  static const bool USE_LOCAL_DATA_FALLBACK = true; // Local data if Firestore empty
}
```

### To Disable Demo Mode (Production):
```dart
static const bool DEMO_MODE = false;  // Will use phone OTP
```

---

## 📊 Data Sources

### Priority Order:
1. **Firestore** (if configured and has data)
2. **Local Assets** (`assets/data/seed_data.json`)
3. **Hardcoded Fallback** (in `LocalDataService`)

### Sample Data Includes:
- 2 Years (1st, 2nd)
- 2 Subjects (Math, Arabic)
- 3 Lessons with content
- Multiple exercises (MCQ + T/F)
- 4 Ad slots configured

---

## 🎨 Web-Specific Features

### Responsive Layout
- **Mobile**: Full width (< 480px)
- **Tablet/Desktop**: Centered 480px container
- Maintains mobile-app feel on larger screens

### RTL Support
- Arabic text flows right-to-left
- UI elements mirror correctly
- Tested in web browsers

### Performance
- Lazy loading
- Asset caching
- Service worker (PWA ready)

---

## 🔒 Security Notes

### Demo Mode Implications:
⚠️ **Demo mode bypasses authentication** - suitable for:
- Public previews
- UI/UX demonstrations
- Testing flows
- Showcasing to stakeholders

🛑 **NOT suitable for**:
- Production with real users
- Storing real user data
- Real progress tracking

### Production Deployment:
Set `DEMO_MODE = false` and configure:
- Real Firebase Authentication
- Phone OTP verification
- Proper Firestore rules

---

## 🐛 Troubleshooting

### Build Errors

**Issue**: `flutter build web` fails
```bash
# Solution:
flutter clean
flutter pub get
flutter build web --release
```

**Issue**: Firebase CLI not found
```bash
# Solution:
npm install -g firebase-tools
firebase --version
```

### Deployment Issues

**Issue**: Firebase project not found
```bash
# Solution:
firebase projects:list
firebase use <project-id>
```

**Issue**: 404 after deployment
```bash
# Solution: Ensure firebase.json has rewrite rules
# Already configured in this project
```

### Runtime Issues

**Issue**: White screen after loading
- Check browser console for errors
- Ensure Firebase config is correct
- Check if `main.dart.js` loaded

**Issue**: Data not loading
- Local fallback should work
- Check `assets/data/seed_data.json` exists
- Check browser network tab

**Issue**: RTL not working
- Test specifically in Arabic mode
- Check browser DevTools for RTL styles
- Clear browser cache

---

## 📈 Monitoring

### Firebase Hosting Metrics
```bash
firebase hosting:channel:list
```

### Analytics (Optional)
Add Google Analytics to track:
- Page views
- User interactions
- Demo usage patterns

---

## 🔄 Updating the Demo

### To Update Content:
1. Edit `assets/data/seed_data.json`
2. Rebuild: `flutter build web --release`
3. Redeploy: `firebase deploy --only hosting`

### To Update UI:
1. Modify Dart code
2. Rebuild web
3. Redeploy

### Version Channels (Optional):
```bash
# Preview channel (test before production)
firebase hosting:channel:deploy preview

# Production
firebase deploy --only hosting
```

---

## 🌍 Custom Domain (Optional)

### Add Custom Domain:
1. Firebase Console → Hosting → Add custom domain
2. Follow DNS configuration steps
3. SSL automatically provisioned

---

## 📦 What's Deployed

When you run `firebase deploy`, you're deploying:

```
build/web/
├── index.html              # Entry point
├── main.dart.js           # Compiled Dart code
├── flutter.js             # Flutter web engine
├── assets/                # All assets including seed_data.json
├── icons/                 # App icons
└── manifest.json          # PWA manifest
```

**Total Size**: ~5-10 MB (depends on assets)

---

## ✅ Pre-Launch Checklist

Before sharing the demo URL:

- [ ] `flutter build web --release` succeeds
- [ ] Firebase project created
- [ ] Deployed successfully
- [ ] Demo login works
- [ ] All subjects load
- [ ] Lessons open correctly
- [ ] Exercises functional
- [ ] Ads display
- [ ] Language switching works
- [ ] RTL correct in Arabic
- [ ] Tested on mobile viewport
- [ ] Tested on desktop viewport
- [ ] No console errors
- [ ] Loading spinner works

---

## 📞 Demo URL Structure

### Default Firebase URLs:
```
Primary: https://<project-id>.web.app
Backup:  https://<project-id>.firebaseapp.com
```

### Example:
```
https://mauritania-edu-demo.web.app
```

### Share This URL With:
- Stakeholders
- Testers
- Investors
- Design team
- Content creators

---

## 🎯 Demo Limitations

Current web demo limitations:

⚠️ **Not Included:**
- Real phone OTP (demo bypass only)
- Push notifications (not supported on web)
- Native device features
- App store distribution

✅ **Fully Functional:**
- All UI screens
- Navigation flows
- Data loading
- Progress tracking (local)
- Exercise completion
- Language switching
- RTL support
- Ads display

---

## 🔮 Next Steps

After demo approval:

1. **Collect Feedback** from stakeholders
2. **Iterate on UI/UX** based on feedback
3. **Prepare Mobile Builds** (Android/iOS)
4. **Configure Production Firebase**
5. **Import Real Content** to Firestore
6. **Test on Real Devices**
7. **Submit to App Stores**

---

## 📚 Additional Resources

- [Firebase Hosting Docs](https://firebase.google.com/docs/hosting)
- [Flutter Web Docs](https://docs.flutter.dev/platform-integration/web)
- [PWA Guide](https://web.dev/progressive-web-apps/)

---

**Web Demo Version**: 1.0.0-demo  
**Build Date**: 2026-01-09  
**Deploy Target**: Firebase Hosting  
**Demo Mode**: Enabled  

---

**🎉 Ready to showcase Mauritania Edu to the world!**
