# 📚 تطبيق التعليم الموريتاني - Mauritania Educational App

## 🎯 نظرة عامة

تطبيق تعليمي متكامل للطلاب في موريتانيا، مبني بتقنية Flutter لأنظمة Android و iOS والويب. يوفر التطبيق تجربة تعليمية تفاعلية مع نظام فتح دروس تدريجي ودعم كامل للغة العربية (RTL) والفرنسية.

### ✨ الميزات الرئيسية

- 🔐 **مصادقة آمنة:** تسجيل دخول إلزامي عبر OTP (رمز التحقق) المرسل للهاتف
- 📱 **متعدد المنصات:** Android، iOS، والويب من كود واحد
- 🌍 **ثنائي اللغة:** دعم كامل للعربية (RTL) والفرنسية
- 📖 **محتوى منظم:** السنة الدراسية > المادة > الوحدة > الدرس
- 🔓 **فتح تدريجي:** نظام ذكي لفتح الدروس بشكل تدريجي
- ✍️ **تمارين تفاعلية:** أسئلة متعددة الخيارات وصح/خطأ
- 📊 **تتبع التقدم:** متابعة إنجازات الطالب
- 📺 **إعلانات مخصصة:** نظام إعلانات قابل للتحكم عن بُعد
- 📴 **العمل دون اتصال:** كاش ذكي للدروس المفتوحة
- 🔔 **إشعارات:** تنبيهات للدروس الجديدة والتحديثات
- 📈 **تحليلات:** متابعة استخدام التطبيق وأداء الطلاب

---

## 🚀 البدء السريع

### المتطلبات الأساسية

```bash
# Flutter SDK 3.0+
flutter --version

# Firebase CLI
npm install -g firebase-tools

# Git
git --version
```

### التثبيت

```bash
# 1. استنساخ المشروع
git clone <repository-url>
cd mauritania_edu_app

# 2. تحميل التبعيات
flutter pub get

# 3. تشغيل التطبيق
flutter run

# للويب:
flutter run -d chrome
```

---

## 📁 بنية المشروع

```
mauritania_edu_app/
├── lib/
│   ├── config/             # إعدادات التطبيق
│   │   ├── theme.dart      # الثيم والألوان
│   │   ├── firebase_options.dart
│   │   └── demo_config.dart
│   │
│   ├── models/             # نماذج البيانات
│   │   └── models.dart     # User, Year, Subject, Lesson, etc.
│   │
│   ├── services/           # الخدمات
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── progress_service.dart
│   │   ├── notification_service.dart
│   │   ├── analytics_service.dart
│   │   ├── crashlytics_service.dart
│   │   ├── storage_service.dart
│   │   └── local_data_service.dart
│   │
│   ├── providers/          # State Management
│   │   ├── auth_provider.dart
│   │   ├── locale_provider.dart
│   │   └── curriculum_provider.dart
│   │
│   ├── screens/            # الشاشات
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── phone_auth_screen.dart
│   │   │   ├── demo_login_screen.dart
│   │   │   └── select_year_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── subject/
│   │   │   └── subject_screen.dart
│   │   ├── lesson/
│   │   │   └── lesson_screen.dart
│   │   └── profile/
│   │       └── profile_screen.dart
│   │
│   ├── widgets/            # المكونات المشتركة
│   │   ├── ad_banner.dart
│   │   ├── exercise_widget.dart
│   │   └── web_responsive_wrapper.dart
│   │
│   ├── l10n/               # الترجمات
│   │   └── app_localizations.dart
│   │
│   └── main.dart           # نقطة الدخول
│
├── assets/
│   ├── fonts/              # الخطوط العربية
│   ├── images/             # الصور والأيقونات
│   └── data/               # البيانات المحلية
│       └── seed_data.json
│
├── web/                    # إعدادات الويب
│   ├── index.html
│   └── manifest.json
│
├── android/                # إعدادات Android
├── ios/                    # إعدادات iOS
│
├── firestore.rules         # قواعد Firestore
├── firebase.json           # إعدادات Firebase
├── pubspec.yaml            # التبعيات
│
└── docs/                   # الوثائق
    ├── README.md
    ├── DEPLOYMENT_GUIDE.md
    ├── ADMIN_GUIDE.md
    ├── IMPLEMENTATION_GUIDE.md
    └── WEB_DEMO_README.md
```

---

## 🔐 نظام المصادقة

### 1. تسجيل الدخول عبر الهاتف (Production)

```dart
// Phone OTP Flow
1. المستخدم يدخل رقم الهاتف (+222XXXXXXXX)
2. Firebase يرسل رمز OTP
3. المستخدم يدخل الرمز
4. تسجيل الدخول ناجح
5. اختيار السنة الدراسية
```

### 2. الوضع التجريبي (Demo Mode)

```dart
// lib/config/demo_config.dart
static const bool DEMO_MODE = true;

// عند التفعيل:
- زر "متابعة كمستخدم تجريبي"
- بدون OTP
- بيانات محلية تجريبية
```

---

## 📚 نظام المحتوى

### الهيكل الهرمي

```
السنة الدراسية (Year)
  └── المادة (Subject)
      └── الوحدة (Unit)
          └── الدرس (Lesson)
              ├── العنوان (Title)
              ├── الملخص (Summary)
              ├── الأقسام (Sections)
              │   └── قسم مقفل/مفتوح
              └── التمارين (Exercises)
                  ├── اختيار متعدد (MCQ)
                  └── صح/خطأ (True/False)
```

### نموذج البيانات

```json
{
  "years": [
    {
      "id": "year_1",
      "name_ar": "السنة الأولى",
      "name_fr": "Première année",
      "order": 1
    }
  ],
  "subjects": [
    {
      "id": "math_1",
      "year_id": "year_1",
      "name_ar": "الرياضيات",
      "name_fr": "Mathématiques",
      "icon": "calculate"
    }
  ],
  "lessons": [
    {
      "id": "lesson_001",
      "unit_id": "unit_001",
      "title_ar": "الأعداد الطبيعية",
      "title_fr": "Nombres naturels",
      "summary_ar": "مقدمة إلى الأعداد...",
      "content_language": "ar",
      "order": 1
    }
  ]
}
```

---

## 🔓 نظام فتح الدروس

### القواعد (لكل مادة):

1. **فتح تلقائي:** درس واحد كل 24 ساعة
2. **فتح إضافي:** درس ثانٍ عند إكمال 70% من تمارين الدرس الحالي
3. **الحد الأقصى:** درسان في اليوم لكل مادة
4. **المؤشرات:**
   - 🔓 درس مفتوح
   - 🔒 درس مقفل
   - ⏰ عداد تنازلي للدرس التالي

### مثال توضيحي:

```
اليوم 1:
- 08:00 - الدرس 1 يُفتح تلقائياً ✅
- 10:00 - أكملت 70% من تمارين الدرس 1
- 10:01 - الدرس 2 يُفتح ✅
- باقي اليوم - انتظار 24 ساعة

اليوم 2:
- 08:00 - الدرس 3 يُفتح تلقائياً ✅
- ...
```

---

## 💻 التطوير

### تشغيل التطبيق محلياً

```bash
# Android Emulator
flutter run

# iOS Simulator
flutter run -d "iPhone 14"

# Chrome (Web)
flutter run -d chrome

# جميع الأجهزة المتصلة
flutter run -d all
```

### بناء الإصدارات

```bash
# Android APK
flutter build apk --release

# Android App Bundle (للنشر)
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### الاختبار

```bash
# تشغيل جميع الاختبارات
flutter test

# اختبار مع التغطية
flutter test --coverage

# اختبار التكامل
flutter drive --target=test_driver/app.dart
```

---

## 🌐 النشر

### 1. Firebase Hosting (الويب)

```bash
# بناء
flutter build web --release

# نشر
firebase deploy --only hosting

# أو استخدم السكريبت:
./deploy_web_demo.sh
```

### 2. Google Play Store (Android)

```bash
# 1. إنشاء Keystore
keytool -genkey -v -keystore ~/mauritania-edu-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias mauritania-edu

# 2. تحديث android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=mauritania-edu
storeFile=<path-to-keystore>

# 3. بناء Bundle
flutter build appbundle --release

# 4. رفع على Google Play Console
```

### 3. Apple App Store (iOS)

```bash
# 1. فتح Xcode
open ios/Runner.xcworkspace

# 2. تحديث Bundle ID وTeam
# 3. Archive > Distribute App
# 4. رفع على App Store Connect
```

---

## 🔥 إعداد Firebase

### 1. إنشاء مشروع Firebase

```bash
# 1. اذهب إلى Firebase Console
https://console.firebase.google.com

# 2. أنشئ مشروع جديد
# اسم المشروع: Mauritania Education App

# 3. فعّل الخدمات:
✅ Authentication (Phone)
✅ Cloud Firestore
✅ Cloud Messaging
✅ Analytics
✅ Crashlytics
✅ Hosting
```

### 2. إضافة التطبيقات

```bash
# Android
Package name: com.mauritania.edu_app
تحميل: google-services.json → android/app/

# iOS
Bundle ID: com.mauritania.eduApp
تحميل: GoogleService-Info.plist → ios/Runner/

# Web
نسخ: firebaseConfig → lib/config/firebase_options.dart
```

### 3. استيراد البيانات

```bash
# استخدم Firebase Console
# Firestore Database > Start collection
# استورد: seed_data.json
```

### 4. نشر قواعد الأمان

```bash
firebase deploy --only firestore:rules
```

---

## 📊 التحليلات والمراقبة

### Firebase Analytics

تتبع أحداث:
- `login` - تسجيل الدخول
- `lesson_opened` - فتح درس
- `lesson_completed` - إكمال درس
- `exercise_started` - بدء تمرين
- `exercise_completed` - إكمال تمرين
- `ad_clicked` - نقر على إعلان
- `language_changed` - تغيير اللغة

### Firebase Crashlytics

تقارير الأخطاء التلقائية:
- تعطل التطبيق (Crashes)
- الأخطاء غير المعالجة (Unhandled Exceptions)
- سجلات مخصصة (Custom Logs)

### الوصول للوحات التحكم

```
Firebase Console > Your Project
├── Analytics (التحليلات)
├── Crashlytics (الأخطاء)
├── Cloud Messaging (الإشعارات)
└── Performance (الأداء)
```

---

## 🎨 التخصيص

### الألوان

```dart
// lib/config/theme.dart
static const Color primary = Color(0xFF1E3A8A);     // أزرق داكن
static const Color secondary = Color(0xFFFBBF24);   // ذهبي
static const Color success = Color(0xFF10B981);     // أخضر
static const Color error = Color(0xFFEF4444);       // أحمر
```

### الخطوط

```yaml
# pubspec.yaml
fonts:
  - family: Cairo          # للعربية
    fonts:
      - asset: assets/fonts/Cairo-Regular.ttf
      - asset: assets/fonts/Cairo-Bold.ttf
        weight: 700
  
  - family: Roboto         # للإنجليزية/الفرنسية
    fonts:
      - asset: assets/fonts/Roboto-Regular.ttf
      - asset: assets/fonts/Roboto-Bold.ttf
        weight: 700
```

### الترجمات

```dart
// lib/l10n/app_localizations.dart
class AppLocalizations {
  static Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'app_title': 'التعليم الموريتاني',
      'welcome': 'مرحباً',
      'login': 'تسجيل الدخول',
      // ...
    },
    'fr': {
      'app_title': 'Éducation Mauritanienne',
      'welcome': 'Bienvenue',
      'login': 'Se connecter',
      // ...
    },
  };
}
```

---

## 🔔 الإشعارات

### إشعارات محلية

```dart
// جدولة إشعار
await notificationService.scheduleNotification(
  title: 'درس جديد متاح!',
  body: 'درس الرياضيات الجديد جاهز الآن',
  scheduledTime: DateTime.now().add(Duration(hours: 24)),
);
```

### إشعارات Push

```dart
// إرسال لمستخدم محدد
POST https://fcm.googleapis.com/fcm/send
{
  "to": "<user_fcm_token>",
  "notification": {
    "title": "درس جديد",
    "body": "تم إضافة درس جديد في الرياضيات"
  },
  "data": {
    "lesson_id": "lesson_123",
    "subject_id": "math_1"
  }
}
```

---

## 📴 العمل دون اتصال

### التخزين المحلي

```dart
// حفظ درس للعمل دون اتصال
await storageService.cacheLessonContent('lesson_123', lessonData);

// استرجاع درس محفوظ
final lesson = storageService.getCachedLessonContent('lesson_123');

// التحقق من الكاش
if (storageService.isLessonCached('lesson_123')) {
  // استخدم النسخة المحفوظة
}
```

### المزامنة التلقائية

```dart
// عند الاتصال بالإنترنت
if (await connectivity.checkConnectivity() != ConnectivityResult.none) {
  await syncService.syncProgress();
  await syncService.fetchNewContent();
}
```

---

## 🛠️ أدوات الإدارة

### لوحة إدارة الإعلانات

```dart
// في Firebase Console أو أداة إدارة مخصصة
Ad Slot: home_top
- Enabled: true
- Image URL: https://example.com/ad.jpg
- Target URL: https://example.com/offer
- Start Date: 2026-01-01
- End Date: 2026-12-31
```

### إضافة محتوى جديد

```json
// إضافة درس جديد في Firestore
{
  "id": "lesson_new",
  "unit_id": "unit_001",
  "title_ar": "درس جديد",
  "title_fr": "Nouvelle leçon",
  "summary_ar": "ملخص الدرس...",
  "content_language": "ar",
  "order": 10,
  "exercises": [...]
}
```

---

## 🐛 استكشاف الأخطاء

### مشاكل شائعة

**1. خطأ Firebase:**
```bash
# التأكد من إعداد Firebase
flutter pub get
flutterfire configure
```

**2. خطأ Gradle (Android):**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**3. خطأ Pods (iOS):**
```bash
cd ios
pod deintegrate
pod install
cd ..
```

**4. خطأ الخطوط:**
```bash
# تأكد من وجود ملفات الخطوط في assets/fonts/
# تأكد من تسجيلها في pubspec.yaml
flutter clean
flutter pub get
```

---

## 📚 الوثائق الإضافية

- [📖 دليل النشر (DEPLOYMENT_GUIDE.md)](DEPLOYMENT_GUIDE.md)
- [👨‍💼 دليل الإدارة (ADMIN_GUIDE.md)](ADMIN_GUIDE.md)
- [🚀 دليل التنفيذ (IMPLEMENTATION_GUIDE.md)](IMPLEMENTATION_GUIDE.md)
- [🌐 دليل الويب (WEB_DEMO_README.md)](WEB_DEMO_README.md)

---

## 🤝 المساهمة

للمساهمة في المشروع:

1. Fork المشروع
2. أنشئ فرع للميزة (`git checkout -b feature/amazing-feature`)
3. Commit التغييرات (`git commit -m 'Add amazing feature'`)
4. Push للفرع (`git push origin feature/amazing-feature`)
5. افتح Pull Request

---

## 📄 الترخيص

هذا المشروع مرخص تحت [MIT License](LICENSE).

---

## 📞 الدعم

للمساعدة والدعم:
- 📧 البريد الإلكتروني: support@mauritania-edu.app
- 🌐 الموقع: https://mauritania-edu.web.app
- 📱 الهاتف: +222 XX XX XX XX

---

## 🙏 شكر وتقدير

- Flutter Team
- Firebase Team
- Material Design
- المساهمون في المشروع

---

**صُنع بـ ❤️ في موريتانيا 🇲🇷**

**تم التطوير بواسطة Genspark AI** 🤖  
**آخر تحديث:** يناير 2026

