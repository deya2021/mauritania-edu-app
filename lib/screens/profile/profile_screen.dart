import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/curriculum_provider.dart';
import '../../models/models.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final curriculumProvider = context.watch<CurriculumProvider>();

    // Compute stats
    int totalUnlocked = 0;
    int totalCompleted = 0;
    double avgProgress = 0;
    for (final subject in curriculumProvider.subjects) {
      final p = curriculumProvider.getProgress(subject.id);
      if (p != null) {
        totalUnlocked += p.unlockedLessonIds.length;
        totalCompleted += p.lessonProgress.values
            .where((lp) => lp.completionPercentage >= 70)
            .length;
        avgProgress += curriculumProvider.getSubjectProgress(subject.id);
      }
    }
    if (curriculumProvider.subjects.isNotEmpty) {
      avgProgress = avgProgress / curriculumProvider.subjects.length;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Icon(Icons.person, size: 44, color: Colors.white),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.check, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    authProvider.currentUser?.phoneNumber ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      authProvider.currentUser?.selectedYearId?.replaceAll('_', ' ').toUpperCase() ?? '',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Learning stats
          Text(
            l10n.learningStats,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.lock_open,
                  value: '$totalUnlocked',
                  label: l10n.unlockedLessons,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  value: '$totalCompleted',
                  label: l10n.completedLessons,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up,
                  value: '${avgProgress.toStringAsFixed(0)}%',
                  label: l10n.overallProgress,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Settings
          Text(
            l10n.settings,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8),

          // Change year
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.school, color: Colors.blue, size: 20),
                  ),
                  title: Text(l10n.changeYear),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => _showYearSelectionDialog(context),
                ),
                const Divider(height: 1, indent: 60),

                // Change language
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.language, color: Colors.purple, size: 20),
                  ),
                  title: Text(l10n.changeLanguage),
                  subtitle: Text(
                    localeProvider.locale.languageCode == 'ar'
                        ? l10n.arabic
                        : l10n.french,
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => _showLanguageSelectionDialog(context),
                ),
                const Divider(height: 1, indent: 60),

                // Privacy policy
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.privacy_tip, color: Colors.teal, size: 20),
                  ),
                  title: Text(l10n.privacyPolicy),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => _showPrivacyPolicy(context, l10n),
                ),
                const Divider(height: 1, indent: 60),

                // About
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                  ),
                  title: Text(l10n.aboutApp),
                  subtitle: Text('${l10n.version} 1.0.0'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => _showAboutDialog(context, l10n),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Logout button
          ElevatedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.logout),
                  content: Text('${l10n.logout}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        l10n.logout,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/auth',
                    (route) => false,
                  );
                }
              }
            },
            icon: const Icon(Icons.logout),
            label: Text(l10n.logout),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.shade200),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _showYearSelectionDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.read<AuthProvider>();
    final curriculumProvider = context.read<CurriculumProvider>();

    if (curriculumProvider.years.isEmpty) {
      await curriculumProvider.loadYears();
    }

    final selectedYear = await showDialog<Year>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changeYear),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: curriculumProvider.years.map((year) {
              final locale = Localizations.localeOf(context).languageCode;
              final isSelected =
                  authProvider.currentUser?.selectedYearId == year.id;
              return ListTile(
                title: Text(year.getLocalizedName(locale)),
                trailing: isSelected
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
                onTap: () => Navigator.of(context).pop(year),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    if (selectedYear != null) {
      await authProvider.selectYear(selectedYear.id);
      await curriculumProvider.loadSubjects(selectedYear.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.success)),
        );
      }
    }
  }

  Future<void> _showLanguageSelectionDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final localeProvider = context.read<LocaleProvider>();

    final selectedLocale = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.arabic),
              leading: const Text('🇲🇷', style: TextStyle(fontSize: 20)),
              trailing: localeProvider.locale.languageCode == 'ar'
                  ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                  : null,
              onTap: () => Navigator.of(context).pop('ar'),
            ),
            ListTile(
              title: Text(l10n.french),
              leading: const Text('🇫🇷', style: TextStyle(fontSize: 20)),
              trailing: localeProvider.locale.languageCode == 'fr'
                  ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                  : null,
              onTap: () => Navigator.of(context).pop('fr'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    if (selectedLocale != null &&
        selectedLocale != localeProvider.locale.languageCode) {
      await localeProvider.setLocale(selectedLocale);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.success)),
        );
      }
    }
  }

  void _showPrivacyPolicy(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.privacyPolicy),
        content: SingleChildScrollView(
          child: Text(
            l10n.privacyContent,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
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

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.school, size: 48, color: Colors.blue),
      children: [
        const SizedBox(height: 8),
        Text(
          'تطبيق تعليمي للطلاب الموريتانيين\nApplication éducative pour les étudiants mauritaniens',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
