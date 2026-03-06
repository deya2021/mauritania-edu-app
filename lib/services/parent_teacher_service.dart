import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parent_teacher_models.dart';

/// Service for managing parent/teacher accounts and student monitoring
class ParentTeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection names
  static const String _parentTeacherCollection = 'parent_teacher_accounts';
  static const String _linkRequestsCollection = 'link_requests';
  static const String _activityLogsCollection = 'activity_logs';
  static const String _studentsCollection = 'users';
  
  /// Create parent/teacher account
  Future<void> createParentTeacherAccount({
    required String userId,
    required UserRole role,
    required String name,
    required String phoneNumber,
    String email = '',
  }) async {
    try {
      final account = ParentTeacherAccount(
        userId: userId,
        role: role,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );
      
      await _firestore
        .collection(_parentTeacherCollection)
        .doc(userId)
        .set(account.toMap());
      
      print('✅ Created ${role.toString()} account for: $userId');
    } catch (e) {
      print('❌ Error creating parent/teacher account: $e');
      rethrow;
    }
  }
  
  /// Get parent/teacher account
  Future<ParentTeacherAccount?> getAccount(String userId) async {
    try {
      final doc = await _firestore
        .collection(_parentTeacherCollection)
        .doc(userId)
        .get();
      
      if (doc.exists) {
        return ParentTeacherAccount.fromMap(doc.data()!);
      }
    } catch (e) {
      print('❌ Error getting account: $e');
    }
    return null;
  }
  
  /// Send link request to student
  Future<String?> sendLinkRequest({
    required String parentUserId,
    required String parentName,
    required String studentPhoneNumber,
  }) async {
    try {
      // Find student by phone number
      final studentQuery = await _firestore
        .collection(_studentsCollection)
        .where('phone_number', isEqualTo: studentPhoneNumber)
        .limit(1)
        .get();
      
      if (studentQuery.docs.isEmpty) {
        print('❌ Student not found with phone: $studentPhoneNumber');
        return null;
      }
      
      final studentUserId = studentQuery.docs.first.id;
      
      // Check if already linked
      final parentAccount = await getAccount(parentUserId);
      if (parentAccount != null && 
          parentAccount.linkedStudentIds.contains(studentUserId)) {
        print('⚠️ Student already linked');
        return null;
      }
      
      // Check for existing pending request
      final existingRequest = await _firestore
        .collection(_linkRequestsCollection)
        .where('parent_user_id', isEqualTo: parentUserId)
        .where('student_user_id', isEqualTo: studentUserId)
        .where('status', isEqualTo: LinkRequestStatus.pending.toString())
        .get();
      
      if (existingRequest.docs.isNotEmpty) {
        print('⚠️ Link request already pending');
        return existingRequest.docs.first.id;
      }
      
      // Create new link request
      final requestId = _firestore.collection(_linkRequestsCollection).doc().id;
      final linkRequest = LinkRequest(
        id: requestId,
        parentUserId: parentUserId,
        studentPhoneNumber: studentPhoneNumber,
        studentUserId: studentUserId,
        parentName: parentName,
        status: LinkRequestStatus.pending,
        createdAt: DateTime.now(),
      );
      
      await _firestore
        .collection(_linkRequestsCollection)
        .doc(requestId)
        .set(linkRequest.toMap());
      
      print('✅ Link request sent: $requestId');
      
      // TODO: Send notification to student
      
      return requestId;
    } catch (e) {
      print('❌ Error sending link request: $e');
      return null;
    }
  }
  
  /// Get pending link requests for student
  Future<List<LinkRequest>> getPendingRequests(String studentUserId) async {
    try {
      final snapshot = await _firestore
        .collection(_linkRequestsCollection)
        .where('student_user_id', isEqualTo: studentUserId)
        .where('status', isEqualTo: LinkRequestStatus.pending.toString())
        .orderBy('created_at', descending: true)
        .get();
      
      return snapshot.docs
        .map((doc) => LinkRequest.fromMap(doc.data()))
        .toList();
    } catch (e) {
      print('❌ Error getting pending requests: $e');
      return [];
    }
  }
  
  /// Accept link request
  Future<bool> acceptLinkRequest(String requestId) async {
    try {
      final requestDoc = await _firestore
        .collection(_linkRequestsCollection)
        .doc(requestId)
        .get();
      
      if (!requestDoc.exists) return false;
      
      final request = LinkRequest.fromMap(requestDoc.data()!);
      
      // Update request status
      await _firestore
        .collection(_linkRequestsCollection)
        .doc(requestId)
        .update({
          'status': LinkRequestStatus.accepted.toString(),
          'responded_at': Timestamp.now(),
        });
      
      // Get student name
      final studentDoc = await _firestore
        .collection(_studentsCollection)
        .doc(request.studentUserId)
        .get();
      
      final studentName = studentDoc.data()?['name'] ?? 'Student';
      
      // Link student to parent account
      await _firestore
        .collection(_parentTeacherCollection)
        .doc(request.parentUserId)
        .update({
          'linked_student_ids': FieldValue.arrayUnion([request.studentUserId]),
          'linked_student_names.${request.studentUserId}': studentName,
        });
      
      print('✅ Link request accepted: $requestId');
      
      // TODO: Send confirmation notification to parent
      
      return true;
    } catch (e) {
      print('❌ Error accepting link request: $e');
      return false;
    }
  }
  
  /// Reject link request
  Future<bool> rejectLinkRequest(String requestId) async {
    try {
      await _firestore
        .collection(_linkRequestsCollection)
        .doc(requestId)
        .update({
          'status': LinkRequestStatus.rejected.toString(),
          'responded_at': Timestamp.now(),
        });
      
      print('✅ Link request rejected: $requestId');
      return true;
    } catch (e) {
      print('❌ Error rejecting link request: $e');
      return false;
    }
  }
  
  /// Get student progress summary
  Future<StudentProgressSummary?> getStudentProgress(String studentUserId) async {
    try {
      // Get user data
      final userDoc = await _firestore
        .collection(_studentsCollection)
        .doc(studentUserId)
        .get();
      
      if (!userDoc.exists) return null;
      
      final userData = userDoc.data()!;
      
      // Get gamification data
      final gamificationDoc = await _firestore
        .collection('user_gamification')
        .doc(studentUserId)
        .get();
      
      final gamificationData = gamificationDoc.exists 
        ? gamificationDoc.data()! 
        : <String, dynamic>{};
      
      // Get progress data
      final progressDoc = await _firestore
        .collection('user_progress')
        .doc(studentUserId)
        .get();
      
      final progressData = progressDoc.exists 
        ? progressDoc.data()! 
        : <String, dynamic>{};
      
      // Calculate subject progress
      final subjectProgress = <String, SubjectProgress>{};
      
      // TODO: Calculate actual subject progress from lessons/exercises
      
      return StudentProgressSummary(
        studentId: studentUserId,
        studentName: userData['name'] ?? 'Student',
        yearId: userData['selected_year_id'] ?? '',
        yearName: userData['year_name'] ?? '',
        totalLessonsCompleted: gamificationData['lessons_completed'] ?? 0,
        totalExercisesCompleted: gamificationData['exercises_completed'] ?? 0,
        totalPoints: gamificationData['total_points'] ?? 0,
        currentLevel: gamificationData['current_level'] ?? 1,
        currentStreak: gamificationData['current_streak'] ?? 0,
        averageScore: 0.0, // TODO: Calculate from exercises
        lastActivityDate: (gamificationData['last_activity_date'] as Timestamp?)?.toDate() 
          ?? DateTime.now(),
        subjectProgress: subjectProgress,
      );
    } catch (e) {
      print('❌ Error getting student progress: $e');
      return null;
    }
  }
  
  /// Get all linked students' progress
  Future<List<StudentProgressSummary>> getLinkedStudentsProgress(
    String parentUserId,
  ) async {
    try {
      final account = await getAccount(parentUserId);
      if (account == null) return [];
      
      final summaries = <StudentProgressSummary>[];
      
      for (var studentId in account.linkedStudentIds) {
        final summary = await getStudentProgress(studentId);
        if (summary != null) {
          summaries.add(summary);
        }
      }
      
      return summaries;
    } catch (e) {
      print('❌ Error getting linked students progress: $e');
      return [];
    }
  }
  
  /// Log student activity
  Future<void> logActivity({
    required String studentId,
    required String activityType,
    required String resourceId,
    required String resourceTitle,
    required String subjectId,
    required String subjectName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final logId = _firestore.collection(_activityLogsCollection).doc().id;
      
      final log = ActivityLog(
        id: logId,
        studentId: studentId,
        activityType: activityType,
        resourceId: resourceId,
        resourceTitle: resourceTitle,
        subjectId: subjectId,
        subjectName: subjectName,
        timestamp: DateTime.now(),
        metadata: metadata,
      );
      
      await _firestore
        .collection(_activityLogsCollection)
        .doc(logId)
        .set(log.toMap());
      
      print('✅ Activity logged: $activityType for $studentId');
    } catch (e) {
      print('❌ Error logging activity: $e');
    }
  }
  
  /// Get student activity logs
  Future<List<ActivityLog>> getStudentActivityLogs({
    required String studentId,
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
        .collection(_activityLogsCollection)
        .where('student_id', isEqualTo: studentId)
        .orderBy('timestamp', descending: true)
        .limit(limit);
      
      if (startDate != null) {
        query = query.where('timestamp', 
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      
      if (endDate != null) {
        query = query.where('timestamp', 
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs
        .map((doc) => ActivityLog.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    } catch (e) {
      print('❌ Error getting activity logs: $e');
      return [];
    }
  }
  
  /// Unlink student from parent account
  Future<bool> unlinkStudent({
    required String parentUserId,
    required String studentUserId,
  }) async {
    try {
      await _firestore
        .collection(_parentTeacherCollection)
        .doc(parentUserId)
        .update({
          'linked_student_ids': FieldValue.arrayRemove([studentUserId]),
          'linked_student_names.$studentUserId': FieldValue.delete(),
        });
      
      print('✅ Student unlinked: $studentUserId from $parentUserId');
      return true;
    } catch (e) {
      print('❌ Error unlinking student: $e');
      return false;
    }
  }
}
