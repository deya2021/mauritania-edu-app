import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class LocalStorageService {
  static Database? _database;
  static const String _databaseName = 'mauritania_edu.db';
  static const int _databaseVersion = 1;
  
  // Table names
  static const String _lessonsTable = 'lessons';
  static const String _lessonContentsTable = 'lesson_contents';
  static const String _userProgressTable = 'user_progress';
  static const String _cacheTable = 'cache';
  
  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  // Initialize database
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    // Lessons table
    await db.execute('''
      CREATE TABLE $_lessonsTable (
        id TEXT PRIMARY KEY,
        unitId TEXT,
        subjectId TEXT,
        title TEXT,
        summary TEXT,
        contentLanguage TEXT,
        orderIndex INTEGER,
        cachedAt INTEGER
      )
    ''');
    
    // Lesson contents table
    await db.execute('''
      CREATE TABLE $_lessonContentsTable (
        id TEXT PRIMARY KEY,
        lessonId TEXT,
        sections TEXT,
        exercises TEXT,
        cachedAt INTEGER
      )
    ''');
    
    // User progress table (for offline sync)
    await db.execute('''
      CREATE TABLE $_userProgressTable (
        id TEXT PRIMARY KEY,
        userId TEXT,
        subjectId TEXT,
        unlockedLessonIds TEXT,
        lessonProgress TEXT,
        lastSyncedAt INTEGER,
        needsSync INTEGER DEFAULT 1
      )
    ''');
    
    // Generic cache table
    await db.execute('''
      CREATE TABLE $_cacheTable (
        key TEXT PRIMARY KEY,
        value TEXT,
        cachedAt INTEGER,
        expiresAt INTEGER
      )
    ''');
    
    // Create indices
    await db.execute('CREATE INDEX idx_lessons_subject ON $_lessonsTable(subjectId)');
    await db.execute('CREATE INDEX idx_progress_user ON $_userProgressTable(userId)');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades
    if (oldVersion < newVersion) {
      // Add migration logic here
    }
  }
  
  // ============ LESSON OPERATIONS ============
  
  // Cache lesson
  Future<void> cacheLesson(Lesson lesson) async {
    final db = await database;
    await db.insert(
      _lessonsTable,
      {
        'id': lesson.id,
        'unitId': lesson.unitId,
        'subjectId': lesson.subjectId,
        'title': jsonEncode(lesson.title),
        'summary': jsonEncode(lesson.summary),
        'contentLanguage': lesson.contentLanguage,
        'orderIndex': lesson.order,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Get cached lesson
  Future<Lesson?> getCachedLesson(String lessonId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _lessonsTable,
      where: 'id = ?',
      whereArgs: [lessonId],
    );
    
    if (maps.isEmpty) return null;
    
    final map = maps.first;
    return Lesson(
      id: map['id'],
      unitId: map['unitId'],
      subjectId: map['subjectId'],
      title: Map<String, String>.from(jsonDecode(map['title'])),
      summary: Map<String, String>.from(jsonDecode(map['summary'])),
      contentLanguage: map['contentLanguage'],
      order: map['orderIndex'],
    );
  }
  
  // Get cached lessons by subject
  Future<List<Lesson>> getCachedLessonsBySubject(String subjectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _lessonsTable,
      where: 'subjectId = ?',
      whereArgs: [subjectId],
      orderBy: 'orderIndex ASC',
    );
    
    return maps.map((map) {
      return Lesson(
        id: map['id'],
        unitId: map['unitId'],
        subjectId: map['subjectId'],
        title: Map<String, String>.from(jsonDecode(map['title'])),
        summary: Map<String, String>.from(jsonDecode(map['summary'])),
        contentLanguage: map['contentLanguage'],
        order: map['orderIndex'],
      );
    }).toList();
  }
  
  // ============ LESSON CONTENT OPERATIONS ============
  
  // Cache lesson content
  Future<void> cacheLessonContent(LessonContent content) async {
    final db = await database;
    await db.insert(
      _lessonContentsTable,
      {
        'id': content.id,
        'lessonId': content.lessonId,
        'sections': jsonEncode(content.sections.map((s) => s.toMap()).toList()),
        'exercises': jsonEncode(content.exercises.map((e) => e.toMap()).toList()),
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Get cached lesson content
  Future<LessonContent?> getCachedLessonContent(String lessonId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _lessonContentsTable,
      where: 'lessonId = ?',
      whereArgs: [lessonId],
    );
    
    if (maps.isEmpty) return null;
    
    final map = maps.first;
    return LessonContent(
      id: map['id'],
      lessonId: map['lessonId'],
      sections: (jsonDecode(map['sections']) as List)
          .map((s) => ContentSection.fromMap(s))
          .toList(),
      exercises: (jsonDecode(map['exercises']) as List)
          .map((e) => Exercise.fromMap(e))
          .toList(),
    );
  }
  
  // ============ USER PROGRESS OPERATIONS ============
  
  // Save progress for offline sync
  Future<void> saveProgressForSync(UserProgress progress) async {
    final db = await database;
    await db.insert(
      _userProgressTable,
      {
        'id': '${progress.userId}_${progress.subjectId}',
        'userId': progress.userId,
        'subjectId': progress.subjectId,
        'unlockedLessonIds': jsonEncode(progress.unlockedLessonIds),
        'lessonProgress': jsonEncode(
          progress.lessonProgress.map((key, value) => MapEntry(key, value.toMap())),
        ),
        'lastSyncedAt': DateTime.now().millisecondsSinceEpoch,
        'needsSync': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Get progress that needs sync
  Future<List<UserProgress>> getProgressNeedingSync() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _userProgressTable,
      where: 'needsSync = ?',
      whereArgs: [1],
    );
    
    return maps.map((map) {
      final lessonProgressMap = <String, LessonProgress>{};
      final decoded = jsonDecode(map['lessonProgress']) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        lessonProgressMap[key] = LessonProgress.fromMap(value);
      });
      
      return UserProgress(
        userId: map['userId'],
        subjectId: map['subjectId'],
        unlockedLessonIds: List<String>.from(jsonDecode(map['unlockedLessonIds'])),
        lessonProgress: lessonProgressMap,
      );
    }).toList();
  }
  
  // Mark progress as synced
  Future<void> markProgressAsSynced(String userId, String subjectId) async {
    final db = await database;
    await db.update(
      _userProgressTable,
      {'needsSync': 0, 'lastSyncedAt': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: ['${userId}_$subjectId'],
    );
  }
  
  // ============ GENERIC CACHE OPERATIONS ============
  
  // Set cache value
  Future<void> setCacheValue(
    String key,
    String value, {
    Duration? expiresIn,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = expiresIn != null
        ? now + expiresIn.inMilliseconds
        : null;
    
    await db.insert(
      _cacheTable,
      {
        'key': key,
        'value': value,
        'cachedAt': now,
        'expiresAt': expiresAt,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Get cache value
  Future<String?> getCacheValue(String key) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final List<Map<String, dynamic>> maps = await db.query(
      _cacheTable,
      where: 'key = ? AND (expiresAt IS NULL OR expiresAt > ?)',
      whereArgs: [key, now],
    );
    
    if (maps.isEmpty) return null;
    return maps.first['value'];
  }
  
  // Clear expired cache
  Future<void> clearExpiredCache() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await db.delete(
      _cacheTable,
      where: 'expiresAt IS NOT NULL AND expiresAt < ?',
      whereArgs: [now],
    );
  }
  
  // Clear all cache
  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete(_cacheTable);
  }
  
  // ============ MAINTENANCE OPERATIONS ============
  
  // Get database size
  Future<int> getDatabaseSize() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    final file = await documentsDirectory.parent.list().firstWhere(
      (entity) => entity.path == path,
      orElse: () => throw Exception('Database not found'),
    );
    return await file.stat().then((stat) => stat.size);
  }
  
  // Clear old cached lessons (older than 30 days)
  Future<void> clearOldCache({int daysOld = 30}) async {
    final db = await database;
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: daysOld))
        .millisecondsSinceEpoch;
    
    await db.delete(
      _lessonsTable,
      where: 'cachedAt < ?',
      whereArgs: [cutoffTime],
    );
    
    await db.delete(
      _lessonContentsTable,
      where: 'cachedAt < ?',
      whereArgs: [cutoffTime],
    );
  }
  
  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

// Sync manager for online/offline sync
class SyncManager {
  final LocalStorageService _localStorage = LocalStorageService();
  
  // Sync all pending progress to Firestore
  Future<void> syncPendingProgress() async {
    final progressList = await _localStorage.getProgressNeedingSync();
    
    for (final progress in progressList) {
      try {
        // Upload to Firestore
        // await firestoreService.updateUserProgress(progress);
        
        // Mark as synced
        await _localStorage.markProgressAsSynced(
          progress.userId,
          progress.subjectId,
        );
      } catch (e) {
        // Keep in local storage for retry
        print('Failed to sync progress: $e');
      }
    }
  }
  
  // Check if sync is needed
  Future<bool> needsSync() async {
    final progressList = await _localStorage.getProgressNeedingSync();
    return progressList.isNotEmpty;
  }
}
