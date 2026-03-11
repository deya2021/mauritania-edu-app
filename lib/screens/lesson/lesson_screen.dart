import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../providers/curriculum_provider.dart';
import '../../widgets/ad_banner.dart';
import '../../widgets/exercise_widget.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  final Subject subject;
  final String userId;

  const LessonScreen({
    Key? key,
    required this.lesson,
    required this.subject,
    required this.userId,
  }) : super(key: key);

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  LessonContent? _lessonContent;
  bool _isLoading = true;
  Map<String, bool> _exerciseResults = {};
  Timer? _countdownTimer;
  Duration? _timeUntilNext;
  bool _showCompletionBanner = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLessonContent();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    final provider = context.read<CurriculumProvider>();
    final duration = provider.getTimeUntilNextUnlock(widget.subject.id);
    if (duration != null && duration.inSeconds > 0) {
      setState(() => _timeUntilNext = duration);
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          if (_timeUntilNext != null && _timeUntilNext!.inSeconds > 0) {
            _timeUntilNext = _timeUntilNext! - const Duration(seconds: 1);
          } else {
            timer.cancel();
            _timeUntilNext = null;
          }
        });
      });
    }
  }

  Future<void> _loadLessonContent() async {
    setState(() => _isLoading = true);

    final firestoreService = FirestoreService();
    final content = await firestoreService.getLessonContent(widget.lesson.id);

    setState(() {
      _lessonContent = content;
      _isLoading = false;
    });
  }

  Future<void> _submitExerciseResult(String exerciseId, bool isCorrect) async {
    setState(() {
      _exerciseResults[exerciseId] = isCorrect;
    });

    if (_lessonContent != null) {
      final curriculumProvider = context.read<CurriculumProvider>();
      await curriculumProvider.updateLessonProgress(
        widget.userId,
        widget.subject.id,
        widget.lesson.id,
        _lessonContent!.exercises.length,
        _exerciseResults,
      );

      // Check completion
      final correctCount =
          _exerciseResults.values.where((v) => v).length;
      final total = _lessonContent!.exercises.length;
      if (total > 0 && correctCount / total >= 0.7) {
        setState(() => _showCompletionBanner = true);
      }
    }
  }

  double get _exerciseProgress {
    if (_lessonContent == null || _lessonContent!.exercises.isEmpty) return 0;
    return _exerciseResults.length / _lessonContent!.exercises.length;
  }

  int get _correctCount =>
      _exerciseResults.values.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final subjectColor = _parseColor(widget.subject.color);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lesson.getLocalizedTitle(locale),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_lessonContent != null && _lessonContent!.exercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '$_correctCount/${_lessonContent!.exercises.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lessonContent == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(l10n.error,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadLessonContent,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Top ad
                    const AdBanner(slotName: 'lesson_top'),

                    // Progress bar for exercises
                    if (_lessonContent!.exercises.isNotEmpty)
                      LinearProgressIndicator(
                        value: _exerciseProgress,
                        minHeight: 4,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(subjectColor),
                      ),

                    // Countdown to next lesson
                    if (_timeUntilNext != null)
                      _NextLessonCountdown(
                        duration: _timeUntilNext!,
                        l10n: l10n,
                        color: subjectColor,
                      ),

                    // Completion banner
                    if (_showCompletionBanner)
                      _CompletionBanner(l10n: l10n, color: subjectColor),

                    // Lesson content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Lesson title
                            Text(
                              widget.lesson.getLocalizedTitle(locale),
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 8),

                            // Subject chip
                            ActionChip(
                              avatar: Icon(Icons.book,
                                  color: subjectColor, size: 16),
                              label: Text(
                                  widget.subject.getLocalizedName(locale)),
                              onPressed: () {},
                              backgroundColor:
                                  subjectColor.withOpacity(0.1),
                              labelStyle: TextStyle(color: subjectColor),
                            ),
                            const SizedBox(height: 16),

                            // Summary section
                            _SectionCard(
                              title: l10n.summary,
                              icon: Icons.summarize,
                              color: subjectColor,
                              child: Text(
                                widget.lesson.getLocalizedSummary(locale),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Content sections
                            ..._lessonContent!.sections
                                .asMap()
                                .entries
                                .map((entry) {
                              final index = entry.key;
                              final section = entry.value;
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12),
                                child: _SectionCard(
                                  title: section.title,
                                  icon: Icons.article,
                                  color: subjectColor,
                                  isLocked: section.lockedInitially,
                                  child: section.lockedInitially
                                      ? Text(
                                          l10n.lessonLockedMessage,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color: Colors.grey),
                                        )
                                      : MarkdownBody(
                                          data: section.content,
                                          styleSheet: MarkdownStyleSheet(
                                            p: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                            h1: Theme.of(context)
                                                .textTheme
                                                .displaySmall,
                                            h2: Theme.of(context)
                                                .textTheme
                                                .headlineMedium,
                                            h3: Theme.of(context)
                                                .textTheme
                                                .titleLarge,
                                          ),
                                        ),
                                ),
                              );
                            }),

                            // Exercises
                            if (_lessonContent!.exercises.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.quiz,
                                      color: subjectColor, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.exercises,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.completeExercises,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 16),

                              // Exercise progress chips
                              Row(
                                children: [
                                  _ExerciseStatChip(
                                    label:
                                        '${_exerciseResults.length}/${_lessonContent!.exercises.length}',
                                    icon: Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  _ExerciseStatChip(
                                    label: '$_correctCount ${l10n.correct}',
                                    icon: Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              ..._lessonContent!.exercises
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final exercise = entry.value;
                                return ExerciseWidget(
                                  exercise: exercise,
                                  index: index + 1,
                                  onSubmit: (isCorrect) {
                                    _submitExerciseResult(
                                        exercise.id, isCorrect);
                                  },
                                  previousResult:
                                      _exerciseResults[exercise.id],
                                );
                              }),
                            ],

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),

                    // Bottom ad
                    const AdBanner(slotName: 'lesson_bottom'),
                  ],
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
}

// ====================================================
// Next Lesson Countdown Widget
// ====================================================
class _NextLessonCountdown extends StatelessWidget {
  final Duration duration;
  final AppLocalizations l10n;
  final Color color;

  const _NextLessonCountdown({
    required this.duration,
    required this.l10n,
    required this.color,
  });

  String _formatDuration() {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '${l10n.nextLessonIn}: ',
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
          Text(
            _formatDuration(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================
// Completion Banner Widget
// ====================================================
class _CompletionBanner extends StatelessWidget {
  final AppLocalizations l10n;
  final Color color;

  const _CompletionBanner({required this.l10n, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.wellDone,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                Text(
                  l10n.lessonCompleted,
                  style: TextStyle(color: Colors.green.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================
// Section Card
// ====================================================
class _SectionCard extends StatefulWidget {
  final String title;
  final Widget child;
  final bool isLocked;
  final IconData icon;
  final Color color;

  const _SectionCard({
    required this.title,
    required this.child,
    required this.icon,
    required this.color,
    this.isLocked = false,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.isLocked
                          ? Colors.grey.withOpacity(0.1)
                          : widget.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.isLocked ? Icons.lock : widget.icon,
                      size: 18,
                      color: widget.isLocked ? Colors.grey : widget.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color:
                                widget.isLocked ? Colors.grey : null,
                          ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}

// ====================================================
// Exercise Stat Chip
// ====================================================
class _ExerciseStatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _ExerciseStatChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style:
                TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
