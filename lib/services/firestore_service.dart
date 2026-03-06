import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../config/demo_config.dart';
import 'local_data_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collections
  String get usersCollection => 'users';
  String get yearsCollection => 'years';
  String get subjectsCollection => 'subjects';
  String get unitsCollection => 'units';
  String get lessonsCollection => 'lessons';
  String get lessonContentsCollection => 'lesson_contents';
  String get userProgressCollection => 'user_progress';
  String get adSlotsCollection => 'ad_slots';
  
  // User operations
  Future<void> createOrUpdateUser(User user) async {
    await _firestore.collection(usersCollection).doc(user.id).set(
      user.toMap(),
      SetOptions(merge: true),
    );
  }
  
  Future<User?> getUser(String userId) async {
    final doc = await _firestore.collection(usersCollection).doc(userId).get();
    if (!doc.exists) return null;
    return User.fromMap(doc.data()!, doc.id);
  }
  
  Future<void> updateUserYear(String userId, String yearId) async {
    await _firestore.collection(usersCollection).doc(userId).update({
      'selectedYearId': yearId,
    });
  }
  
  // Year operations
  Future<List<Year>> getActiveYears() async {
    if (DemoConfig.USE_LOCAL_DATA_FALLBACK) {
      try {
        final snapshot = await _firestore
            .collection(yearsCollection)
            .where('isActive', isEqualTo: true)
            .orderBy('order')
            .get();
        
        if (snapshot.docs.isEmpty) {
          return await LocalDataService.getYears();
        }
        return snapshot.docs.map((doc) => Year.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        return await LocalDataService.getYears();
      }
    }
    
    final snapshot = await _firestore
        .collection(yearsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    
    return snapshot.docs.map((doc) => Year.fromMap(doc.data(), doc.id)).toList();
  }
  
  Future<Year?> getYear(String yearId) async {
    final doc = await _firestore.collection(yearsCollection).doc(yearId).get();
    if (!doc.exists) return null;
    return Year.fromMap(doc.data()!, doc.id);
  }
  
  // Subject operations
  Future<List<Subject>> getSubjectsByYear(String yearId) async {
    if (DemoConfig.USE_LOCAL_DATA_FALLBACK) {
      try {
        final snapshot = await _firestore
            .collection(subjectsCollection)
            .where('yearId', isEqualTo: yearId)
            .orderBy('order')
            .get();
        
        if (snapshot.docs.isEmpty) {
          return await LocalDataService.getSubjectsByYear(yearId);
        }
        return snapshot.docs.map((doc) => Subject.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        return await LocalDataService.getSubjectsByYear(yearId);
      }
    }
    
    final snapshot = await _firestore
        .collection(subjectsCollection)
        .where('yearId', isEqualTo: yearId)
        .orderBy('order')
        .get();
    
    return snapshot.docs.map((doc) => Subject.fromMap(doc.data(), doc.id)).toList();
  }
  
  Future<Subject?> getSubject(String subjectId) async {
    final doc = await _firestore.collection(subjectsCollection).doc(subjectId).get();
    if (!doc.exists) return null;
    return Subject.fromMap(doc.data()!, doc.id);
  }
  
  // Unit operations
  Future<List<Unit>> getUnitsBySubject(String subjectId) async {
    final snapshot = await _firestore
        .collection(unitsCollection)
        .where('subjectId', isEqualTo: subjectId)
        .orderBy('order')
        .get();
    
    return snapshot.docs.map((doc) => Unit.fromMap(doc.data(), doc.id)).toList();
  }
  
  // Lesson operations
  Future<List<Lesson>> getLessonsBySubject(String subjectId) async {
    if (DemoConfig.USE_LOCAL_DATA_FALLBACK) {
      try {
        final snapshot = await _firestore
            .collection(lessonsCollection)
            .where('subjectId', isEqualTo: subjectId)
            .orderBy('order')
            .get();
        
        if (snapshot.docs.isEmpty) {
          return await LocalDataService.getLessonsBySubject(subjectId);
        }
        return snapshot.docs.map((doc) => Lesson.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        return await LocalDataService.getLessonsBySubject(subjectId);
      }
    }
    
    final snapshot = await _firestore
        .collection(lessonsCollection)
        .where('subjectId', isEqualTo: subjectId)
        .orderBy('order')
        .get();
    
    return snapshot.docs.map((doc) => Lesson.fromMap(doc.data(), doc.id)).toList();
  }
  
  Future<Lesson?> getLesson(String lessonId) async {
    final doc = await _firestore.collection(lessonsCollection).doc(lessonId).get();
    if (!doc.exists) return null;
    return Lesson.fromMap(doc.data()!, doc.id);
  }
  
  // Lesson content operations
  Future<LessonContent?> getLessonContent(String lessonId) async {
    if (DemoConfig.USE_LOCAL_DATA_FALLBACK) {
      try {
        final snapshot = await _firestore
            .collection(lessonContentsCollection)
            .where('lessonId', isEqualTo: lessonId)
            .limit(1)
            .get();
        
        if (snapshot.docs.isEmpty) {
          return await LocalDataService.getLessonContent(lessonId);
        }
        return LessonContent.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      } catch (e) {
        return await LocalDataService.getLessonContent(lessonId);
      }
    }
    
    final snapshot = await _firestore
        .collection(lessonContentsCollection)
        .where('lessonId', isEqualTo: lessonId)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    return LessonContent.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
  }
  
  // User progress operations
  Future<UserProgress?> getUserProgress(String userId, String subjectId) async {
    final docId = '${userId}_$subjectId';
    final doc = await _firestore.collection(userProgressCollection).doc(docId).get();
    
    if (!doc.exists) return null;
    return UserProgress.fromMap(doc.data()!);
  }
  
  Future<void> updateUserProgress(UserProgress progress) async {
    final docId = '${progress.userId}_${progress.subjectId}';
    await _firestore.collection(userProgressCollection).doc(docId).set(
      progress.toMap(),
      SetOptions(merge: true),
    );
  }
  
  Stream<UserProgress?> watchUserProgress(String userId, String subjectId) {
    final docId = '${userId}_$subjectId';
    return _firestore
        .collection(userProgressCollection)
        .doc(docId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return UserProgress.fromMap(doc.data()!);
        });
  }
  
  // Ad slot operations
  Future<List<AdSlot>> getAdSlots(String slotName) async {
    if (DemoConfig.USE_LOCAL_DATA_FALLBACK) {
      try {
        final snapshot = await _firestore
            .collection(adSlotsCollection)
            .where('slotName', isEqualTo: slotName)
            .where('enabled', isEqualTo: true)
            .orderBy('order')
            .get();
        
        if (snapshot.docs.isEmpty) {
          return await LocalDataService.getAdSlots(slotName);
        }
        return snapshot.docs
            .map((doc) => AdSlot.fromMap(doc.data(), doc.id))
            .where((ad) => ad.isActive)
            .toList();
      } catch (e) {
        return await LocalDataService.getAdSlots(slotName);
      }
    }
    
    final snapshot = await _firestore
        .collection(adSlotsCollection)
        .where('slotName', isEqualTo: slotName)
        .where('enabled', isEqualTo: true)
        .orderBy('order')
        .get();
    
    return snapshot.docs
        .map((doc) => AdSlot.fromMap(doc.data(), doc.id))
        .where((ad) => ad.isActive)
        .toList();
  }
  
  Stream<List<AdSlot>> watchAdSlots(String slotName) {
    return _firestore
        .collection(adSlotsCollection)
        .where('slotName', isEqualTo: slotName)
        .where('enabled', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AdSlot.fromMap(doc.data(), doc.id))
              .where((ad) => ad.isActive)
              .toList();
        });
  }
  
  // Batch operations for seeding data
  Future<void> seedData() async {
    // This method can be used to seed initial data
    // Implementation depends on your data structure
  }
}
