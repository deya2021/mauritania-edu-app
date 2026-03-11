import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/curriculum_provider.dart';
import '../../models/models.dart';
import '../lesson/lesson_screen.dart';
import '../subject/subject_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _filterType = 'all'; // all, subjects, lessons

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_SearchResult> _getResults(
      CurriculumProvider provider, AuthProvider auth, String locale) {
    if (_query.trim().isEmpty) return [];

    final q = _query.toLowerCase();
    final results = <_SearchResult>[];

    // Search subjects
    for (final subject in provider.subjects) {
      final name = subject.getLocalizedName(locale).toLowerCase();
      if ((_filterType == 'all' || _filterType == 'subjects') &&
          name.contains(q)) {
        results.add(_SearchResult(
          type: 'subject',
          title: subject.getLocalizedName(locale),
          subtitle: '',
          icon: Icons.book,
          color: _parseColor(subject.color),
          data: subject,
        ));
      }
    }

    // Search lessons
    for (final lesson in provider.allLessons) {
      final title = lesson.getLocalizedTitle(locale).toLowerCase();
      final summary = lesson.getLocalizedSummary(locale).toLowerCase();
      if ((_filterType == 'all' || _filterType == 'lessons') &&
          (title.contains(q) || summary.contains(q))) {
        // Find subject for this lesson
        final subject = provider.subjects.firstWhere(
          (s) => s.id == lesson.subjectId,
          orElse: () => Subject(
            id: '',
            yearId: '',
            name: {},
            iconUrl: '',
            color: '#2196F3',
            order: 0,
          ),
        );
        results.add(_SearchResult(
          type: 'lesson',
          title: lesson.getLocalizedTitle(locale),
          subtitle: subject.getLocalizedName(locale),
          icon: Icons.menu_book,
          color: _parseColor(subject.color),
          data: {'lesson': lesson, 'subject': subject, 'userId': auth.currentUser?.id ?? ''},
        ));
      }
    }

    return results;
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF2196F3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final provider = context.watch<CurriculumProvider>();
    final auth = context.watch<AuthProvider>();

    final results = _getResults(provider, auth, locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.search),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: l10n.all,
                  selected: _filterType == 'all',
                  onSelected: () => setState(() => _filterType = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.subjects,
                  selected: _filterType == 'subjects',
                  onSelected: () => setState(() => _filterType = 'subjects'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.lessons,
                  selected: _filterType == 'lessons',
                  onSelected: () => setState(() => _filterType = 'lessons'),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _query.isEmpty
                ? _buildSearchSuggestions(context, l10n, provider, auth, locale)
                : results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noResults,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          return _SearchResultTile(
                            result: results[index],
                            onTap: () => _onResultTap(context, results[index], auth),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions(BuildContext context, AppLocalizations l10n,
      CurriculumProvider provider, AuthProvider auth, String locale) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recentSubjects,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (provider.subjects.isEmpty)
            Text(
              l10n.noSubjects,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.subjects.map((subject) {
                final color = _parseColor(subject.color);
                return ActionChip(
                  avatar: Icon(Icons.book, color: color, size: 18),
                  label: Text(subject.getLocalizedName(locale)),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SubjectScreen(
                          subject: subject,
                          userId: auth.currentUser?.id ?? '',
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          const SizedBox(height: 24),
          Text(
            l10n.browseAll,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...provider.subjects.map((subject) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _parseColor(subject.color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.book,
                      color: _parseColor(subject.color), size: 22),
                ),
                title: Text(subject.getLocalizedName(locale)),
                subtitle: Text(
                    '${provider.getLessonsCountForSubject(subject.id)} ${l10n.lessons}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SubjectScreen(
                        subject: subject,
                        userId: auth.currentUser?.id ?? '',
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _onResultTap(
      BuildContext context, _SearchResult result, AuthProvider auth) {
    if (result.type == 'subject') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SubjectScreen(
            subject: result.data as Subject,
            userId: auth.currentUser?.id ?? '',
          ),
        ),
      );
    } else if (result.type == 'lesson') {
      final data = result.data as Map<String, dynamic>;
      final lesson = data['lesson'] as Lesson;
      final subject = data['subject'] as Subject;
      final provider = context.read<CurriculumProvider>();
      final isUnlocked = provider.isLessonUnlocked(subject.id, lesson.id);

      if (isUnlocked) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LessonScreen(
              lesson: lesson,
              subject: subject,
              userId: data['userId'] as String,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).lessonLockedMessage),
          ),
        );
      }
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: selected ? Theme.of(context).primaryColor : Colors.grey[700],
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _SearchResult {
  final String type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final dynamic data;

  _SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.data,
  });
}

class _SearchResultTile extends StatelessWidget {
  final _SearchResult result;
  final VoidCallback onTap;

  const _SearchResultTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: result.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(result.icon, color: result.color, size: 22),
        ),
        title: Text(result.title),
        subtitle: result.subtitle.isNotEmpty ? Text(result.subtitle) : null,
        trailing: Icon(
          result.type == 'subject' ? Icons.chevron_right : Icons.menu_book,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }
}
