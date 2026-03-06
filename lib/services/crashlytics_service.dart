import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  
  // Initialize Crashlytics
  Future<void> initialize() async {
    // Enable Crashlytics collection
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    
    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    
    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    
    if (kDebugMode) {
      print('Crashlytics initialized (disabled in debug mode)');
    }
  }
  
  // Set user identifier
  Future<void> setUserId(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
    if (kDebugMode) {
      print('Crashlytics: User ID set to $userId');
    }
  }
  
  // Set custom key-value pairs
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
    if (kDebugMode) {
      print('Crashlytics: Custom key $key = $value');
    }
  }
  
  // Log message
  Future<void> log(String message) async {
    await _crashlytics.log(message);
    if (kDebugMode) {
      print('Crashlytics Log: $message');
    }
  }
  
  // Record error (non-fatal)
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
    
    if (kDebugMode) {
      print('Crashlytics: Recorded error - $exception');
    }
  }
  
  // Record Flutter error
  Future<void> recordFlutterError(FlutterErrorDetails errorDetails) async {
    await _crashlytics.recordFlutterError(errorDetails);
    
    if (kDebugMode) {
      print('Crashlytics: Recorded Flutter error');
    }
  }
  
  // Test crash (for testing only)
  void testCrash() {
    if (kDebugMode) {
      print('Test crash triggered');
    }
    _crashlytics.crash();
  }
  
  // Set user properties for better debugging
  Future<void> setUserProperties({
    required String userId,
    String? yearId,
    String? selectedLanguage,
    String? appVersion,
  }) async {
    await setUserId(userId);
    
    if (yearId != null) {
      await setCustomKey('selected_year', yearId);
    }
    
    if (selectedLanguage != null) {
      await setCustomKey('language', selectedLanguage);
    }
    
    if (appVersion != null) {
      await setCustomKey('app_version', appVersion);
    }
  }
  
  // Record lesson-related errors
  Future<void> recordLessonError(
    String lessonId,
    String errorMessage,
    StackTrace? stack,
  ) async {
    await setCustomKey('lesson_id', lessonId);
    await log('Lesson error: $errorMessage');
    await recordError(
      Exception('Lesson Error: $errorMessage'),
      stack,
      reason: 'Error in lesson $lessonId',
    );
  }
  
  // Record data loading errors
  Future<void> recordDataLoadError(
    String dataType,
    String errorMessage,
    StackTrace? stack,
  ) async {
    await setCustomKey('data_type', dataType);
    await log('Data load error: $errorMessage');
    await recordError(
      Exception('Data Load Error: $errorMessage'),
      stack,
      reason: 'Failed to load $dataType',
    );
  }
  
  // Record authentication errors
  Future<void> recordAuthError(
    String authMethod,
    String errorMessage,
    StackTrace? stack,
  ) async {
    await setCustomKey('auth_method', authMethod);
    await log('Auth error: $errorMessage');
    await recordError(
      Exception('Auth Error: $errorMessage'),
      stack,
      reason: 'Authentication failed via $authMethod',
    );
  }
  
  // Record network errors
  Future<void> recordNetworkError(
    String endpoint,
    String errorMessage,
    StackTrace? stack,
  ) async {
    await setCustomKey('endpoint', endpoint);
    await log('Network error: $errorMessage');
    await recordError(
      Exception('Network Error: $errorMessage'),
      stack,
      reason: 'Network request failed: $endpoint',
    );
  }
}

// Error handler wrapper for try-catch blocks
class ErrorHandler {
  static final CrashlyticsService _crashlytics = CrashlyticsService();
  
  // Execute function with error handling
  static Future<T?> execute<T>({
    required Future<T> Function() function,
    String? errorMessage,
    T? defaultValue,
    bool silent = false,
  }) async {
    try {
      return await function();
    } catch (error, stackTrace) {
      // Log to Crashlytics
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: errorMessage,
      );
      
      // Log to console in debug mode
      if (kDebugMode && !silent) {
        print('Error: ${errorMessage ?? error}');
        print('Stack trace: $stackTrace');
      }
      
      return defaultValue;
    }
  }
  
  // Execute synchronous function with error handling
  static T? executeSync<T>({
    required T Function() function,
    String? errorMessage,
    T? defaultValue,
    bool silent = false,
  }) {
    try {
      return function();
    } catch (error, stackTrace) {
      // Log to Crashlytics
      _crashlytics.recordError(
        error,
        stackTrace,
        reason: errorMessage,
      );
      
      // Log to console in debug mode
      if (kDebugMode && !silent) {
        print('Error: ${errorMessage ?? error}');
        print('Stack trace: $stackTrace');
      }
      
      return defaultValue;
    }
  }
}

// Custom error types for better categorization
class AppError {
  final String type;
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;
  
  AppError({
    required this.type,
    required this.message,
    this.originalError,
    this.stackTrace,
  });
  
  @override
  String toString() => 'AppError[$type]: $message';
}

class DataLoadError extends AppError {
  DataLoadError(String message, {dynamic originalError, StackTrace? stackTrace})
      : super(
          type: 'DataLoad',
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class AuthenticationError extends AppError {
  AuthenticationError(String message, {dynamic originalError, StackTrace? stackTrace})
      : super(
          type: 'Authentication',
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class NetworkError extends AppError {
  NetworkError(String message, {dynamic originalError, StackTrace? stackTrace})
      : super(
          type: 'Network',
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class LessonError extends AppError {
  LessonError(String message, {dynamic originalError, StackTrace? stackTrace})
      : super(
          type: 'Lesson',
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}
