import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/curriculum_provider.dart';
import '../../models/models.dart';
import '../../widgets/ad_banner.dart';
import '../subject/subject_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final curriculumProvider = context.read<CurriculumProvider>();
    
    final yearId = authProvider.currentUser?.selectedYearId;
    if (yearId != null) {
      await curriculumProvider.loadSubjects(yearId);
      
      // Load progress for each subject
      for (final subject in curriculumProvider.subjects) {
        await curriculumProvider.loadProgress(
          authProvider.currentUser!.id,
          subject.id,
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();
    final curriculumProvider = context.watch<CurriculumProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            // Top ad banner
            const AdBanner(slotName: 'home_top'),
            
            // Subjects list
            Expanded(
              child: curriculumProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : curriculumProvider.subjects.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noSubjects,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: curriculumProvider.subjects.length,
                          itemBuilder: (context, index) {
                            final subject = curriculumProvider.subjects[index];
                            return _SubjectCard(
                              subject: subject,
                              userId: authProvider.currentUser!.id,
                            );
                          },
                        ),
            ),
            
            // Bottom ad banner
            const AdBanner(slotName: 'home_bottom'),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final String userId;
  
  const _SubjectCard({
    required this.subject,
    required this.userId,
  });
  
  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final curriculumProvider = context.watch<CurriculumProvider>();
    final l10n = AppLocalizations.of(context);
    
    // Calculate progress
    final progress = curriculumProvider.getProgress(subject.id);
    final progressPercentage = progress != null 
        ? curriculumProvider.getSubjectProgress(subject.id)
        : 0.0;
    
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SubjectScreen(
                subject: subject,
                userId: userId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Subject icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _parseColor(subject.color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: subject.iconUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: subject.iconUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.book,
                            size: 32,
                            color: _parseColor(subject.color),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.book,
                        size: 32,
                        color: _parseColor(subject.color),
                      ),
              ),
              const SizedBox(width: 16),
              
              // Subject info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.getLocalizedName(locale),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    
                    // Progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.progress,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${progressPercentage.toStringAsFixed(0)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressPercentage / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _parseColor(subject.color),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
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
}
