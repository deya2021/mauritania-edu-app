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
  
  @override
  void initState() {
    super.initState();
    _loadLessonContent();
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
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.getLocalizedTitle(locale)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lessonContent == null
              ? Center(child: Text(l10n.error))
              : Column(
                  children: [
                    // Top ad banner
                    const AdBanner(slotName: 'lesson_top'),
                    
                    // Lesson content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Lesson title
                            Text(
                              widget.lesson.getLocalizedTitle(locale),
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 16),
                            
                            // Summary section (always visible)
                            _SectionCard(
                              title: l10n.summary,
                              child: Text(
                                widget.lesson.getLocalizedSummary(locale),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Content sections
                            ..._lessonContent!.sections.map((section) {
                              return _SectionCard(
                                title: section.title,
                                isLocked: section.lockedInitially,
                                child: MarkdownBody(
                                  data: section.content,
                                  styleSheet: MarkdownStyleSheet(
                                    p: Theme.of(context).textTheme.bodyLarge,
                                    h1: Theme.of(context).textTheme.displaySmall,
                                    h2: Theme.of(context).textTheme.displaySmall,
                                    h3: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                              );
                            }),
                            
                            const SizedBox(height: 24),
                            
                            // Exercises section
                            if (_lessonContent!.exercises.isNotEmpty) ...[
                              Text(
                                l10n.exercises,
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.completeExercises,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              ..._lessonContent!.exercises.asMap().entries.map((entry) {
                                final index = entry.key;
                                final exercise = entry.value;
                                return ExerciseWidget(
                                  exercise: exercise,
                                  index: index + 1,
                                  onSubmit: (isCorrect) {
                                    _submitExerciseResult(exercise.id, isCorrect);
                                  },
                                  previousResult: _exerciseResults[exercise.id],
                                );
                              }),
                            ],
                            
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom ad banner
                    const AdBanner(slotName: 'lesson_bottom'),
                  ],
                ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isLocked;
  
  const _SectionCard({
    required this.title,
    required this.child,
    this.isLocked = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (isLocked)
                  const Icon(
                    Icons.lock_outline,
                    color: Colors.grey,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            isLocked
                ? Text(
                    AppLocalizations.of(context).lessonLockedMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  )
                : child,
          ],
        ),
      ),
    );
  }
}
