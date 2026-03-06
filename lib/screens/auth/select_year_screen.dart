import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/curriculum_provider.dart';
import '../../models/models.dart';

class SelectYearScreen extends StatefulWidget {
  const SelectYearScreen({Key? key}) : super(key: key);
  
  @override
  State<SelectYearScreen> createState() => _SelectYearScreenState();
}

class _SelectYearScreenState extends State<SelectYearScreen> {
  String? _selectedYearId;
  
  @override
  void initState() {
    super.initState();
    _loadYears();
  }
  
  Future<void> _loadYears() async {
    final curriculumProvider = context.read<CurriculumProvider>();
    await curriculumProvider.loadYears();
  }
  
  Future<void> _selectYear() async {
    if (_selectedYearId == null) return;
    
    final authProvider = context.read<AuthProvider>();
    await authProvider.selectYear(_selectedYearId!);
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final curriculumProvider = context.watch<CurriculumProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectYearTitle),
        automaticallyImplyLeading: false,
      ),
      body: curriculumProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Icon(
                    Icons.school_outlined,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.selectYearSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Years list
                  ...curriculumProvider.years.map((year) {
                    return _YearCard(
                      year: year,
                      isSelected: _selectedYearId == year.id,
                      onTap: () {
                        setState(() {
                          _selectedYearId = year.id;
                        });
                      },
                    );
                  }),
                  
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _selectedYearId == null || authProvider.isLoading
                        ? null
                        : _selectYear,
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(l10n.continueText),
                  ),
                ],
              ),
            ),
    );
  }
}

class _YearCard extends StatelessWidget {
  final Year year;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _YearCard({
    required this.year,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    width: 2,
                  ),
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  year.getLocalizedName(locale),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
