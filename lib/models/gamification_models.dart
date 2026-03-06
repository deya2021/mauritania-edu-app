import 'package:cloud_firestore/cloud_firestore.dart';

/// Achievement types for badges
enum AchievementType {
  firstLesson,           // أول درس
  firstExercise,         // أول تمرين
  perfectScore,          // درجة كاملة
  weekStreak,            // أسبوع متواصل
  monthStreak,           // شهر متواصل
  fastLearner,           // متعلم سريع
  dedicated,             // مجتهد
  explorer,              // مستكشف
  master,                // متقن
  champion,              // بطل
}

/// Badge/Achievement model
class Badge {
  final String id;
  final AchievementType type;
  final String nameAr;
  final String nameFr;
  final String descriptionAr;
  final String descriptionFr;
  final String iconName;
  final int requiredPoints;
  final DateTime? earnedAt;
  
  Badge({
    required this.id,
    required this.type,
    required this.nameAr,
    required this.nameFr,
    required this.descriptionAr,
    required this.descriptionFr,
    required this.iconName,
    required this.requiredPoints,
    this.earnedAt,
  });
  
  bool get isEarned => earnedAt != null;
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'name_ar': nameAr,
      'name_fr': nameFr,
      'description_ar': descriptionAr,
      'description_fr': descriptionFr,
      'icon_name': iconName,
      'required_points': requiredPoints,
      'earned_at': earnedAt?.toIso8601String(),
    };
  }
  
  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      id: map['id'] ?? '',
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => AchievementType.firstLesson,
      ),
      nameAr: map['name_ar'] ?? '',
      nameFr: map['name_fr'] ?? '',
      descriptionAr: map['description_ar'] ?? '',
      descriptionFr: map['description_fr'] ?? '',
      iconName: map['icon_name'] ?? 'star',
      requiredPoints: map['required_points'] ?? 0,
      earnedAt: map['earned_at'] != null 
        ? DateTime.parse(map['earned_at']) 
        : null,
    );
  }
}

/// User points and gamification data
class UserGamification {
  final String userId;
  final int totalPoints;
  final int currentLevel;
  final int lessonsCompleted;
  final int exercisesCompleted;
  final int perfectScores;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActivityDate;
  final List<String> earnedBadges;
  final Map<String, int> subjectPoints;  // Points per subject
  
  UserGamification({
    required this.userId,
    this.totalPoints = 0,
    this.currentLevel = 1,
    this.lessonsCompleted = 0,
    this.exercisesCompleted = 0,
    this.perfectScores = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastActivityDate,
    this.earnedBadges = const [],
    this.subjectPoints = const {},
  });
  
  // Calculate level from total points
  static int calculateLevel(int points) {
    // Every 100 points = 1 level
    return (points ~/ 100) + 1;
  }
  
  // Points needed for next level
  int get pointsToNextLevel {
    int nextLevel = currentLevel + 1;
    int pointsNeeded = (nextLevel - 1) * 100;
    return pointsNeeded - totalPoints;
  }
  
  // Progress to next level (0.0 to 1.0)
  double get levelProgress {
    int currentLevelPoints = (currentLevel - 1) * 100;
    int nextLevelPoints = currentLevel * 100;
    int progressPoints = totalPoints - currentLevelPoints;
    int levelRange = nextLevelPoints - currentLevelPoints;
    return progressPoints / levelRange;
  }
  
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'total_points': totalPoints,
      'current_level': currentLevel,
      'lessons_completed': lessonsCompleted,
      'exercises_completed': exercisesCompleted,
      'perfect_scores': perfectScores,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_activity_date': Timestamp.fromDate(lastActivityDate),
      'earned_badges': earnedBadges,
      'subject_points': subjectPoints,
    };
  }
  
  factory UserGamification.fromMap(Map<String, dynamic> map) {
    return UserGamification(
      userId: map['user_id'] ?? '',
      totalPoints: map['total_points'] ?? 0,
      currentLevel: map['current_level'] ?? 1,
      lessonsCompleted: map['lessons_completed'] ?? 0,
      exercisesCompleted: map['exercises_completed'] ?? 0,
      perfectScores: map['perfect_scores'] ?? 0,
      currentStreak: map['current_streak'] ?? 0,
      longestStreak: map['longest_streak'] ?? 0,
      lastActivityDate: (map['last_activity_date'] as Timestamp?)?.toDate() 
        ?? DateTime.now(),
      earnedBadges: List<String>.from(map['earned_badges'] ?? []),
      subjectPoints: Map<String, int>.from(map['subject_points'] ?? {}),
    );
  }
}

/// Predefined badges
class PredefinedBadges {
  static List<Badge> getAllBadges() {
    return [
      Badge(
        id: 'first_lesson',
        type: AchievementType.firstLesson,
        nameAr: 'أول درس',
        nameFr: 'Première leçon',
        descriptionAr: 'أكملت أول درس لك',
        descriptionFr: 'Complété votre première leçon',
        iconName: 'school',
        requiredPoints: 0,
      ),
      Badge(
        id: 'first_exercise',
        type: AchievementType.firstExercise,
        nameAr: 'أول تمرين',
        nameFr: 'Premier exercice',
        descriptionAr: 'أكملت أول تمرين لك',
        descriptionFr: 'Complété votre premier exercice',
        iconName: 'edit',
        requiredPoints: 0,
      ),
      Badge(
        id: 'perfect_score',
        type: AchievementType.perfectScore,
        nameAr: 'درجة كاملة',
        nameFr: 'Score parfait',
        descriptionAr: 'حصلت على 100% في تمرين',
        descriptionFr: 'Obtenu 100% dans un exercice',
        iconName: 'stars',
        requiredPoints: 0,
      ),
      Badge(
        id: 'week_streak',
        type: AchievementType.weekStreak,
        nameAr: 'أسبوع متواصل',
        nameFr: 'Semaine continue',
        descriptionAr: 'تعلمت لمدة 7 أيام متتالية',
        descriptionFr: 'Appris pendant 7 jours consécutifs',
        iconName: 'local_fire_department',
        requiredPoints: 50,
      ),
      Badge(
        id: 'month_streak',
        type: AchievementType.monthStreak,
        nameAr: 'شهر متواصل',
        nameFr: 'Mois continu',
        descriptionAr: 'تعلمت لمدة 30 يوماً متتالياً',
        descriptionFr: 'Appris pendant 30 jours consécutifs',
        iconName: 'whatshot',
        requiredPoints: 200,
      ),
      Badge(
        id: 'fast_learner',
        type: AchievementType.fastLearner,
        nameAr: 'متعلم سريع',
        nameFr: 'Apprenant rapide',
        descriptionAr: 'أكملت 10 دروس',
        descriptionFr: 'Complété 10 leçons',
        iconName: 'flash_on',
        requiredPoints: 100,
      ),
      Badge(
        id: 'dedicated',
        type: AchievementType.dedicated,
        nameAr: 'مجتهد',
        nameFr: 'Dévoué',
        descriptionAr: 'أكملت 50 تمريناً',
        descriptionFr: 'Complété 50 exercices',
        iconName: 'workspace_premium',
        requiredPoints: 250,
      ),
      Badge(
        id: 'explorer',
        type: AchievementType.explorer,
        nameAr: 'مستكشف',
        nameFr: 'Explorateur',
        descriptionAr: 'درست في 3 مواد مختلفة',
        descriptionFr: 'Étudié dans 3 matières différentes',
        iconName: 'explore',
        requiredPoints: 150,
      ),
      Badge(
        id: 'master',
        type: AchievementType.master,
        nameAr: 'متقن',
        nameFr: 'Maître',
        descriptionAr: 'وصلت إلى المستوى 10',
        descriptionFr: 'Atteint le niveau 10',
        iconName: 'military_tech',
        requiredPoints: 1000,
      ),
      Badge(
        id: 'champion',
        type: AchievementType.champion,
        nameAr: 'بطل',
        nameFr: 'Champion',
        descriptionAr: 'حصلت على جميع الشارات',
        descriptionFr: 'Obtenu tous les badges',
        iconName: 'emoji_events',
        requiredPoints: 2000,
      ),
    ];
  }
}

/// Points reward for different actions
class PointsRewards {
  static const int lessonOpened = 5;
  static const int lessonCompleted = 10;
  static const int exerciseCompleted = 5;
  static const int perfectScore = 20;
  static const int dailyLogin = 2;
  static const int weeklyStreak = 50;
  static const int monthlyStreak = 200;
}
