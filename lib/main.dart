import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/firebase_options.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/progress_service.dart';
import 'services/notification_service.dart';
import 'services/analytics_service.dart';
import 'services/crashlytics_service.dart';
import 'services/local_storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/curriculum_provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/phone_auth_screen.dart';
import 'screens/auth/select_year_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/demo_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Crashlytics
  final crashlyticsService = CrashlyticsService();
  await crashlyticsService.initialize();
  
  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Initialize Analytics
  final analyticsService = AnalyticsService();
  await analyticsService.logAppOpened();
  
  // Initialize Local Storage
  final localStorage = LocalStorageService();
  await localStorage.clearExpiredCache();
  
  final prefs = await SharedPreferences.getInstance();
  
  runApp(MyApp(
    prefs: prefs,
    analyticsService: analyticsService,
    notificationService: notificationService,
    crashlyticsService: crashlyticsService,
    localStorage: localStorage,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final AnalyticsService analyticsService;
  final NotificationService notificationService;
  final CrashlyticsService crashlyticsService;
  final LocalStorageService localStorage;
  
  const MyApp({
    Key? key,
    required this.prefs,
    required this.analyticsService,
    required this.notificationService,
    required this.crashlyticsService,
    required this.localStorage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<AnalyticsService>.value(value: analyticsService),
        Provider<NotificationService>.value(value: notificationService),
        Provider<CrashlyticsService>.value(value: crashlyticsService),
        Provider<LocalStorageService>.value(value: localStorage),
        
        // State Management
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: AuthService(),
            firestoreService: FirestoreService(),
            prefs: prefs,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CurriculumProvider(
            firestoreService: FirestoreService(),
            progressService: ProgressService(FirestoreService()),
          ),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            title: 'Mauritania Edu',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('ar', ''),
              Locale('fr', ''),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // Add Analytics Observer
            navigatorObservers: [
              analyticsService.getAnalyticsObserver(),
            ],
            home: const SplashScreen(),
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/demo-login': (context) => const DemoLoginScreen(),
              '/auth': (context) => const PhoneAuthScreen(),
              '/select-year': (context) => const SelectYearScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
