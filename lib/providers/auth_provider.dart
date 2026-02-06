import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (StorageService.isLoggedIn()) {
        _currentUser = StorageService.getUser();
        _isAuthenticated = _currentUser != null;
      }
    } catch (e) {
      _error = 'Failed to check auth status';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      if (email.isEmpty || password.isEmpty) {
        _error = 'Email and password are required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _error = 'Invalid credentials';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = UserModel.create(
        email: email,
        name: _extractNameFromEmail(email),
        role: UserRole.admin,
        phone: '+91 9876543210',
        department: 'Claims Processing',
      );

      await StorageService.saveUser(_currentUser!);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        _error = 'All fields are required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _error = 'Password must be at least 6 characters';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = UserModel.create(
        email: email,
        name: name,
        role: UserRole.user,
        phone: phone,
        department: 'Claims Processing',
      );

      await StorageService.saveUser(_currentUser!);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await StorageService.clearUser();
      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      _error = 'Logout failed';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await StorageService.saveUser(user);
      _currentUser = user;
    } catch (e) {
      _error = 'Failed to update profile';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _extractNameFromEmail(String email) {
    final localPart = email.split('@').first;
    final parts = localPart.split(RegExp(r'[._]'));
    return parts
        .map((p) => p.isNotEmpty ? '${p[0].toUpperCase()}${p.substring(1)}' : '')
        .join(' ');
  }
}
