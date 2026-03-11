import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../services/progress_service.dart';

class CurriculumProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final ProgressService _progressService;

  List<Year> _years = [];
  List<Subject> _subjects = [];
  List<Lesson> _lessons = [];
  // Store all lessons across all subjects for search
  final Map<String, List<Lesson>> _subjectLessonsMap = {};
  Map<String, UserProgress> _progressMap = {};
  bool _isLoading = false;
  String? _error;

  CurriculumProvider({
    required FirestoreService firestoreService,
    required ProgressService progressService,
  })  : _firestoreService = firestoreService,
        _progressService = progressService;

  List<Year> get years => _years;
  List<Subject> get subjects => _subjects;
  List<Lesson> get lessons => _lessons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// All lessons across all loaded subjects (for search)
  List<Lesson> get allLessons {
    final all = <Lesson>[];
    for (final lessons in _subjectLessonsMap.values) {
      all.addAll(lessons);
    }
    return all;
  }

  Future<void> loadYears() async {
    _isLoading = true;
    notifyListeners();

    try {
      _years = await _firestoreService.getActiveYears();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSubjects(String yearId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _subjects = await _firestoreService.getSubjectsByYear(yearId);
      _error = null;

      // Pre-load lessons for all subjects (for search)
      for (final subject in _subjects) {
        if (!_subjectLessonsMap.containsKey(subject.id)) {
          try {
            final sLessons =
                await _firestoreService.getLessonsBySubject(subject.id);
            _subjectLessonsMap[subject.id] = sLessons;
          } catch (_) {}
        }
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadLessons(String subjectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _lessons = await _firestoreService.getLessonsBySubject(subjectId);
      _subjectLessonsMap[subjectId] = _lessons;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProgress(String userId, String subjectId) async {
    try {
      final progress =
          await _firestoreService.getUserProgress(userId, subjectId);
      if (progress != null) {
        _progressMap[subjectId] = progress;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  UserProgress? getProgress(String subjectId) {
    return _progressMap[subjectId];
  }

  bool isLessonUnlocked(String subjectId, String lessonId) {
    final progress = _progressMap[subjectId];
    if (progress == null) return false;
    return progress.unlockedLessonIds.contains(lessonId);
  }

  Future<bool> tryUnlockLesson(
      String userId, String subjectId, String lessonId) async {
    try {
      final shouldUnlock = await _progressService.shouldUnlockLesson(
        userId,
        subjectId,
        lessonId,
      );

      if (shouldUnlock) {
        await _progressService.unlockLesson(userId, subjectId, lessonId);
        await loadProgress(userId, subjectId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> updateLessonProgress(
    String userId,
    String subjectId,
    String lessonId,
    int totalExercises,
    Map<String, bool> exerciseResults,
  ) async {
    try {
      await _progressService.updateLessonProgress(
        userId,
        subjectId,
        lessonId,
        totalExercises,
        exerciseResults,
      );
      await loadProgress(userId, subjectId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Duration? getTimeUntilNextUnlock(String subjectId) {
    final progress = _progressMap[subjectId];
    return _progressService.getTimeUntilNextUnlock(progress);
  }

  double getSubjectProgress(String subjectId) {
    final progress = _progressMap[subjectId];
    final subjectLessons = _subjectLessonsMap[subjectId] ?? _lessons.where((l) => l.subjectId == subjectId).toList();
    final totalLessons = subjectLessons.length;
    return _progressService.calculateSubjectProgress(progress, totalLessons);
  }

  /// Returns number of lessons loaded for a subject
  int getLessonsCountForSubject(String subjectId) {
    return _subjectLessonsMap[subjectId]?.length ?? 0;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
