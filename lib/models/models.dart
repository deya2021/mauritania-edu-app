class User {
  final String id;
  final String phoneNumber;
  final String? selectedYearId;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  
  User({
    required this.id,
    required this.phoneNumber,
    this.selectedYearId,
    required this.createdAt,
    this.lastLoginAt,
  });
  
  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      phoneNumber: map['phoneNumber'] ?? '',
      selectedYearId: map['selectedYearId'],
      createdAt: (map['createdAt'] as dynamic).toDate(),
      lastLoginAt: map['lastLoginAt'] != null 
          ? (map['lastLoginAt'] as dynamic).toDate() 
          : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'selectedYearId': selectedYearId,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
    };
  }
}

class Year {
  final String id;
  final Map<String, String> name; // {'ar': 'السنة الأولى', 'fr': 'Première année'}
  final int order;
  final bool isActive;
  
  Year({
    required this.id,
    required this.name,
    required this.order,
    this.isActive = true,
  });
  
  factory Year.fromMap(Map<String, dynamic> map, String id) {
    return Year(
      id: id,
      name: Map<String, String>.from(map['name'] ?? {}),
      order: map['order'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'order': order,
      'isActive': isActive,
    };
  }
  
  String getLocalizedName(String locale) {
    return name[locale] ?? name['fr'] ?? name['ar'] ?? 'Unknown';
  }
}

class Subject {
  final String id;
  final String yearId;
  final Map<String, String> name;
  final String iconUrl;
  final String color;
  final int order;
  
  Subject({
    required this.id,
    required this.yearId,
    required this.name,
    required this.iconUrl,
    required this.color,
    required this.order,
  });
  
  factory Subject.fromMap(Map<String, dynamic> map, String id) {
    return Subject(
      id: id,
      yearId: map['yearId'] ?? '',
      name: Map<String, String>.from(map['name'] ?? {}),
      iconUrl: map['iconUrl'] ?? '',
      color: map['color'] ?? '#2196F3',
      order: map['order'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'yearId': yearId,
      'name': name,
      'iconUrl': iconUrl,
      'color': color,
      'order': order,
    };
  }
  
  String getLocalizedName(String locale) {
    return name[locale] ?? name['fr'] ?? name['ar'] ?? 'Unknown';
  }
}

class Unit {
  final String id;
  final String subjectId;
  final Map<String, String> name;
  final int order;
  
  Unit({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.order,
  });
  
  factory Unit.fromMap(Map<String, dynamic> map, String id) {
    return Unit(
      id: id,
      subjectId: map['subjectId'] ?? '',
      name: Map<String, String>.from(map['name'] ?? {}),
      order: map['order'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'name': name,
      'order': order,
    };
  }
  
  String getLocalizedName(String locale) {
    return name[locale] ?? name['fr'] ?? name['ar'] ?? 'Unknown';
  }
}

class Lesson {
  final String id;
  final String unitId;
  final String subjectId;
  final Map<String, String> title;
  final Map<String, String> summary;
  final String contentLanguage; // 'ar' or 'fr'
  final int order;
  
  Lesson({
    required this.id,
    required this.unitId,
    required this.subjectId,
    required this.title,
    required this.summary,
    required this.contentLanguage,
    required this.order,
  });
  
  factory Lesson.fromMap(Map<String, dynamic> map, String id) {
    return Lesson(
      id: id,
      unitId: map['unitId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      title: Map<String, String>.from(map['title'] ?? {}),
      summary: Map<String, String>.from(map['summary'] ?? {}),
      contentLanguage: map['contentLanguage'] ?? 'fr',
      order: map['order'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'unitId': unitId,
      'subjectId': subjectId,
      'title': title,
      'summary': summary,
      'contentLanguage': contentLanguage,
      'order': order,
    };
  }
  
  String getLocalizedTitle(String locale) {
    return title[locale] ?? title['fr'] ?? title['ar'] ?? 'Unknown';
  }
  
  String getLocalizedSummary(String locale) {
    return summary[locale] ?? summary['fr'] ?? summary['ar'] ?? '';
  }
}

class LessonContent {
  final String id;
  final String lessonId;
  final List<ContentSection> sections;
  final List<Exercise> exercises;
  
  LessonContent({
    required this.id,
    required this.lessonId,
    required this.sections,
    required this.exercises,
  });
  
  factory LessonContent.fromMap(Map<String, dynamic> map, String id) {
    return LessonContent(
      id: id,
      lessonId: map['lessonId'] ?? '',
      sections: (map['sections'] as List? ?? [])
          .map((s) => ContentSection.fromMap(s))
          .toList(),
      exercises: (map['exercises'] as List? ?? [])
          .map((e) => Exercise.fromMap(e))
          .toList(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'sections': sections.map((s) => s.toMap()).toList(),
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }
}

class ContentSection {
  final String title;
  final String content; // Markdown format
  final bool lockedInitially;
  final int order;
  
  ContentSection({
    required this.title,
    required this.content,
    this.lockedInitially = false,
    required this.order,
  });
  
  factory ContentSection.fromMap(Map<String, dynamic> map) {
    return ContentSection(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      lockedInitially: map['lockedInitially'] ?? false,
      order: map['order'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'lockedInitially': lockedInitially,
      'order': order,
    };
  }
}

class Exercise {
  final String id;
  final String type; // 'mcq' or 'true_false'
  final String question;
  final List<String>? options; // For MCQ
  final String correctAnswer; // Index for MCQ, 'true'/'false' for T/F
  final String? explanation;
  
  Exercise({
    required this.id,
    required this.type,
    required this.question,
    this.options,
    required this.correctAnswer,
    this.explanation,
  });
  
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? '',
      type: map['type'] ?? 'mcq',
      question: map['question'] ?? '',
      options: map['options'] != null 
          ? List<String>.from(map['options']) 
          : null,
      correctAnswer: map['correctAnswer']?.toString() ?? '',
      explanation: map['explanation'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}

class UserProgress {
  final String userId;
  final String subjectId;
  final List<String> unlockedLessonIds;
  final DateTime? lastUnlockTimestamp;
  final int dailyUnlockCount;
  final DateTime? lastUnlockDate;
  final Map<String, LessonProgress> lessonProgress;
  
  UserProgress({
    required this.userId,
    required this.subjectId,
    this.unlockedLessonIds = const [],
    this.lastUnlockTimestamp,
    this.dailyUnlockCount = 0,
    this.lastUnlockDate,
    this.lessonProgress = const {},
  });
  
  factory UserProgress.fromMap(Map<String, dynamic> map) {
    final lessonProgressMap = <String, LessonProgress>{};
    if (map['lessonProgress'] != null) {
      (map['lessonProgress'] as Map).forEach((key, value) {
        lessonProgressMap[key] = LessonProgress.fromMap(value);
      });
    }
    
    return UserProgress(
      userId: map['userId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      unlockedLessonIds: List<String>.from(map['unlockedLessonIds'] ?? []),
      lastUnlockTimestamp: map['lastUnlockTimestamp'] != null
          ? (map['lastUnlockTimestamp'] as dynamic).toDate()
          : null,
      dailyUnlockCount: map['dailyUnlockCount'] ?? 0,
      lastUnlockDate: map['lastUnlockDate'] != null
          ? (map['lastUnlockDate'] as dynamic).toDate()
          : null,
      lessonProgress: lessonProgressMap,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'subjectId': subjectId,
      'unlockedLessonIds': unlockedLessonIds,
      'lastUnlockTimestamp': lastUnlockTimestamp,
      'dailyUnlockCount': dailyUnlockCount,
      'lastUnlockDate': lastUnlockDate,
      'lessonProgress': lessonProgress.map((key, value) => MapEntry(key, value.toMap())),
    };
  }
}

class LessonProgress {
  final String lessonId;
  final int totalExercises;
  final int completedExercises;
  final Map<String, bool> exerciseResults; // exerciseId -> isCorrect
  final DateTime? lastAccessedAt;
  
  LessonProgress({
    required this.lessonId,
    required this.totalExercises,
    this.completedExercises = 0,
    this.exerciseResults = const {},
    this.lastAccessedAt,
  });
  
  double get completionPercentage {
    if (totalExercises == 0) return 0;
    return (completedExercises / totalExercises) * 100;
  }
  
  factory LessonProgress.fromMap(Map<String, dynamic> map) {
    return LessonProgress(
      lessonId: map['lessonId'] ?? '',
      totalExercises: map['totalExercises'] ?? 0,
      completedExercises: map['completedExercises'] ?? 0,
      exerciseResults: Map<String, bool>.from(map['exerciseResults'] ?? {}),
      lastAccessedAt: map['lastAccessedAt'] != null
          ? (map['lastAccessedAt'] as dynamic).toDate()
          : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'totalExercises': totalExercises,
      'completedExercises': completedExercises,
      'exerciseResults': exerciseResults,
      'lastAccessedAt': lastAccessedAt,
    };
  }
}

class AdSlot {
  final String id;
  final String slotName; // 'home_top', 'home_bottom', 'lesson_top', 'lesson_bottom'
  final String imageUrl;
  final String targetUrl;
  final bool enabled;
  final DateTime? startDate;
  final DateTime? endDate;
  final int order;
  
  AdSlot({
    required this.id,
    required this.slotName,
    required this.imageUrl,
    required this.targetUrl,
    this.enabled = true,
    this.startDate,
    this.endDate,
    this.order = 0,
  });
  
  bool get isActive {
    if (!enabled) return false;
    
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    
    return true;
  }
  
  factory AdSlot.fromMap(Map<String, dynamic> map, String id) {
    return AdSlot(
      id: id,
      slotName: map['slotName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      targetUrl: map['targetUrl'] ?? '',
      enabled: map['enabled'] ?? true,
      startDate: map['startDate'] != null
          ? (map['startDate'] as dynamic).toDate()
          : null,
      endDate: map['endDate'] != null
          ? (map['endDate'] as dynamic).toDate()
          : null,
      order: map['order'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'slotName': slotName,
      'imageUrl': imageUrl,
      'targetUrl': targetUrl,
      'enabled': enabled,
      'startDate': startDate,
      'endDate': endDate,
      'order': order,
    };
  }
}
