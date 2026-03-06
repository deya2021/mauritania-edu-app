import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../config/demo_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }
  
  Future<void> _initialize() async {
    // Detect system locale
    final localeProvider = context.read<LocaleProvider>();
    localeProvider.detectSystemLocale(context);
    
    // Wait for a moment to show splash
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Check if demo mode
    if (DemoConfig.DEMO_MODE) {
      // In demo mode, go directly to demo login
      Navigator.of(context).pushReplacementNamed('/demo-login');
      return;
    }
    
    // Check authentication status
    final authProvider = context.read<AuthProvider>();
    
    if (!mounted) return;
    
    if (authProvider.isAuthenticated) {
      if (authProvider.currentUser?.selectedYearId != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/select-year');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.school,
                size: 64,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Mauritania Edu',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
