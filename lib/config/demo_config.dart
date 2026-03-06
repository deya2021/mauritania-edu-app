// Demo Mode Configuration
class DemoConfig {
  // Set to true to enable demo mode (bypasses phone OTP)
  static const bool DEMO_MODE = true;
  
  // Demo user credentials
  static const String DEMO_USER_ID = 'demo_user_001';
  static const String DEMO_PHONE_NUMBER = '+222 12 34 56 78';
  static const String DEMO_USER_YEAR = 'year_1';
  
  // For web: use anonymous auth or mock auth
  static const bool USE_ANONYMOUS_AUTH = true;
  
  // Local data fallback when Firestore is not configured
  static const bool USE_LOCAL_DATA_FALLBACK = true;
}
