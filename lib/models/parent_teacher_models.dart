import 'package:cloud_firestore/cloud_firestore.dart';

/// User role types
enum UserRole {
  student,    // طالب
  parent,     // ولي أمر
  teacher,    // معلم
}

/// Parent/Teacher account model
class ParentTeacherAccount {
  final String userId;
  final UserRole role;
  final String name;
  final String email;
  final String phoneNumber;
  final List<String> linkedStudentIds;  // IDs of linked students
  final DateTime createdAt;
  final Map<String, String> linkedStudentNames;  // studentId -> name
  
  ParentTeacherAccount({
    required this.userId,
    required this.role,
    required this.name,
    this.email = '',
    required this.phoneNumber,
    this.linkedStudentIds = const [],
    required this.createdAt,
    this.linkedStudentNames = const {},
  });
  
  bool get isParent => role == UserRole.parent;
  bool get isTeacher => role == UserRole.teacher;
  
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'role': role.toString(),
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'linked_student_ids': linkedStudentIds,
      'linked_student_names': linkedStudentNames,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
  
  factory ParentTeacherAccount.fromMap(Map<String, dynamic> map) {
    return ParentTeacherAccount(
      userId: map['user_id'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == map['role'],
        orElse: () => UserRole.parent,
      ),
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      linkedStudentIds: List<String>.from(map['linked_student_ids'] ?? []),
      linkedStudentNames: Map<String, String>.from(map['linked_student_names'] ?? {}),
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Student progress summary for parents/teachers
class StudentProgressSummary {
  final String studentId;
  final String studentName;
  final String yearId;
  final String yearName;
  final int totalLessonsCompleted;
  final int totalExercisesCompleted;
  final int totalPoints;
  final int currentLevel;
  final int currentStreak;
  final double averageScore;  // Average exercise score
  final DateTime lastActivityDate;
  final Map<String, SubjectProgress> subjectProgress;
  
  StudentProgressSummary({
    required this.studentId,
    required this.studentName,
    required this.yearId,
    required this.yearName,
    required this.totalLessonsCompleted,
    required this.totalExercisesCompleted,
    required this.totalPoints,
    required this.currentLevel,
    required this.currentStreak,
    required this.averageScore,
    required this.lastActivityDate,
    required this.subjectProgress,
  });
  
  factory StudentProgressSummary.fromMap(Map<String, dynamic> map) {
    return StudentProgressSummary(
      studentId: map['student_id'] ?? '',
      studentName: map['student_name'] ?? '',
      yearId: map['year_id'] ?? '',
      yearName: map['year_name'] ?? '',
      totalLessonsCompleted: map['total_lessons_completed'] ?? 0,
      totalExercisesCompleted: map['total_exercises_completed'] ?? 0,
      totalPoints: map['total_points'] ?? 0,
      currentLevel: map['current_level'] ?? 1,
      currentStreak: map['current_streak'] ?? 0,
      averageScore: (map['average_score'] ?? 0.0).toDouble(),
      lastActivityDate: (map['last_activity_date'] as Timestamp?)?.toDate() 
        ?? DateTime.now(),
      subjectProgress: (map['subject_progress'] as Map<String, dynamic>?)
        ?.map((key, value) => MapEntry(key, SubjectProgress.fromMap(value)))
        ?? {},
    );
  }
}

/// Progress per subject
class SubjectProgress {
  final String subjectId;
  final String subjectName;
  final int lessonsCompleted;
  final int totalLessons;
  final int exercisesCompleted;
  final double averageScore;
  final DateTime lastAccessDate;
  
  SubjectProgress({
    required this.subjectId,
    required this.subjectName,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.exercisesCompleted,
    required this.averageScore,
    required this.lastAccessDate,
  });
  
  double get completionPercentage {
    if (totalLessons == 0) return 0.0;
    return (lessonsCompleted / totalLessons) * 100;
  }
  
  Map<String, dynamic> toMap() {
    return {
      'subject_id': subjectId,
      'subject_name': subjectName,
      'lessons_completed': lessonsCompleted,
      'total_lessons': totalLessons,
      'exercises_completed': exercisesCompleted,
      'average_score': averageScore,
      'last_access_date': Timestamp.fromDate(lastAccessDate),
    };
  }
  
  factory SubjectProgress.fromMap(Map<String, dynamic> map) {
    return SubjectProgress(
      subjectId: map['subject_id'] ?? '',
      subjectName: map['subject_name'] ?? '',
      lessonsCompleted: map['lessons_completed'] ?? 0,
      totalLessons: map['total_lessons'] ?? 0,
      exercisesCompleted: map['exercises_completed'] ?? 0,
      averageScore: (map['average_score'] ?? 0.0).toDouble(),
      lastAccessDate: (map['last_access_date'] as Timestamp?)?.toDate() 
        ?? DateTime.now(),
    );
  }
}

/// Activity log entry
class ActivityLog {
  final String id;
  final String studentId;
  final String activityType;  // 'lesson_opened', 'lesson_completed', 'exercise_completed'
  final String resourceId;    // lessonId or exerciseId
  final String resourceTitle;
  final String subjectId;
  final String subjectName;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;  // Additional data (score, duration, etc.)
  
  ActivityLog({
    required this.id,
    required this.studentId,
    required this.activityType,
    required this.resourceId,
    required this.resourceTitle,
    required this.subjectId,
    required this.subjectName,
    required this.timestamp,
    this.metadata,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'activity_type': activityType,
      'resource_id': resourceId,
      'resource_title': resourceTitle,
      'subject_id': subjectId,
      'subject_name': subjectName,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }
  
  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      id: map['id'] ?? '',
      studentId: map['student_id'] ?? '',
      activityType: map['activity_type'] ?? '',
      resourceId: map['resource_id'] ?? '',
      resourceTitle: map['resource_title'] ?? '',
      subjectId: map['subject_id'] ?? '',
      subjectName: map['subject_name'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Link request (for parent to link to student)
class LinkRequest {
  final String id;
  final String parentUserId;
  final String studentPhoneNumber;
  final String studentUserId;
  final String parentName;
  final LinkRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  
  LinkRequest({
    required this.id,
    required this.parentUserId,
    required this.studentPhoneNumber,
    required this.studentUserId,
    required this.parentName,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });
  
  bool get isPending => status == LinkRequestStatus.pending;
  bool get isAccepted => status == LinkRequestStatus.accepted;
  bool get isRejected => status == LinkRequestStatus.rejected;
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_user_id': parentUserId,
      'student_phone_number': studentPhoneNumber,
      'student_user_id': studentUserId,
      'parent_name': parentName,
      'status': status.toString(),
      'created_at': Timestamp.fromDate(createdAt),
      'responded_at': respondedAt != null 
        ? Timestamp.fromDate(respondedAt!) 
        : null,
    };
  }
  
  factory LinkRequest.fromMap(Map<String, dynamic> map) {
    return LinkRequest(
      id: map['id'] ?? '',
      parentUserId: map['parent_user_id'] ?? '',
      studentPhoneNumber: map['student_phone_number'] ?? '',
      studentUserId: map['student_user_id'] ?? '',
      parentName: map['parent_name'] ?? '',
      status: LinkRequestStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => LinkRequestStatus.pending,
      ),
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      respondedAt: (map['responded_at'] as Timestamp?)?.toDate(),
    );
  }
}

enum LinkRequestStatus {
  pending,
  accepted,
  rejected,
}
