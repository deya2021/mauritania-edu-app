import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../config/demo_config.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  
  String? _verificationId;
  
  auth.User? get currentUser => _firebaseAuth.currentUser;
  
  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();
  
  // Send OTP to phone number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function(auth.PhoneAuthCredential credential) onAutoVerify,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (auth.PhoneAuthCredential credential) async {
        onAutoVerify(credential);
      },
      verificationFailed: (auth.FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  }
  
  // Verify OTP code
  Future<auth.UserCredential> verifyOTP(String otp) async {
    if (_verificationId == null) {
      throw Exception('Verification ID not found');
    }
    
    final credential = auth.PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
    
    return await _firebaseAuth.signInWithCredential(credential);
  }
  
  // Sign in with phone credential (for auto-verify)
  Future<auth.UserCredential> signInWithCredential(
    auth.PhoneAuthCredential credential,
  ) async {
    return await _firebaseAuth.signInWithCredential(credential);
  }
  
  // Demo login (anonymous or fake)
  Future<auth.UserCredential> signInDemo() async {
    if (DemoConfig.USE_ANONYMOUS_AUTH) {
      return await _firebaseAuth.signInAnonymously();
    } else {
      // For web demo without Firebase configured, we'll handle in provider
      throw UnimplementedError('Use local demo mode');
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
  
  // Get current user ID
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }
  
  // Get current user phone number
  String? getCurrentUserPhone() {
    return _firebaseAuth.currentUser?.phoneNumber;
  }
}
