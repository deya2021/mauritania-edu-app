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
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authProvider.currentUser?.phoneNumber ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Settings section
          Text(
            l10n.settings,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          
          // Change year
          Card(
            child: ListTile(
              leading: const Icon(Icons.school),
              title: Text(l10n.changeYear),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showYearSelectionDialog(context);
              },
            ),
          ),
          
          // Change language
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.changeLanguage),
              subtitle: Text(
                localeProvider.locale.languageCode == 'ar'
                    ? l10n.arabic
                    : l10n.french,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showLanguageSelectionDialog(context);
              },
            ),
          ),
          
          // Privacy policy
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: Text(l10n.privacyPolicy),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Open privacy policy
                // This can be implemented with WebView
              },
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Logout button
          ElevatedButton(
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
                      child: Text(l10n.ok),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showYearSelectionDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.read<AuthProvider>();
    final curriculumProvider = context.read<CurriculumProvider>();
    
    // Load years if not already loaded
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
              return ListTile(
                title: Text(year.getLocalizedName(locale)),
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
      
      // Reload subjects for new year
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
              trailing: localeProvider.locale.languageCode == 'ar'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.of(context).pop('ar'),
            ),
            ListTile(
              title: Text(l10n.french),
              trailing: localeProvider.locale.languageCode == 'fr'
                  ? const Icon(Icons.check)
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
    
    if (selectedLocale != null && selectedLocale != localeProvider.locale.languageCode) {
      await localeProvider.setLocale(selectedLocale);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.success)),
        );
      }
    }
  }
}
