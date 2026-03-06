# Project Structure

```
mauritania_edu_app/
├── README.md                           # Complete project documentation
├── ADMIN_GUIDE.md                      # Admin user guide
├── DEPLOYMENT_GUIDE.md                 # Deployment instructions
├── pubspec.yaml                        # Flutter dependencies
├── seed_data.json                      # Sample data for Firestore
├── firestore.rules                     # Firestore security rules
│
├── lib/
│   ├── main.dart                       # App entry point
│   │
│   ├── config/
│   │   ├── theme.dart                  # App theme & colors
│   │   └── firebase_options.dart       # Firebase configuration
│   │
│   ├── models/
│   │   └── models.dart                 # All data models
│   │
│   ├── services/
│   │   ├── auth_service.dart           # Firebase authentication
│   │   ├── firestore_service.dart      # Database operations
│   │   └── progress_service.dart       # Unlock logic & progress
│   │
│   ├── providers/
│   │   ├── auth_provider.dart          # Auth state management
│   │   ├── locale_provider.dart        # Language management
│   │   └── curriculum_provider.dart    # Content state management
│   │
│   ├── l10n/
│   │   └── app_localizations.dart      # Arabic & French translations
│   │
│   ├── screens/
│   │   ├── splash_screen.dart          # Initial loading screen
│   │   ├── auth/
│   │   │   ├── phone_auth_screen.dart  # Phone + OTP login
│   │   │   └── select_year_screen.dart # Year selection
│   │   ├── home/
│   │   │   └── home_screen.dart        # Subjects list
│   │   ├── subject/
│   │   │   └── subject_screen.dart     # Lessons list
│   │   ├── lesson/
│   │   │   └── lesson_screen.dart      # Lesson content & exercises
│   │   └── profile/
│   │       └── profile_screen.dart     # Settings & profile
│   │
│   └── widgets/
│       ├── ad_banner.dart              # Custom ad widget
│       └── exercise_widget.dart        # MCQ & True/False widget
│
├── android/
│   ├── app/
│   │   ├── build.gradle                # Android build config
│   │   └── src/main/AndroidManifest.xml
│   ├── build.gradle                    # Root Gradle config
│   └── gradle.properties               # Gradle properties
│
└── ios/
    └── Runner/
        └── Info.plist                  # iOS configuration
```

## File Count
- **Dart files**: 21
- **Configuration files**: 9
- **Documentation files**: 3
- **Total**: 33 core files

## Key Features by File

### Authentication Flow
- `auth_service.dart` - Phone OTP handling
- `phone_auth_screen.dart` - UI for phone input
- `auth_provider.dart` - Auth state management

### Progressive Unlock System
- `progress_service.dart` - Core unlock logic (24h rule, 70% completion)
- `curriculum_provider.dart` - Manages unlock state
- `subject_screen.dart` - Visual lock indicators

### Bilingual Support
- `app_localizations.dart` - 100+ translated strings (AR/FR)
- `locale_provider.dart` - Language switching
- `theme.dart` - RTL support

### Custom Ad System
- `ad_banner.dart` - Banner widget with WebView
- `firestore_service.dart` - Ad slot management
- Ad slots: home_top, home_bottom, lesson_top, lesson_bottom

## Setup Priority

1. **Install Flutter** (if not already installed)
2. **Create Firebase project**
3. **Configure Firebase** (update firebase_options.dart)
4. **Import seed data** to Firestore
5. **Deploy security rules**
6. **Test with test phone number**
7. **Build & deploy**

## Next Steps

1. Review README.md for complete overview
2. Follow DEPLOYMENT_GUIDE.md for Firebase setup
3. Use ADMIN_GUIDE.md for content management
4. Import seed_data.json into Firestore
5. Test app with provided test credentials
