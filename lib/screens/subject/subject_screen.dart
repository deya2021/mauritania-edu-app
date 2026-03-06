import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/curriculum_provider.dart';
import '../../models/models.dart';
import '../lesson/lesson_screen.dart';

class SubjectScreen extends StatefulWidget {
  final Subject subject;
  final String userId;
  
  const SubjectScreen({
    Key? key,
    required this.subject,
    required this.userId,
  }) : super(key: key);
  
  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  @override
  void initState() {
    super.initState();
    _loadLessons();
  }
  
  Future<void> _loadLessons() async {
    final curriculumProvider = context.read<CurriculumProvider>();
    await curriculumProvider.loadLessons(widget.subject.id);
    await curriculumProvider.loadProgress(widget.userId, widget.subject.id);
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final curriculumProvider = context.watch<CurriculumProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.getLocalizedName(locale)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadLessons,
        child: curriculumProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: curriculumProvider.lessons.length,
                itemBuilder: (context, index) {
                  final lesson = curriculumProvider.lessons[index];
                  return _LessonCard(
                    lesson: lesson,
                    subject: widget.subject,
                    userId: widget.userId,
                    index: index,
                  );
                },
              ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final Subject subject;
  final String userId;
  final int index;
  
  const _LessonCard({
    required this.lesson,
    required this.subject,
    required this.userId,
    required this.index,
  });
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final curriculumProvider = context.watch<CurriculumProvider>();
    
    final isUnlocked = curriculumProvider.isLessonUnlocked(subject.id, lesson.id);
    final progress = curriculumProvider.getProgress(subject.id);
    final lessonProgress = progress?.lessonProgress[lesson.id];
    final completionPercentage = lessonProgress?.completionPercentage ?? 0.0;
    
    // Calculate time until next unlock
    Duration? timeUntilUnlock;
    if (!isUnlocked) {
      timeUntilUnlock = curriculumProvider.getTimeUntilNextUnlock(subject.id);
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: isUnlocked
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LessonScreen(
                      lesson: lesson,
                      subject: subject,
                      userId: userId,
                    ),
                  ),
                );
              }
            : () {
                _showLockedDialog(context, l10n, timeUntilUnlock);
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Lesson number badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? _parseColor(subject.color)
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isUnlocked
                      ? Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Lesson info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.getLocalizedTitle(locale),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isUnlocked ? null : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    if (isUnlocked) ...[
                      if (completionPercentage > 0) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: completionPercentage / 100,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _parseColor(subject.color),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${completionPercentage.toStringAsFixed(0)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          l10n.unlocked,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ] else ...[
                      Text(
                        timeUntilUnlock != null && timeUntilUnlock != Duration.zero
                            ? '${l10n.unlockIn}: ${_formatDuration(timeUntilUnlock, l10n)}'
                            : l10n.locked,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              Icon(
                isUnlocked ? Icons.chevron_right : Icons.lock_outline,
                color: isUnlocked ? null : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF2196F3);
    }
  }
  
  String _formatDuration(Duration duration, AppLocalizations l10n) {
    if (duration.inHours > 0) {
      return '${duration.inHours} ${l10n.hours}';
    } else {
      return '${duration.inMinutes} ${l10n.minutes}';
    }
  }
  
  void _showLockedDialog(BuildContext context, AppLocalizations l10n, Duration? timeUntilUnlock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.lessonLocked),
        content: Text(
          timeUntilUnlock != null && timeUntilUnlock != Duration.zero
              ? '${l10n.lessonLockedMessage}\n\n${l10n.unlockIn}: ${_formatDuration(timeUntilUnlock, l10n)}'
              : l10n.lessonLockedMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
