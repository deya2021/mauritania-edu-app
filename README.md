# Mauritania Educational App - MVP

A comprehensive educational mobile application designed specifically for students in Mauritania, built with Flutter for both Android and iOS platforms.

## 🎯 Overview

This MVP (Minimum Viable Product) provides a structured curriculum learning platform with:
- Phone-based authentication
- Progressive lesson unlocking system
- Bilingual support (Arabic RTL + French)
- Integrated custom ad system
- Offline content caching
- Exercise tracking and progress monitoring

## 📱 Features

### Core Features
- **Authentication**: Phone number + OTP verification
- **Multi-language Support**: Arabic (RTL) and French with auto-detection
- **Curriculum Structure**: Year → Subject → Unit → Lesson
- **Progressive Unlocking**: Smart lesson unlock system (max 2 lessons per day per subject)
- **Interactive Exercises**: MCQ and True/False questions with instant feedback
- **Progress Tracking**: Per-lesson and per-subject progress monitoring
- **Custom Ads**: Banner ads with in-app WebView display
- **Offline Support**: Cached lessons for offline access

### Progressive Unlock Logic (CRITICAL)
Per subject basis:
1. **Automatic unlock**: At least 1 new lesson every 24 hours
2. **Conditional second unlock**: Complete current lesson at 70%+ to unlock second lesson same day
3. **Daily limit**: Maximum 2 lessons per day per subject
4. **Visual feedback**: Clear lock indicators and countdown timers

## 🏗️ Architecture

### Tech Stack
- **Framework**: Flutter 3.0+
- **Backend**: Firebase (Auth + Firestore)
- **State Management**: Provider
- **UI Components**: Material Design 3
- **Localization**: Custom i18n system

### Project Structure
```
lib/
├── config/               # App configuration
│   ├── theme.dart
│   └── firebase_options.dart
├── models/              # Data models
│   └── models.dart
├── services/            # Business logic
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── progress_service.dart
├── providers/           # State management
│   ├── auth_provider.dart
│   ├── locale_provider.dart
│   └── curriculum_provider.dart
├── l10n/               # Localization
│   └── app_localizations.dart
├── screens/            # UI screens
│   ├── splash_screen.dart
│   ├── auth/
│   ├── home/
│   ├── subject/
│   ├── lesson/
│   └── profile/
├── widgets/            # Reusable widgets
│   ├── ad_banner.dart
│   └── exercise_widget.dart
└── main.dart
```

## 🗄️ Database Schema (Firestore)

### Collections

#### `users`
```json
{
  "id": "userId",
  "phoneNumber": "+222XXXXXXXX",
  "selectedYearId": "year_1",
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp"
}
```

#### `years`
```json
{
  "id": "year_1",
  "name": {"ar": "السنة الأولى", "fr": "Première année"},
  "order": 1,
  "isActive": true
}
```

#### `subjects`
```json
{
  "id": "math_year1",
  "yearId": "year_1",
  "name": {"ar": "الرياضيات", "fr": "Mathématiques"},
  "iconUrl": "https://...",
  "color": "#2196F3",
  "order": 1
}
```

#### `units`
```json
{
  "id": "unit_1",
  "subjectId": "math_year1",
  "name": {"ar": "...", "fr": "..."},
  "order": 1
}
```

#### `lessons`
```json
{
  "id": "lesson_1",
  "unitId": "unit_1",
  "subjectId": "math_year1",
  "title": {"ar": "...", "fr": "..."},
  "summary": {"ar": "...", "fr": "..."},
  "contentLanguage": "fr",
  "order": 1
}
```

#### `lesson_contents`
```json
{
  "id": "content_1",
  "lessonId": "lesson_1",
  "sections": [
    {
      "title": "Section Title",
      "content": "Markdown content...",
      "lockedInitially": false,
      "order": 1
    }
  ],
  "exercises": [
    {
      "id": "ex1",
      "type": "mcq",
      "question": "Question text?",
      "options": ["Option 1", "Option 2"],
      "correctAnswer": "0",
      "explanation": "Explanation text"
    }
  ]
}
```

#### `user_progress`
Document ID format: `{userId}_{subjectId}`
```json
{
  "userId": "user123",
  "subjectId": "math_year1",
  "unlockedLessonIds": ["lesson_1", "lesson_2"],
  "lastUnlockTimestamp": "timestamp",
  "dailyUnlockCount": 1,
  "lastUnlockDate": "timestamp",
  "lessonProgress": {
    "lesson_1": {
      "lessonId": "lesson_1",
      "totalExercises": 5,
      "completedExercises": 4,
      "exerciseResults": {"ex1": true, "ex2": false},
      "lastAccessedAt": "timestamp"
    }
  }
}
```

#### `ad_slots`
```json
{
  "id": "ad_1",
  "slotName": "home_top",
  "imageUrl": "https://...",
  "targetUrl": "https://...",
  "enabled": true,
  "startDate": "timestamp",
  "endDate": "timestamp",
  "order": 1
}
```

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Firebase project (iOS + Android apps configured)
- Android Studio / Xcode for platform-specific builds

### Installation Steps

1. **Clone the repository**
```bash
cd /path/to/mauritania_edu_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
   - Create a Firebase project at https://console.firebase.google.com
   - Add Android and iOS apps to your Firebase project
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in appropriate directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`
   - Update `lib/config/firebase_options.dart` with your Firebase configuration

4. **Enable Firebase services**
   - Enable Phone Authentication in Firebase Console
   - Enable Firestore Database
   - Deploy Firestore security rules (see `firestore.rules`)

5. **Seed initial data**
   - Import `seed_data.json` into Firestore
   - Or manually create collections using Firebase Console

6. **Run the app**
```bash
# Run on Android
flutter run

# Run on iOS
flutter run
```

## 🔒 Security Rules

Firestore security rules are defined in `firestore.rules`. Deploy them using:
```bash
firebase deploy --only firestore:rules
```

Key security features:
- Users can only access their own data
- Curriculum content is read-only
- Progress updates restricted to document owners
- Admin operations require backend authentication

## 🎨 UI/UX Guidelines

### Color Palette
- Primary: `#2196F3` (Blue)
- Secondary: `#4CAF50` (Green)
- Accent: `#FF9800` (Orange)
- Background: `#F5F5F5`
- Locked: `#BDBDBD` (Gray)

### RTL Support
- Arabic language displays in RTL mode
- All layouts support bidirectional text
- Icons and UI elements mirror appropriately

### Ad Placement
Fixed slots with reserved space:
- `home_top`: Top of home screen
- `home_bottom`: Bottom of home screen
- `lesson_top`: Top of lesson detail
- `lesson_bottom`: Bottom of lesson detail

## 📊 Admin Interface (Simple)

For MVP, use Firebase Console to manage:

### Ad Management
1. Go to Firestore → `ad_slots` collection
2. Add/edit documents with fields:
   - `slotName`: home_top | home_bottom | lesson_top | lesson_bottom
   - `imageUrl`: Direct URL to banner image
   - `targetUrl`: Destination URL
   - `enabled`: true/false
   - `startDate`, `endDate`: Optional timestamps
   - `order`: Display priority

### Content Management
1. Use Firebase Console or custom scripts
2. Maintain data structure as defined in schema
3. Content prepared externally (NotebookLM) and imported as JSON

## 🔄 Lesson Content Workflow

1. **Prepare content** using NotebookLM or similar tools
2. **Structure** as JSON following `lesson_contents` schema
3. **Import** to Firestore using Firebase Console or scripts
4. **Verify** content displays correctly in app
5. **Test** exercises and unlock logic

## 📝 Testing Checklist

- [ ] Phone authentication works (test mode)
- [ ] Year selection saves properly
- [ ] Subjects load for selected year
- [ ] First lesson unlocks automatically
- [ ] 24-hour unlock rule enforced
- [ ] Second lesson unlocks at 70% completion
- [ ] Daily limit (2 lessons) enforced
- [ ] Exercises submit and track correctly
- [ ] Progress persists across sessions
- [ ] Ads display and open in WebView
- [ ] Language switching works (AR ↔ FR)
- [ ] RTL layout renders correctly
- [ ] Offline caching functions

## 🚧 Known Limitations (MVP)

- No payment integration
- No social features
- No gamification (beyond unlock logic)
- Basic admin interface (Firebase Console)
- No advanced analytics
- No push notifications
- No content search

## 🔮 Future Enhancements

- Advanced admin dashboard
- Payment integration for premium content
- Leaderboards and achievements
- Parent/teacher monitoring
- Video lessons support
- Live classes integration
- Content recommendation engine
- Advanced analytics dashboard

## 📄 License

Proprietary - All rights reserved

## 👥 Contributors

- Developer: [Your Name]
- Project: Mauritania Educational Platform MVP

## 📞 Support

For technical support or questions, contact: [your-email@example.com]

---

**Version**: 1.0.0  
**Last Updated**: 2026-01-07  
**Platform**: Flutter 3.0+ | Android & iOS
