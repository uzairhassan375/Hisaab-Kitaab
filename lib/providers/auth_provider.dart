import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/preferences_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Load user from SharedPreferences first for instant UI
    _loadSavedUser();
    
    // Then listen to Firebase Auth state changes
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        // Fetch fresh user data from Firestore
        final userData = await _authService.getUserData(user.uid);
        if (userData != null) {
          _currentUser = userData;
          // Save to SharedPreferences for next time
          await PreferencesService.saveUserData(userData);
          notifyListeners();
        }
      } else {
        _currentUser = null;
        // Clear SharedPreferences
        await PreferencesService.clearUserData();
        notifyListeners();
      }
      if (!_isInitialized) {
        _isInitialized = true;
        notifyListeners();
      }
    });

    // Also check current Firebase Auth user on startup
    _checkCurrentUser();
  }

  Future<void> _loadSavedUser() async {
    try {
      final savedUser = await PreferencesService.getUserData();
      if (savedUser != null) {
        _currentUser = savedUser;
        notifyListeners();
      }
    } catch (e) {
      // Ignore errors, will fetch from Firebase
    }
  }

  Future<void> _checkCurrentUser() async {
    try {
      // If no saved user but Firebase has a user, load from Firestore
      if (_currentUser == null && _authService.currentUser != null) {
        final userData = await _authService.getUserData(_authService.currentUser!.uid);
        if (userData != null) {
          _currentUser = userData;
          await PreferencesService.saveUserData(userData);
          notifyListeners();
        }
      }
      if (!_isInitialized) {
        _isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      if (!_isInitialized) {
        _isInitialized = true;
        notifyListeners();
      }
    }
  }

  bool get isInitialized => _isInitialized;

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      _currentUser = await _authService.signInWithEmailAndPassword(email, password);
      if (_currentUser != null) {
        // Save user data to SharedPreferences
        await PreferencesService.saveUserData(_currentUser!);
      }
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      _isLoading = true;
      notifyListeners();
      _currentUser = await _authService.registerWithEmailAndPassword(email, password, name);
      if (_currentUser != null) {
        // Save user data to SharedPreferences
        await PreferencesService.saveUserData(_currentUser!);
      }
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    // Clear SharedPreferences
    await PreferencesService.clearUserData();
    notifyListeners();
  }

  Stream<User?> get authStateChanges => _authService.authStateChanges;
}

