import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  // Initialize notifications
  Future<void> initialize() async {
    // Request permission (iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted notification permission');
      }
    }
    
    // Get FCM token
    final token = await _messaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }
    
    // Save token to preferences
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    }
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Check for initial message (app opened from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }
  
  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message: ${message.notification?.title}');
    }
    
    // Show local notification or update UI
    // You can use flutter_local_notifications package for better control
  }
  
  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification tapped: ${message.data}');
    }
    
    // Navigate to specific screen based on message data
    final type = message.data['type'];
    final targetId = message.data['targetId'];
    
    switch (type) {
      case 'lesson_unlocked':
        // Navigate to lesson screen
        break;
      case 'new_content':
        // Navigate to subject screen
        break;
      case 'exercise_reminder':
        // Navigate to lesson with exercises
        break;
    }
  }
  
  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    if (kDebugMode) {
      print('Subscribed to topic: $topic');
    }
  }
  
  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    if (kDebugMode) {
      print('Unsubscribed from topic: $topic');
    }
  }
  
  // Subscribe to year-specific notifications
  Future<void> subscribeToYearNotifications(String yearId) async {
    await subscribeToTopic('year_$yearId');
  }
  
  // Subscribe to subject-specific notifications
  Future<void> subscribeToSubjectNotifications(String subjectId) async {
    await subscribeToTopic('subject_$subjectId');
  }
  
  // Schedule local notifications (requires flutter_local_notifications)
  Future<void> scheduleLessonUnlockReminder(
    String lessonId,
    DateTime unlockTime,
  ) async {
    // Implementation with flutter_local_notifications
    // This allows scheduling notifications even without server
  }
  
  // Send notification to server (for user-to-user notifications)
  Future<void> sendNotificationToUser(
    String userId,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    // Call your backend API to send notification via FCM
    // Backend should use Firebase Admin SDK
  }
}

// Top-level function for background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background message: ${message.notification?.title}');
  }
}

// Notification types for the app
class NotificationTypes {
  static const String lessonUnlocked = 'lesson_unlocked';
  static const String newContent = 'new_content';
  static const String exerciseReminder = 'exercise_reminder';
  static const String achievementUnlocked = 'achievement_unlocked';
  static const String dailyReminder = 'daily_reminder';
}

// Notification payload data structure
class NotificationPayload {
  final String type;
  final String? targetId;
  final String? title;
  final String? body;
  final Map<String, dynamic>? additionalData;
  
  NotificationPayload({
    required this.type,
    this.targetId,
    this.title,
    this.body,
    this.additionalData,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'targetId': targetId,
      'title': title,
      'body': body,
      if (additionalData != null) ...additionalData!,
    };
  }
  
  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      type: map['type'] ?? '',
      targetId: map['targetId'],
      title: map['title'],
      body: map['body'],
      additionalData: Map<String, dynamic>.from(map)
        ..remove('type')
        ..remove('targetId')
        ..remove('title')
        ..remove('body'),
    );
  }
}
