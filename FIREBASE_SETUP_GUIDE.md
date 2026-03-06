# دليل إعداد ونشر المشروع على Firebase

هذا الدليل يوضح خطوة بخطوة كيفية إعداد مشروع Firebase الخاص بك وربطه بتطبيق "التعليم الموريتاني" (Flutter) ونشره على الويب.

## الخطوة 1: إنشاء مشروع Firebase

1. اذهب إلى [Firebase Console](https://console.firebase.google.com/).
2. انقر على **"Add project"** (إضافة مشروع).
3. أدخل اسم المشروع (مثلاً: `mauritania-edu-app`).
4. (اختياري) قم بتفعيل أو تعطيل Google Analytics حسب رغبتك، ثم انقر على **"Create project"**.
5. انتظر حتى يكتمل الإنشاء ثم انقر على **"Continue"**.

## الخطوة 2: تفعيل الخدمات المطلوبة في Firebase

في لوحة تحكم Firebase، قم بتفعيل الخدمات التالية:

### 1. Authentication (المصادقة)
- اذهب إلى **Build > Authentication**.
- انقر على **"Get started"**.
- في تبويب **"Sign-in method"**، قم بتفعيل **Email/Password**.

### 2. Firestore Database (قاعدة البيانات)
- اذهب إلى **Build > Firestore Database**.
- انقر على **"Create database"**.
- اختر **"Start in test mode"** (للتطوير الأولي) أو **"Start in production mode"**.
- اختر المنطقة الجغرافية الأقرب لك (مثلاً `eur3` لأوروبا/إفريقيا).
- انقر على **"Enable"**.

### 3. Firebase Hosting (الاستضافة - لنسخة الويب)
- اذهب إلى **Build > Hosting**.
- انقر على **"Get started"** واتبع التعليمات الأولية (سنقوم بالإعداد الفعلي من خلال سطر الأوامر لاحقاً).

## الخطوة 3: ربط التطبيق بـ Firebase (طريقة FlutterFire CLI)

الطريقة الأسهل والأحدث لربط تطبيقات Flutter بـ Firebase هي استخدام `flutterfire_cli`.

### 1. تثبيت أدوات Firebase
افتح سطر الأوامر (Terminal/CMD) وقم بتنفيذ:
```bash
# تثبيت Firebase CLI إذا لم يكن مثبتاً
npm install -g firebase-tools

# تسجيل الدخول إلى حساب Google الخاص بك
firebase login

# تفعيل أدوات FlutterFire
dart pub global activate flutterfire_cli
```

### 2. إعداد المشروع
في مجلد المشروع الرئيسي (`mauritania-edu-app`)، قم بتشغيل:
```bash
flutterfire configure
```
- اختر المشروع الذي قمت بإنشائه في الخطوة 1.
- اختر المنصات التي تريد دعمها (Android, iOS, Web).
- سيقوم هذا الأمر تلقائياً بإنشاء ملف `lib/firebase_options.dart` وتحديث ملفات المنصات المختلفة.

## الخطوة 4: إعداد قواعد Firestore (Security Rules)

لحماية بياناتك، يجب تحديث قواعد Firestore. المشروع يحتوي بالفعل على ملف `firestore.rules`.

يمكنك نشر هذه القواعد مباشرة باستخدام:
```bash
firebase deploy --only firestore:rules
```

أو يمكنك نسخ محتوى ملف `firestore.rules` ولصقه يدوياً في لوحة تحكم Firebase:
1. اذهب إلى **Firestore Database > Rules**.
2. الصق القواعد.
3. انقر على **"Publish"**.

## الخطوة 5: رفع البيانات الأولية (Seed Data)

المشروع يحتوي على بيانات تجريبية للمواد والدروس. لإضافتها:

1. تأكد من أن التطبيق يعمل ومربوط بـ Firebase.
2. يمكنك استخدام أداة مثل [Firefoo](https://firefoo.app/) أو كتابة سكريبت صغير لرفع محتوى ملف `seed_data.json` إلى Firestore.

## الخطوة 6: نشر نسخة الويب (Web Demo)

لنشر التطبيق كصفحة ويب (Web Demo) باستخدام Firebase Hosting:

1. **تهيئة استضافة Firebase:**
   ```bash
   firebase init hosting
   ```
   - اختر مشروعك.
   - عند السؤال "What do you want to use as your public directory?"، اكتب: `build/web`
   - عند السؤال "Configure as a single-page app?"، اختر: `Yes` (y)
   - عند السؤال "Set up automatic builds and deploys with GitHub?"، اختر: `No` (n) (إلا إذا أردت إعداده)

2. **بناء نسخة الويب:**
   ```bash
   flutter build web --release --web-renderer canvaskit
   ```

3. **النشر على Firebase:**
   ```bash
   firebase deploy --only hosting
   ```

بعد اكتمال النشر، سيظهر لك رابط (URL) لنسخة الويب الخاصة بتطبيقك.

## الخطوة 7: نشر التطبيق على المتاجر (Android & iOS)

### Android (Google Play)
1. قم بتحديث `applicationId` في `android/app/build.gradle` إذا لزم الأمر.
2. قم بإنشاء ملف Keystore لتوقيع التطبيق.
3. قم ببناء حزمة التطبيق:
   ```bash
   flutter build appbundle --release
   ```
4. ارفع ملف `.aab` الناتج إلى Google Play Console.

### iOS (App Store)
1. تحتاج إلى حساب Apple Developer وجهاز Mac.
2. افتح مجلد `ios` في Xcode.
3. قم بتحديث الـ Bundle Identifier وإعدادات الـ Signing.
4. قم ببناء التطبيق:
   ```bash
   flutter build ipa --release
   ```
5. استخدم Xcode أو Transporter لرفع التطبيق إلى App Store Connect.

---
**ملاحظة هامة:** لا تقم أبداً برفع ملفات `google-services.json` أو `GoogleService-Info.plist` أو `firebase_options.dart` إلى مستودعات Git العامة لأنها تحتوي على مفاتيح مشروعك. (ملف `.gitignore` المرفق يقوم بتجاهلها تلقائياً).
