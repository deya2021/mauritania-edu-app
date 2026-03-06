import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Enhanced local storage service with caching and offline support
class StorageService {
  final SharedPreferences _prefs;
  
  // Keys
  static const String _cachedContentPrefix = 'cached_content_';
  static const String _cachedImagesPrefix = 'cached_images_';
  static const String _offlineModeKey = 'offline_mode';
  static const String _lastSyncKey = 'last_sync';
  static const String _userProgressKey = 'user_progress';
  
  StorageService(this._prefs);
  
  // Initialize storage
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }
  
  // === Content Caching ===
  
  /// Cache lesson content for offline access
  Future<void> cacheLessonContent(String lessonId, Map<String, dynamic> content) async {
    try {
      final key = '$_cachedContentPrefix$lessonId';
      final jsonString = json.encode(content);
      await _prefs.setString(key, jsonString);
      print('✅ Cached lesson content: $lessonId');
    } catch (e) {
      print('❌ Error caching lesson content: $e');
    }
  }
  
  /// Get cached lesson content
  Map<String, dynamic>? getCachedLessonContent(String lessonId) {
    try {
      final key = '$_cachedContentPrefix$lessonId';
      final jsonString = _prefs.getString(key);
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('❌ Error reading cached lesson content: $e');
    }
    return null;
  }
  
  /// Check if lesson is cached
  bool isLessonCached(String lessonId) {
    final key = '$_cachedContentPrefix$lessonId';
    return _prefs.containsKey(key);
  }
  
  /// Cache multiple lessons at once
  Future<void> cacheLessons(Map<String, Map<String, dynamic>> lessons) async {
    for (var entry in lessons.entries) {
      await cacheLessonContent(entry.key, entry.value);
    }
  }
  
  // === Image Caching ===
  
  /// Cache image URL mapping for offline display
  Future<void> cacheImageUrl(String imageId, String url) async {
    final key = '$_cachedImagesPrefix$imageId';
    await _prefs.setString(key, url);
  }
  
  /// Get cached image URL
  String? getCachedImageUrl(String imageId) {
    final key = '$_cachedImagesPrefix$imageId';
    return _prefs.getString(key);
  }
  
  // === User Progress Caching ===
  
  /// Cache user progress locally
  Future<void> cacheUserProgress(Map<String, dynamic> progress) async {
    try {
      final jsonString = json.encode(progress);
      await _prefs.setString(_userProgressKey, jsonString);
      print('✅ Cached user progress');
    } catch (e) {
      print('❌ Error caching user progress: $e');
    }
  }
  
  /// Get cached user progress
  Map<String, dynamic>? getCachedUserProgress() {
    try {
      final jsonString = _prefs.getString(_userProgressKey);
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('❌ Error reading cached user progress: $e');
    }
    return null;
  }
  
  // === Offline Mode ===
  
  /// Enable/disable offline mode
  Future<void> setOfflineMode(bool enabled) async {
    await _prefs.setBool(_offlineModeKey, enabled);
  }
  
  /// Check if offline mode is enabled
  bool isOfflineMode() {
    return _prefs.getBool(_offlineModeKey) ?? false;
  }
  
  // === Sync Management ===
  
  /// Update last sync timestamp
  Future<void> updateLastSync() async {
    await _prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  /// Get last sync timestamp
  DateTime? getLastSync() {
    final timestamp = _prefs.getInt(_lastSyncKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }
  
  // === Cache Management ===
  
  /// Get total cache size (approximate in KB)
  int getCacheSizeKB() {
    int totalSize = 0;
    final keys = _prefs.getKeys();
    for (var key in keys) {
      if (key.startsWith(_cachedContentPrefix) || key.startsWith(_cachedImagesPrefix)) {
        final value = _prefs.getString(key);
        if (value != null) {
          totalSize += value.length;
        }
      }
    }
    return (totalSize / 1024).round();
  }
  
  /// Clear all cached content
  Future<void> clearCache() async {
    final keys = _prefs.getKeys().where(
      (key) => key.startsWith(_cachedContentPrefix) || key.startsWith(_cachedImagesPrefix)
    ).toList();
    
    for (var key in keys) {
      await _prefs.remove(key);
    }
    print('✅ Cleared all cache');
  }
  
  /// Clear old cache (older than days)
  Future<void> clearOldCache(int days) async {
    // For now, clear all cache
    // In production, you'd track cache timestamp per item
    await clearCache();
  }
  
  // === Generic Storage ===
  
  /// Save generic string data
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }
  
  /// Get generic string data
  String? getString(String key) {
    return _prefs.getString(key);
  }
  
  /// Save generic int data
  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }
  
  /// Get generic int data
  int? getInt(String key) {
    return _prefs.getInt(key);
  }
  
  /// Save generic bool data
  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }
  
  /// Get generic bool data
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }
  
  /// Remove specific key
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
  
  /// Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
  
  /// Clear all data (use with caution!)
  Future<void> clearAll() async {
    await _prefs.clear();
    print('⚠️ Cleared all storage');
  }
}
