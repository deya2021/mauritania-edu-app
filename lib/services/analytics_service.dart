import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Get observer for navigation tracking
  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }
  
  // User Events
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
    if (kDebugMode) {
      print('Analytics: User logged in via $method');
    }
  }
  
  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
    if (kDebugMode) {
      print('Analytics: User signed up via $method');
    }
  }
  
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
    if (kDebugMode) {
      print('Analytics: User ID set to $userId');
    }
  }
  
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
    if (kDebugMode) {
      print('Analytics: User property $name = $value');
    }
  }
  
  // Screen Events
  Future<void> logScreenView(String screenName, String screenClass) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
    if (kDebugMode) {
      print('Analytics: Screen view - $screenName');
    }
  }
  
  // Content Events
  Future<void> logLessonOpened(String lessonId, String lessonName) async {
    await _analytics.logEvent(
      name: 'lesson_opened',
      parameters: {
        'lesson_id': lessonId,
        'lesson_name': lessonName,
      },
    );
    if (kDebugMode) {
      print('Analytics: Lesson opened - $lessonName');
    }
  }
  
  Future<void> logLessonCompleted(
    String lessonId,
    String lessonName,
    int completionPercentage,
  ) async {
    await _analytics.logEvent(
      name: 'lesson_completed',
      parameters: {
        'lesson_id': lessonId,
        'lesson_name': lessonName,
        'completion_percentage': completionPercentage,
      },
    );
    if (kDebugMode) {
      print('Analytics: Lesson completed - $lessonName ($completionPercentage%)');
    }
  }
  
  Future<void> logSubjectViewed(String subjectId, String subjectName) async {
    await _analytics.logEvent(
      name: 'subject_viewed',
      parameters: {
        'subject_id': subjectId,
        'subject_name': subjectName,
      },
    );
    if (kDebugMode) {
      print('Analytics: Subject viewed - $subjectName');
    }
  }
  
  // Exercise Events
  Future<void> logExerciseStarted(
    String exerciseId,
    String exerciseType,
    String lessonId,
  ) async {
    await _analytics.logEvent(
      name: 'exercise_started',
      parameters: {
        'exercise_id': exerciseId,
        'exercise_type': exerciseType,
        'lesson_id': lessonId,
      },
    );
    if (kDebugMode) {
      print('Analytics: Exercise started - $exerciseType');
    }
  }
  
  Future<void> logExerciseCompleted(
    String exerciseId,
    String exerciseType,
    bool isCorrect,
    String lessonId,
  ) async {
    await _analytics.logEvent(
      name: 'exercise_completed',
      parameters: {
        'exercise_id': exerciseId,
        'exercise_type': exerciseType,
        'is_correct': isCorrect,
        'lesson_id': lessonId,
      },
    );
    if (kDebugMode) {
      print('Analytics: Exercise completed - ${isCorrect ? "Correct" : "Incorrect"}');
    }
  }
  
  // Progress Events
  Future<void> logLessonUnlocked(
    String lessonId,
    String lessonName,
    String unlockMethod,
  ) async {
    await _analytics.logEvent(
      name: 'lesson_unlocked',
      parameters: {
        'lesson_id': lessonId,
        'lesson_name': lessonName,
        'unlock_method': unlockMethod, // '24h_auto', '70%_completion', 'manual'
      },
    );
    if (kDebugMode) {
      print('Analytics: Lesson unlocked - $lessonName via $unlockMethod');
    }
  }
  
  Future<void> logProgressUpdate(
    String subjectId,
    String subjectName,
    int totalLessons,
    int unlockedLessons,
  ) async {
    final percentage = (unlockedLessons / totalLessons * 100).round();
    
    await _analytics.logEvent(
      name: 'progress_update',
      parameters: {
        'subject_id': subjectId,
        'subject_name': subjectName,
        'total_lessons': totalLessons,
        'unlocked_lessons': unlockedLessons,
        'progress_percentage': percentage,
      },
    );
    if (kDebugMode) {
      print('Analytics: Progress updated - $subjectName $percentage%');
    }
  }
  
  // Language & Settings Events
  Future<void> logLanguageChanged(String fromLanguage, String toLanguage) async {
    await _analytics.logEvent(
      name: 'language_changed',
      parameters: {
        'from_language': fromLanguage,
        'to_language': toLanguage,
      },
    );
    if (kDebugMode) {
      print('Analytics: Language changed from $fromLanguage to $toLanguage');
    }
  }
  
  Future<void> logYearSelected(String yearId, String yearName) async {
    await _analytics.logEvent(
      name: 'year_selected',
      parameters: {
        'year_id': yearId,
        'year_name': yearName,
      },
    );
    if (kDebugMode) {
      print('Analytics: Year selected - $yearName');
    }
  }
  
  // Ad Events
  Future<void> logAdViewed(String adSlot, String adId) async {
    await _analytics.logEvent(
      name: 'ad_viewed',
      parameters: {
        'ad_slot': adSlot,
        'ad_id': adId,
      },
    );
    if (kDebugMode) {
      print('Analytics: Ad viewed - $adSlot');
    }
  }
  
  Future<void> logAdClicked(String adSlot, String adId, String targetUrl) async {
    await _analytics.logEvent(
      name: 'ad_clicked',
      parameters: {
        'ad_slot': adSlot,
        'ad_id': adId,
        'target_url': targetUrl,
      },
    );
    if (kDebugMode) {
      print('Analytics: Ad clicked - $adSlot -> $targetUrl');
    }
  }
  
  // Error Events
  Future<void> logError(String errorType, String errorMessage) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
      },
    );
    if (kDebugMode) {
      print('Analytics: Error - $errorType: $errorMessage');
    }
  }
  
  // Custom Events
  Future<void> logCustomEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
    if (kDebugMode) {
      print('Analytics: Custom event - $eventName');
    }
  }
  
  // Session Events
  Future<void> logAppOpened() async {
    await _analytics.logAppOpen();
    if (kDebugMode) {
      print('Analytics: App opened');
    }
  }
  
  Future<void> logSessionStart() async {
    await _analytics.logEvent(name: 'session_start');
    if (kDebugMode) {
      print('Analytics: Session started');
    }
  }
  
  Future<void> logSessionEnd(int durationSeconds) async {
    await _analytics.logEvent(
      name: 'session_end',
      parameters: {'duration_seconds': durationSeconds},
    );
    if (kDebugMode) {
      print('Analytics: Session ended - ${durationSeconds}s');
    }
  }
}

// Analytics event names (for consistency)
class AnalyticsEvents {
  static const String login = 'login';
  static const String signUp = 'sign_up';
  static const String lessonOpened = 'lesson_opened';
  static const String lessonCompleted = 'lesson_completed';
  static const String exerciseStarted = 'exercise_started';
  static const String exerciseCompleted = 'exercise_completed';
  static const String lessonUnlocked = 'lesson_unlocked';
  static const String languageChanged = 'language_changed';
  static const String yearSelected = 'year_selected';
  static const String adViewed = 'ad_viewed';
  static const String adClicked = 'ad_clicked';
}
