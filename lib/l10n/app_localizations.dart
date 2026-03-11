import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      // App
      'app_title': 'التعليم الموريتاني',

      // Authentication
      'welcome': 'مرحباً',
      'phone_auth_title': 'تسجيل الدخول',
      'enter_phone': 'أدخل رقم هاتفك',
      'phone_hint': '+222 XX XX XX XX',
      'send_code': 'إرسال الرمز',
      'enter_otp': 'أدخل رمز التحقق',
      'verify': 'تحقق',
      'resend_code': 'إعادة إرسال الرمز',

      // Greetings
      'good_morning': 'صباح الخير ☀️',
      'good_afternoon': 'مساء الخير 🌤️',
      'good_evening': 'مساء النور 🌙',
      'keep_learning': 'تابع التعلم، أنت تبلي بلاءً حسناً!',

      // Year selection
      'select_year_title': 'اختر سنتك الدراسية',
      'select_year_subtitle': 'اختر السنة الدراسية لرؤية المحتوى المناسب',
      'continue': 'متابعة',

      // Home
      'home_title': 'الرئيسية',
      'my_subjects': 'موادي الدراسية',
      'progress': 'التقدم',
      'no_subjects': 'لا توجد مواد متاحة',
      'subjects': 'المواد',
      'unlocked_lessons': 'دروس مفتوحة',
      'overall_progress': 'التقدم الكلي',
      'no_notifications': 'لا توجد إشعارات جديدة',

      // Subject
      'lessons': 'الدروس',
      'locked': 'مقفل',
      'unlocked': 'مفتوح',
      'completed': 'مكتمل',
      'unlock_in': 'يفتح خلال',
      'hours': 'ساعات',
      'minutes': 'دقائق',

      // Lesson
      'lesson_title': 'الدرس',
      'summary': 'الملخص',
      'content': 'المحتوى',
      'exercises': 'التمارين',
      'complete_exercises': 'أكمل التمارين لفتح الدرس التالي',
      'lesson_locked': 'هذا الدرس مقفل',
      'lesson_locked_message': 'أكمل الدرس السابق بنسبة 70٪ أو انتظر حتى اليوم التالي',
      'next_lesson_in': 'الدرس التالي خلال',
      'lesson_completed': 'تم إكمال الدرس! 🎉',
      'well_done': 'أحسنت!',
      'completed_lessons': 'دروس مكتملة',
      'time_remaining': 'الوقت المتبقي',

      // Exercises
      'question': 'السؤال',
      'true': 'صحيح',
      'false': 'خاطئ',
      'submit': 'إرسال',
      'correct': 'إجابة صحيحة! ✅',
      'incorrect': 'إجابة خاطئة ❌',
      'explanation': 'التفسير',

      // Profile
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'change_year': 'تغيير السنة الدراسية',
      'change_language': 'تغيير اللغة',
      'privacy_policy': 'سياسة الخصوصية',
      'logout': 'تسجيل الخروج',
      'language': 'اللغة',
      'arabic': 'العربية',
      'french': 'الفرنسية',
      'total_lessons': 'إجمالي الدروس',
      'your_year': 'سنتك الدراسية',
      'learning_stats': 'إحصائيات التعلم',
      'member_since': 'عضو منذ',

      // Search
      'search': 'البحث',
      'search_hint': 'ابحث عن مادة أو درس...',
      'no_results': 'لا توجد نتائج',
      'all': 'الكل',
      'recent_subjects': 'المواد',
      'browse_all': 'تصفح الكل',

      // Achievements
      'achievements': 'الإنجازات',
      'your_achievements': 'إنجازاتك',
      'badges_and_medals': 'الأوسمة والشارات',
      'subject_progress': 'تقدم المواد',
      'achievement_earned': 'لقد حصلت على هذه الشارة! 🎉',
      'achievement_locked': 'تابع تعلمك لفتح هذه الشارة 🔒',

      // Achievement names
      'first_lesson': 'أول درس',
      'streak_3_days': 'متعلم منتظم',
      'fast_learner': 'متعلم سريع',
      'diligent_student': 'طالب مجتهد',
      'perfect_score': 'علامة كاملة',
      'bookworm': 'عاشق الكتب',
      'champion': 'بطل',
      'explorer': 'مستكشف',
      'master': 'أستاذ',

      // Settings & Privacy
      'notifications': 'الإشعارات',
      'offline_mode': 'الوضع دون اتصال',
      'clear_cache': 'مسح ذاكرة التخزين',
      'about_app': 'حول التطبيق',
      'version': 'الإصدار',
      'privacy_content': 'هذا التطبيق يجمع بيانات الاستخدام بهدف تحسين تجربة التعلم. نحن ملتزمون بحماية خصوصيتك.',

      // Common
      'ok': 'موافق',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'close': 'إغلاق',
      'error': 'خطأ',
      'success': 'نجح',
      'loading': 'جاري التحميل...',
      'retry': 'إعادة المحاولة',
    },
    'fr': {
      // App
      'app_title': 'Éducation Mauritanienne',

      // Authentication
      'welcome': 'Bienvenue',
      'phone_auth_title': 'Connexion',
      'enter_phone': 'Entrez votre numéro de téléphone',
      'phone_hint': '+222 XX XX XX XX',
      'send_code': 'Envoyer le code',
      'enter_otp': 'Entrez le code de vérification',
      'verify': 'Vérifier',
      'resend_code': 'Renvoyer le code',

      // Greetings
      'good_morning': 'Bonjour ☀️',
      'good_afternoon': 'Bon après-midi 🌤️',
      'good_evening': 'Bonsoir 🌙',
      'keep_learning': 'Continuez à apprendre, vous faites du bon travail!',

      // Year selection
      'select_year_title': 'Sélectionnez votre année scolaire',
      'select_year_subtitle': 'Choisissez votre année pour voir le contenu approprié',
      'continue': 'Continuer',

      // Home
      'home_title': 'Accueil',
      'my_subjects': 'Mes Matières',
      'progress': 'Progression',
      'no_subjects': 'Aucune matière disponible',
      'subjects': 'Matières',
      'unlocked_lessons': 'leçons débloquées',
      'overall_progress': 'Progression globale',
      'no_notifications': 'Pas de nouvelles notifications',

      // Subject
      'lessons': 'Leçons',
      'locked': 'Verrouillé',
      'unlocked': 'Déverrouillé',
      'completed': 'Terminé',
      'unlock_in': 'Déverrouillage dans',
      'hours': 'heures',
      'minutes': 'minutes',

      // Lesson
      'lesson_title': 'Leçon',
      'summary': 'Résumé',
      'content': 'Contenu',
      'exercises': 'Exercices',
      'complete_exercises': 'Complétez les exercices pour déverrouiller la leçon suivante',
      'lesson_locked': 'Cette leçon est verrouillée',
      'lesson_locked_message': 'Complétez la leçon précédente à 70% ou attendez le lendemain',
      'next_lesson_in': 'Prochaine leçon dans',
      'lesson_completed': 'Leçon terminée! 🎉',
      'well_done': 'Bravo!',
      'completed_lessons': 'Leçons terminées',
      'time_remaining': 'Temps restant',

      // Exercises
      'question': 'Question',
      'true': 'Vrai',
      'false': 'Faux',
      'submit': 'Soumettre',
      'correct': 'Bonne réponse! ✅',
      'incorrect': 'Mauvaise réponse ❌',
      'explanation': 'Explication',

      // Profile
      'profile': 'Profil',
      'settings': 'Paramètres',
      'change_year': "Changer d'année scolaire",
      'change_language': 'Changer de langue',
      'privacy_policy': 'Politique de confidentialité',
      'logout': 'Déconnexion',
      'language': 'Langue',
      'arabic': 'Arabe',
      'french': 'Français',
      'total_lessons': 'Total des leçons',
      'your_year': 'Votre année',
      'learning_stats': "Statistiques d'apprentissage",
      'member_since': 'Membre depuis',

      // Search
      'search': 'Recherche',
      'search_hint': 'Rechercher une matière ou leçon...',
      'no_results': 'Aucun résultat',
      'all': 'Tout',
      'recent_subjects': 'Matières',
      'browse_all': 'Parcourir tout',

      // Achievements
      'achievements': 'Succès',
      'your_achievements': 'Vos succès',
      'badges_and_medals': 'Badges et médailles',
      'subject_progress': 'Progression par matière',
      'achievement_earned': 'Vous avez obtenu ce badge! 🎉',
      'achievement_locked': 'Continuez à apprendre pour débloquer ce badge 🔒',

      // Achievement names
      'first_lesson': 'Première leçon',
      'streak_3_days': 'Apprenant régulier',
      'fast_learner': 'Apprenant rapide',
      'diligent_student': 'Élève diligent',
      'perfect_score': 'Score parfait',
      'bookworm': 'Bibliophile',
      'champion': 'Champion',
      'explorer': 'Explorateur',
      'master': 'Maître',

      // Settings & Privacy
      'notifications': 'Notifications',
      'offline_mode': 'Mode hors ligne',
      'clear_cache': 'Vider le cache',
      'about_app': "À propos de l'application",
      'version': 'Version',
      'privacy_content': "Cette application collecte des données d'utilisation pour améliorer l'expérience d'apprentissage. Nous nous engageons à protéger votre vie privée.",

      // Common
      'ok': 'OK',
      'cancel': 'Annuler',
      'save': 'Enregistrer',
      'close': 'Fermer',
      'error': 'Erreur',
      'success': 'Succès',
      'loading': 'Chargement...',
      'retry': 'Réessayer',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // App
  String get appTitle => translate('app_title');

  // Authentication
  String get welcome => translate('welcome');
  String get phoneAuthTitle => translate('phone_auth_title');
  String get enterPhone => translate('enter_phone');
  String get phoneHint => translate('phone_hint');
  String get sendCode => translate('send_code');
  String get enterOtp => translate('enter_otp');
  String get verify => translate('verify');
  String get resendCode => translate('resend_code');

  // Greetings
  String get goodMorning => translate('good_morning');
  String get goodAfternoon => translate('good_afternoon');
  String get goodEvening => translate('good_evening');
  String get keepLearning => translate('keep_learning');

  // Year selection
  String get selectYearTitle => translate('select_year_title');
  String get selectYearSubtitle => translate('select_year_subtitle');
  String get continueText => translate('continue');

  // Home
  String get homeTitle => translate('home_title');
  String get mySubjects => translate('my_subjects');
  String get progress => translate('progress');
  String get noSubjects => translate('no_subjects');
  String get subjects => translate('subjects');
  String get unlockedLessons => translate('unlocked_lessons');
  String get overallProgress => translate('overall_progress');
  String get noNotifications => translate('no_notifications');

  // Subject
  String get lessons => translate('lessons');
  String get locked => translate('locked');
  String get unlocked => translate('unlocked');
  String get completed => translate('completed');
  String get unlockIn => translate('unlock_in');
  String get hours => translate('hours');
  String get minutes => translate('minutes');

  // Lesson
  String get lessonTitle => translate('lesson_title');
  String get summary => translate('summary');
  String get content => translate('content');
  String get exercises => translate('exercises');
  String get completeExercises => translate('complete_exercises');
  String get lessonLocked => translate('lesson_locked');
  String get lessonLockedMessage => translate('lesson_locked_message');
  String get nextLessonIn => translate('next_lesson_in');
  String get lessonCompleted => translate('lesson_completed');
  String get wellDone => translate('well_done');
  String get completedLessons => translate('completed_lessons');
  String get timeRemaining => translate('time_remaining');

  // Exercises
  String get question => translate('question');
  String get trueText => translate('true');
  String get falseText => translate('false');
  String get submit => translate('submit');
  String get correct => translate('correct');
  String get incorrect => translate('incorrect');
  String get explanation => translate('explanation');

  // Profile
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get changeYear => translate('change_year');
  String get changeLanguage => translate('change_language');
  String get privacyPolicy => translate('privacy_policy');
  String get logout => translate('logout');
  String get language => translate('language');
  String get arabic => translate('arabic');
  String get french => translate('french');
  String get totalLessons => translate('total_lessons');
  String get yourYear => translate('your_year');
  String get learningStats => translate('learning_stats');
  String get memberSince => translate('member_since');

  // Search
  String get search => translate('search');
  String get searchHint => translate('search_hint');
  String get noResults => translate('no_results');
  String get all => translate('all');
  String get recentSubjects => translate('recent_subjects');
  String get browseAll => translate('browse_all');

  // Achievements
  String get achievements => translate('achievements');
  String get yourAchievements => translate('your_achievements');
  String get badgesAndMedals => translate('badges_and_medals');
  String get subjectProgress => translate('subject_progress');
  String get achievementEarned => translate('achievement_earned');
  String get achievementLocked => translate('achievement_locked');

  // Achievement names
  String get firstLesson => translate('first_lesson');
  String get streak3Days => translate('streak_3_days');
  String get fastLearner => translate('fast_learner');
  String get diligentStudent => translate('diligent_student');
  String get perfectScore => translate('perfect_score');
  String get bookworm => translate('bookworm');
  String get champion => translate('champion');
  String get explorer => translate('explorer');
  String get master => translate('master');

  // Settings & Privacy
  String get notifications => translate('notifications');
  String get offlineMode => translate('offline_mode');
  String get clearCache => translate('clear_cache');
  String get aboutApp => translate('about_app');
  String get version => translate('version');
  String get privacyContent => translate('privacy_content');

  // Common
  String get ok => translate('ok');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get close => translate('close');
  String get error => translate('error');
  String get success => translate('success');
  String get loading => translate('loading');
  String get retry => translate('retry');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
