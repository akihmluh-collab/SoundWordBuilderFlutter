import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _loading = true;

  UserModel? get user => _user;
  bool get loading => _loading;
  bool get isAuthenticated => _user != null;
  bool get isTeacher => _user?.role == 'teacher';
  bool get hasActiveSubscription => _authService.isSubscriptionValid(_user!);

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        _user = await _authService.getUserProfile(firebaseUser.uid);
      } else {
        _user = null;
      }
      _loading = false;
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    notifyListeners();
    
    final user = await _authService.login(email, password);
    _user = user;
    _loading = false;
    notifyListeners();
    
    return user != null;
  }

  Future<bool> register(String email, String password, String name, String role) async {
    _loading = true;
    notifyListeners();
    
    final user = await _authService.register(email, password, name, role);
    _user = user;
    _loading = false;
    notifyListeners();
    
    return user != null;
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_user != null) {
      _user = await _authService.getUserProfile(_user!.uid);
      notifyListeners();
    }
  }
}