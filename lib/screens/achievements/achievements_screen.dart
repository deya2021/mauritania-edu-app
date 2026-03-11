import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/curriculum_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<CurriculumProvider>();

    // Calculate stats
    int totalUnlocked = 0;
    int totalCompleted = 0;
    double avgProgress = 0;
    int subjectsWithProgress = 0;

    for (final subject in provider.subjects) {
      final progress = provider.getProgress(subject.id);
      if (progress != null) {
        totalUnlocked += progress.unlockedLessonIds.length;
        final pct = provider.getSubjectProgress(subject.id);
        if (pct > 0) {
          avgProgress += pct;
          subjectsWithProgress++;
        }
        totalCompleted +=
            progress.lessonProgress.values.where((lp) => lp.completionPercentage >= 70).length;
      }
    }
    if (subjectsWithProgress > 0) {
      avgProgress = avgProgress / subjectsWithProgress;
    }

    final List<_Achievement> achievements = _buildAchievements(
      l10n,
      totalUnlocked: totalUnlocked,
      totalCompleted: totalCompleted,
      avgProgress: avgProgress,
      subjectCount: provider.subjects.length,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.achievements),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats overview
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade700,
                    Colors.orange.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        l10n.yourAchievements,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatBadge(
                        value: '$totalUnlocked',
                        label: l10n.unlockedLessons,
                        icon: Icons.lock_open,
                      ),
                      _StatBadge(
                        value: '$totalCompleted',
                        label: l10n.completedLessons,
                        icon: Icons.check_circle,
                      ),
                      _StatBadge(
                        value: '${avgProgress.toStringAsFixed(0)}%',
                        label: l10n.overallProgress,
                        icon: Icons.trending_up,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Achievements grid
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                l10n.badgesAndMedals,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                return _AchievementBadge(achievement: achievements[index]);
              },
            ),

            // Progress per subject
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                l10n.subjectProgress,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            if (provider.subjects.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.noSubjects,
                    style:
                        Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                ),
              )
            else
              ...provider.subjects.map((subject) {
                final progress = provider.getProgress(subject.id);
                final pct = progress != null ? provider.getSubjectProgress(subject.id) : 0.0;
                final color = _parseColor(subject.color);
                final locale = Localizations.localeOf(context).languageCode;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.book, color: color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              subject.getLocalizedName(locale),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct / 100,
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      if (progress != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${progress.unlockedLessonIds.length} ${l10n.unlockedLessons}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  List<_Achievement> _buildAchievements(
    AppLocalizations l10n, {
    required int totalUnlocked,
    required int totalCompleted,
    required double avgProgress,
    required int subjectCount,
  }) {
    return [
      _Achievement(
        icon: Icons.star,
        label: l10n.firstLesson,
        color: Colors.amber,
        earned: totalUnlocked >= 1,
      ),
      _Achievement(
        icon: Icons.local_fire_department,
        label: l10n.streak3Days,
        color: Colors.orange,
        earned: totalUnlocked >= 3,
      ),
      _Achievement(
        icon: Icons.bolt,
        label: l10n.fastLearner,
        color: Colors.blue,
        earned: totalUnlocked >= 5,
      ),
      _Achievement(
        icon: Icons.school,
        label: l10n.diligentStudent,
        color: Colors.green,
        earned: totalCompleted >= 1,
      ),
      _Achievement(
        icon: Icons.military_tech,
        label: l10n.perfectScore,
        color: Colors.purple,
        earned: avgProgress >= 90,
      ),
      _Achievement(
        icon: Icons.book,
        label: l10n.bookworm,
        color: Colors.teal,
        earned: totalUnlocked >= 10,
      ),
      _Achievement(
        icon: Icons.emoji_events,
        label: l10n.champion,
        color: Colors.red,
        earned: totalCompleted >= 5,
      ),
      _Achievement(
        icon: Icons.explore,
        label: l10n.explorer,
        color: Colors.indigo,
        earned: subjectCount >= 2 && totalUnlocked >= 2,
      ),
      _Achievement(
        icon: Icons.workspace_premium,
        label: l10n.master,
        color: Colors.amber.shade800,
        earned: avgProgress >= 100,
      ),
    ];
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF2196F3);
    }
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatBadge({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Achievement {
  final IconData icon;
  final String label;
  final Color color;
  final bool earned;

  _Achievement({
    required this.icon,
    required this.label,
    required this.color,
    required this.earned,
  });
}

class _AchievementBadge extends StatelessWidget {
  final _Achievement achievement;

  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(achievement.label),
            content: Row(
              children: [
                Icon(achievement.icon, color: achievement.color, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    achievement.earned
                        ? AppLocalizations.of(context).achievementEarned
                        : AppLocalizations.of(context).achievementLocked,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context).ok),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: achievement.earned
              ? achievement.color.withOpacity(0.15)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: achievement.earned
                ? achievement.color.withOpacity(0.4)
                : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  achievement.icon,
                  size: 40,
                  color: achievement.earned
                      ? achievement.color
                      : Colors.grey[300],
                ),
                if (!achievement.earned)
                  const Icon(Icons.lock, size: 16, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              achievement.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: achievement.earned ? Colors.grey[800] : Colors.grey[400],
                    fontWeight: achievement.earned
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
