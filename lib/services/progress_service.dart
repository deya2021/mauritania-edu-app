import '../models/models.dart';
import 'firestore_service.dart';

class ProgressService {
  final FirestoreService _firestoreService;
  
  ProgressService(this._firestoreService);
  
  // Check if a lesson should be unlocked
  Future<bool> shouldUnlockLesson(
    String userId,
    String subjectId,
    String lessonId,
  ) async {
    final progress = await _firestoreService.getUserProgress(userId, subjectId);
    
    // If no progress exists, first lesson should be unlocked
    if (progress == null) {
      return true;
    }
    
    // If lesson is already unlocked
    if (progress.unlockedLessonIds.contains(lessonId)) {
      return true;
    }
    
    // Check daily unlock limit
    final now = DateTime.now();
    final lastUnlockDate = progress.lastUnlockDate;
    
    // Reset daily count if it's a new day
    int currentDailyCount = progress.dailyUnlockCount;
    if (lastUnlockDate == null || !_isSameDay(lastUnlockDate, now)) {
      currentDailyCount = 0;
    }
    
    // Maximum 2 lessons per day
    if (currentDailyCount >= 2) {
      return false;
    }
    
    // First lesson of the day (automatic unlock)
    if (currentDailyCount == 0) {
      // Check if at least 24 hours have passed since last unlock
      if (progress.lastUnlockTimestamp != null) {
        final hoursSinceLastUnlock = now.difference(progress.lastUnlockTimestamp!).inHours;
        if (hoursSinceLastUnlock < 24) {
          return false;
        }
      }
      return true;
    }
    
    // Second lesson of the day (requires 70% completion of current lesson)
    if (currentDailyCount == 1) {
      // Get the last unlocked lesson
      if (progress.unlockedLessonIds.isNotEmpty) {
        final lastUnlockedLessonId = progress.unlockedLessonIds.last;
        final lessonProgress = progress.lessonProgress[lastUnlockedLessonId];
        
        if (lessonProgress != null && lessonProgress.completionPercentage >= 70) {
          return true;
        }
      }
      return false;
    }
    
    return false;
  }
  
  // Unlock a lesson
  Future<void> unlockLesson(
    String userId,
    String subjectId,
    String lessonId,
  ) async {
    final progress = await _firestoreService.getUserProgress(userId, subjectId);
    final now = DateTime.now();
    
    if (progress == null) {
      // Create new progress
      final newProgress = UserProgress(
        userId: userId,
        subjectId: subjectId,
        unlockedLessonIds: [lessonId],
        lastUnlockTimestamp: now,
        dailyUnlockCount: 1,
        lastUnlockDate: now,
      );
      await _firestoreService.updateUserProgress(newProgress);
    } else {
      // Update existing progress
      final unlockedLessons = List<String>.from(progress.unlockedLessonIds);
      if (!unlockedLessons.contains(lessonId)) {
        unlockedLessons.add(lessonId);
      }
      
      // Calculate new daily count
      int newDailyCount = progress.dailyUnlockCount;
      if (progress.lastUnlockDate == null || !_isSameDay(progress.lastUnlockDate!, now)) {
        newDailyCount = 1;
      } else {
        newDailyCount++;
      }
      
      final updatedProgress = UserProgress(
        userId: userId,
        subjectId: subjectId,
        unlockedLessonIds: unlockedLessons,
        lastUnlockTimestamp: now,
        dailyUnlockCount: newDailyCount,
        lastUnlockDate: now,
        lessonProgress: progress.lessonProgress,
      );
      
      await _firestoreService.updateUserProgress(updatedProgress);
    }
  }
  
  // Update lesson progress
  Future<void> updateLessonProgress(
    String userId,
    String subjectId,
    String lessonId,
    int totalExercises,
    Map<String, bool> exerciseResults,
  ) async {
    final progress = await _firestoreService.getUserProgress(userId, subjectId);
    
    if (progress == null) return;
    
    final completedExercises = exerciseResults.values.where((v) => v).length;
    
    final lessonProgress = LessonProgress(
      lessonId: lessonId,
      totalExercises: totalExercises,
      completedExercises: completedExercises,
      exerciseResults: exerciseResults,
      lastAccessedAt: DateTime.now(),
    );
    
    final updatedLessonProgress = Map<String, LessonProgress>.from(progress.lessonProgress);
    updatedLessonProgress[lessonId] = lessonProgress;
    
    final updatedProgress = UserProgress(
      userId: progress.userId,
      subjectId: progress.subjectId,
      unlockedLessonIds: progress.unlockedLessonIds,
      lastUnlockTimestamp: progress.lastUnlockTimestamp,
      dailyUnlockCount: progress.dailyUnlockCount,
      lastUnlockDate: progress.lastUnlockDate,
      lessonProgress: updatedLessonProgress,
    );
    
    await _firestoreService.updateUserProgress(updatedProgress);
  }
  
  // Get time until next unlock
  Duration? getTimeUntilNextUnlock(UserProgress? progress) {
    if (progress == null) return null;
    
    final now = DateTime.now();
    final lastUnlockDate = progress.lastUnlockDate;
    
    if (lastUnlockDate == null) return null;
    
    // If it's a new day, unlock is available
    if (!_isSameDay(lastUnlockDate, now)) {
      return Duration.zero;
    }
    
    // If daily limit not reached, no waiting needed
    if (progress.dailyUnlockCount < 2) {
      // Check 24-hour rule for first unlock
      if (progress.lastUnlockTimestamp != null) {
        final nextUnlockTime = progress.lastUnlockTimestamp!.add(const Duration(hours: 24));
        if (now.isBefore(nextUnlockTime)) {
          return nextUnlockTime.difference(now);
        }
      }
      return Duration.zero;
    }
    
    // Daily limit reached, wait until next day
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }
  
  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  
  // Calculate overall subject progress
  double calculateSubjectProgress(UserProgress? progress, int totalLessons) {
    if (progress == null || totalLessons == 0) return 0.0;
    return (progress.unlockedLessonIds.length / totalLessons) * 100;
  }
}
