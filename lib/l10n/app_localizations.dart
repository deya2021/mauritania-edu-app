import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      // Authentication
      'welcome': 'مرحباً',
      'phone_auth_title': 'تسجيل الدخول',
      'enter_phone': 'أدخل رقم هاتفك',
      'phone_hint': '+222 XX XX XX XX',
      'send_code': 'إرسال الرمز',
      'enter_otp': 'أدخل رمز التحقق',
      'verify': 'تحقق',
      'resend_code': 'إعادة إرسال الرمز',
      
      // Year selection
      'select_year_title': 'اختر سنتك الدراسية',
      'select_year_subtitle': 'اختر السنة الدراسية لرؤية المحتوى المناسب',
      'continue': 'متابعة',
      
      // Home
      'home_title': 'الرئيسية',
      'my_subjects': 'موادي الدراسية',
      'progress': 'التقدم',
      'no_subjects': 'لا توجد مواد متاحة',
      
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
      
      // Exercises
      'question': 'السؤال',
      'true': 'صحيح',
      'false': 'خاطئ',
      'submit': 'إرسال',
      'correct': 'إجابة صحيحة!',
      'incorrect': 'إجابة خاطئة',
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
      // Authentication
      'welcome': 'Bienvenue',
      'phone_auth_title': 'Connexion',
      'enter_phone': 'Entrez votre numéro de téléphone',
      'phone_hint': '+222 XX XX XX XX',
      'send_code': 'Envoyer le code',
      'enter_otp': 'Entrez le code de vérification',
      'verify': 'Vérifier',
      'resend_code': 'Renvoyer le code',
      
      // Year selection
      'select_year_title': 'Sélectionnez votre année scolaire',
      'select_year_subtitle': 'Choisissez votre année pour voir le contenu approprié',
      'continue': 'Continuer',
      
      // Home
      'home_title': 'Accueil',
      'my_subjects': 'Mes Matières',
      'progress': 'Progression',
      'no_subjects': 'Aucune matière disponible',
      
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
      
      // Exercises
      'question': 'Question',
      'true': 'Vrai',
      'false': 'Faux',
      'submit': 'Soumettre',
      'correct': 'Bonne réponse!',
      'incorrect': 'Mauvaise réponse',
      'explanation': 'Explication',
      
      // Profile
      'profile': 'Profil',
      'settings': 'Paramètres',
      'change_year': 'Changer d\'année scolaire',
      'change_language': 'Changer de langue',
      'privacy_policy': 'Politique de confidentialité',
      'logout': 'Déconnexion',
      'language': 'Langue',
      'arabic': 'Arabe',
      'french': 'Français',
      
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
  
  String get welcome => translate('welcome');
  String get phoneAuthTitle => translate('phone_auth_title');
  String get enterPhone => translate('enter_phone');
  String get phoneHint => translate('phone_hint');
  String get sendCode => translate('send_code');
  String get enterOtp => translate('enter_otp');
  String get verify => translate('verify');
  String get resendCode => translate('resend_code');
  
  String get selectYearTitle => translate('select_year_title');
  String get selectYearSubtitle => translate('select_year_subtitle');
  String get continueText => translate('continue');
  
  String get homeTitle => translate('home_title');
  String get mySubjects => translate('my_subjects');
  String get progress => translate('progress');
  String get noSubjects => translate('no_subjects');
  
  String get lessons => translate('lessons');
  String get locked => translate('locked');
  String get unlocked => translate('unlocked');
  String get completed => translate('completed');
  String get unlockIn => translate('unlock_in');
  String get hours => translate('hours');
  String get minutes => translate('minutes');
  
  String get lessonTitle => translate('lesson_title');
  String get summary => translate('summary');
  String get content => translate('content');
  String get exercises => translate('exercises');
  String get completeExercises => translate('complete_exercises');
  String get lessonLocked => translate('lesson_locked');
  String get lessonLockedMessage => translate('lesson_locked_message');
  
  String get question => translate('question');
  String get trueText => translate('true');
  String get falseText => translate('false');
  String get submit => translate('submit');
  String get correct => translate('correct');
  String get incorrect => translate('incorrect');
  String get explanation => translate('explanation');
  
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get changeYear => translate('change_year');
  String get changeLanguage => translate('change_language');
  String get privacyPolicy => translate('privacy_policy');
  String get logout => translate('logout');
  String get language => translate('language');
  String get arabic => translate('arabic');
  String get french => translate('french');
  
  String get ok => translate('ok');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get close => translate('close');
  String get error => translate('error');
  String get success => translate('success');
  String get loading => translate('loading');
  String get retry => translate('retry');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
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
