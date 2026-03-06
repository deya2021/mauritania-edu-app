import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../config/demo_config.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final SharedPreferences _prefs;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  AuthProvider({
    required AuthService authService,
    required FirestoreService firestoreService,
    required SharedPreferences prefs,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _prefs = prefs {
    _initializeAuth();
  }
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  
  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();
    
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      _currentUser = await _firestoreService.getUser(firebaseUser.uid);
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        _isLoading = false;
        notifyListeners();
        onCodeSent(verificationId);
      },
      onError: (error) {
        _error = error;
        _isLoading = false;
        notifyListeners();
        onError(error);
      },
      onAutoVerify: (credential) async {
        await _signInWithCredential(credential);
      },
    );
  }
  
  Future<bool> verifyOTP(String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final userCredential = await _authService.verifyOTP(otp);
      await _createOrUpdateUser(userCredential.user!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> _signInWithCredential(dynamic credential) async {
    try {
      final userCredential = await _authService.signInWithCredential(credential);
      await _createOrUpdateUser(userCredential.user!);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> _createOrUpdateUser(dynamic firebaseUser) async {
    final user = User(
      id: firebaseUser.uid,
      phoneNumber: firebaseUser.phoneNumber ?? '',
      selectedYearId: _currentUser?.selectedYearId,
      createdAt: _currentUser?.createdAt ?? DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    
    await _firestoreService.createOrUpdateUser(user);
    _currentUser = user;
  }
  
  Future<void> selectYear(String yearId) async {
    if (_currentUser == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await _firestoreService.updateUserYear(_currentUser!.id, yearId);
      _currentUser = User(
        id: _currentUser!.id,
        phoneNumber: _currentUser!.phoneNumber,
        selectedYearId: yearId,
        createdAt: _currentUser!.createdAt,
        lastLoginAt: _currentUser!.lastLoginAt,
      );
      await _prefs.setString('selectedYearId', yearId);
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Demo login
  Future<bool> signInDemo() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      if (DemoConfig.USE_ANONYMOUS_AUTH) {
        final userCredential = await _authService.signInDemo();
        await _createOrUpdateUser(userCredential.user!);
      } else {
        // Local demo mode - create fake user
        final user = User(
          id: DemoConfig.DEMO_USER_ID,
          phoneNumber: DemoConfig.DEMO_PHONE_NUMBER,
          selectedYearId: DemoConfig.DEMO_USER_YEAR,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        _currentUser = user;
        await _prefs.setString('demo_user_id', user.id);
        await _prefs.setString('selectedYearId', DemoConfig.DEMO_USER_YEAR);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    await _prefs.remove('selectedYearId');
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
