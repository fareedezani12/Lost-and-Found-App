import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;

  Future<void> login({required String email, required String password}) async {
    isLoading = true;
    notifyListeners();

    await _authService.login(email: email, password: password);

    isLoading = false;
    notifyListeners();
  }

  Future<void> signUp({required String email, required String password}) async {
    isLoading = true;
    notifyListeners();

    await _authService.signUp(email: email, password: password);

    isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}
