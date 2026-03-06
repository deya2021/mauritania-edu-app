import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gamification_models.dart';

/// Service for managing gamification (points, badges, levels)
class GamificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection names
  static const String _userGamificationCollection = 'user_gamification';
  static const String _badgesCollection = 'badges';
  static const String _leaderboardCollection = 'leaderboard';
  
  /// Initialize user gamification data
  Future<void> initializeUserGamification(String userId) async {
    try {
      final doc = await _firestore
        .collection(_userGamificationCollection)
        .doc(userId)
        .get();
      
      if (!doc.exists) {
        final userGamification = UserGamification(
          userId: userId,
          lastActivityDate: DateTime.now(),
        );
        
        await _firestore
          .collection(_userGamificationCollection)
          .doc(userId)
          .set(userGamification.toMap());
        
        print('✅ Initialized gamification for user: $userId');
      }
    } catch (e) {
      print('❌ Error initializing gamification: $e');
    }
  }
  
  /// Get user gamification data
  Future<UserGamification?> getUserGamification(String userId) async {
    try {
      final doc = await _firestore
        .collection(_userGamificationCollection)
        .doc(userId)
        .get();
      
      if (doc.exists) {
        return UserGamification.fromMap(doc.data()!);
      }
    } catch (e) {
      print('❌ Error getting gamification: $e');
    }
    return null;
  }
  
  /// Award points to user
  Future<void> awardPoints({
    required String userId,
    required int points,
    required String reason,
    String? subjectId,
  }) async {
    try {
      final docRef = _firestore
        .collection(_userGamificationCollection)
        .doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) {
          await initializeUserGamification(userId);
          return;
        }
        
        final currentData = UserGamification.fromMap(snapshot.data()!);
        final newTotalPoints = currentData.totalPoints + points;
        final newLevel = UserGamification.calculateLevel(newTotalPoints);
        
        // Update subject points if specified
        Map<String, int> updatedSubjectPoints = 
          Map<String, int>.from(currentData.subjectPoints);
        if (subjectId != null) {
          updatedSubjectPoints[subjectId] = 
            (updatedSubjectPoints[subjectId] ?? 0) + points;
        }
        
        transaction.update(docRef, {
          'total_points': newTotalPoints,
          'current_level': newLevel,
          'subject_points': updatedSubjectPoints,
          'last_activity_date': Timestamp.now(),
        });
        
        print('✅ Awarded $points points to $userId for: $reason');
        
        // Check for new badges
        await _checkAndAwardBadges(userId);
      });
    } catch (e) {
      print('❌ Error awarding points: $e');
    }
  }
  
  /// Record lesson completion
  Future<void> recordLessonCompletion({
    required String userId,
    required String lessonId,
    required String subjectId,
  }) async {
    try {
      final docRef = _firestore
        .collection(_userGamificationCollection)
        .doc(userId);
      
      await docRef.update({
        'lessons_completed': FieldValue.increment(1),
        'last_activity_date': Timestamp.now(),
      });
      
      await awardPoints(
        userId: userId,
        points: PointsRewards.lessonCompleted,
        reason: 'Lesson completed: $lessonId',
        subjectId: subjectId,
      );
      
      await updateStreak(userId);
    } catch (e) {
      print('❌ Error recording lesson completion: $e');
    }
  }
  
  /// Record exercise completion
  Future<void> recordExerciseCompletion({
    required String userId,
    required String exerciseId,
    required String subjectId,
    required int score,
    required int totalQuestions,
  }) async {
    try {
      final docRef = _firestore
        .collection(_userGamificationCollection)
        .doc(userId);
      
      await docRef.update({
        'exercises_completed': FieldValue.increment(1),
        'last_activity_date': Timestamp.now(),
      });
      
      // Base points for completion
      int pointsEarned = PointsRewards.exerciseCompleted;
      
      // Bonus for perfect score
      if (score == totalQuestions) {
        pointsEarned += PointsRewards.perfectScore;
        await docRef.update({
          'perfect_scores': FieldValue.increment(1),
        });
      }
      
      await awardPoints(
        userId: userId,
        points: pointsEarned,
        reason: 'Exercise completed: $exerciseId (score: $score/$totalQuestions)',
        subjectId: subjectId,
      );
      
      await updateStreak(userId);
    } catch (e) {
      print('❌ Error recording exercise completion: $e');
    }
  }
  
  /// Update user's learning streak
  Future<void> updateStreak(String userId) async {
    try {
      final userGamification = await getUserGamification(userId);
      if (userGamification == null) return;
      
      final now = DateTime.now();
      final lastActivity = userGamification.lastActivityDate;
      final daysDifference = now.difference(lastActivity).inDays;
      
      int newStreak = userGamification.currentStreak;
      
      if (daysDifference == 0) {
        // Same day, no change
        return;
      } else if (daysDifference == 1) {
        // Consecutive day, increment streak
        newStreak++;
      } else {
        // Streak broken, reset
        newStreak = 1;
      }
      
      int newLongestStreak = userGamification.longestStreak;
      if (newStreak > newLongestStreak) {
        newLongestStreak = newStreak;
      }
      
      await _firestore
        .collection(_userGamificationCollection)
        .doc(userId)
        .update({
          'current_streak': newStreak,
          'longest_streak': newLongestStreak,
        });
      
      // Award streak bonuses
      if (newStreak == 7) {
        await awardPoints(
          userId: userId,
          points: PointsRewards.weeklyStreak,
          reason: '7-day streak bonus',
        );
      } else if (newStreak == 30) {
        await awardPoints(
          userId: userId,
          points: PointsRewards.monthlyStreak,
          reason: '30-day streak bonus',
        );
      }
      
      print('✅ Updated streak for $userId: $newStreak days');
    } catch (e) {
      print('❌ Error updating streak: $e');
    }
  }
  
  /// Check and award badges based on achievements
  Future<void> _checkAndAwardBadges(String userId) async {
    try {
      final userGamification = await getUserGamification(userId);
      if (userGamification == null) return;
      
      final allBadges = PredefinedBadges.getAllBadges();
      final earnedBadgeIds = userGamification.earnedBadges;
      
      for (var badge in allBadges) {
        // Skip if already earned
        if (earnedBadgeIds.contains(badge.id)) continue;
        
        // Check if user meets criteria
        bool shouldAward = false;
        
        switch (badge.type) {
          case AchievementType.firstLesson:
            shouldAward = userGamification.lessonsCompleted >= 1;
            break;
          case AchievementType.firstExercise:
            shouldAward = userGamification.exercisesCompleted >= 1;
            break;
          case AchievementType.perfectScore:
            shouldAward = userGamification.perfectScores >= 1;
            break;
          case AchievementType.weekStreak:
            shouldAward = userGamification.currentStreak >= 7;
            break;
          case AchievementType.monthStreak:
            shouldAward = userGamification.currentStreak >= 30;
            break;
          case AchievementType.fastLearner:
            shouldAward = userGamification.lessonsCompleted >= 10;
            break;
          case AchievementType.dedicated:
            shouldAward = userGamification.exercisesCompleted >= 50;
            break;
          case AchievementType.explorer:
            shouldAward = userGamification.subjectPoints.length >= 3;
            break;
          case AchievementType.master:
            shouldAward = userGamification.currentLevel >= 10;
            break;
          case AchievementType.champion:
            shouldAward = earnedBadgeIds.length >= 8; // All except champion
            break;
        }
        
        if (shouldAward) {
          await _awardBadge(userId, badge.id);
        }
      }
    } catch (e) {
      print('❌ Error checking badges: $e');
    }
  }
  
  /// Award a badge to user
  Future<void> _awardBadge(String userId, String badgeId) async {
    try {
      await _firestore
        .collection(_userGamificationCollection)
        .doc(userId)
        .update({
          'earned_badges': FieldValue.arrayUnion([badgeId]),
        });
      
      print('🏆 Badge awarded to $userId: $badgeId');
      
      // You can trigger a notification here
      // await notificationService.showBadgeEarnedNotification(badgeId);
    } catch (e) {
      print('❌ Error awarding badge: $e');
    }
  }
  
  /// Get all badges for user (with earned status)
  Future<List<Badge>> getUserBadges(String userId) async {
    try {
      final userGamification = await getUserGamification(userId);
      final allBadges = PredefinedBadges.getAllBadges();
      
      if (userGamification == null) return allBadges;
      
      return allBadges.map((badge) {
        final isEarned = userGamification.earnedBadges.contains(badge.id);
        return Badge(
          id: badge.id,
          type: badge.type,
          nameAr: badge.nameAr,
          nameFr: badge.nameFr,
          descriptionAr: badge.descriptionAr,
          descriptionFr: badge.descriptionFr,
          iconName: badge.iconName,
          requiredPoints: badge.requiredPoints,
          earnedAt: isEarned ? DateTime.now() : null, // TODO: Store actual earned date
        );
      }).toList();
    } catch (e) {
      print('❌ Error getting user badges: $e');
      return PredefinedBadges.getAllBadges();
    }
  }
  
  /// Get leaderboard (top users by points)
  Future<List<UserGamification>> getLeaderboard({
    int limit = 10,
    String? yearId,
  }) async {
    try {
      Query query = _firestore
        .collection(_userGamificationCollection)
        .orderBy('total_points', descending: true)
        .limit(limit);
      
      final snapshot = await query.get();
      
      return snapshot.docs
        .map((doc) => UserGamification.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    } catch (e) {
      print('❌ Error getting leaderboard: $e');
      return [];
    }
  }
  
  /// Get user's rank in leaderboard
  Future<int> getUserRank(String userId) async {
    try {
      final userGamification = await getUserGamification(userId);
      if (userGamification == null) return 0;
      
      final snapshot = await _firestore
        .collection(_userGamificationCollection)
        .where('total_points', isGreaterThan: userGamification.totalPoints)
        .get();
      
      return snapshot.docs.length + 1;
    } catch (e) {
      print('❌ Error getting user rank: $e');
      return 0;
    }
  }
}
