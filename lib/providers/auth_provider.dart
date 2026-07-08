import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleAuthProvider provider = GoogleAuthProvider();

    final userCredential = await FirebaseAuth.instance.signInWithPopup(
      provider,
    );

    final user = userCredential.user;

    if (user != null) {
      final doc = FirebaseFirestore.instance.collection("users").doc(user.uid);

      final snapshot = await doc.get();

      if (!snapshot.exists) {
        await doc.set({
          "uid": user.uid,
          "fullName": user.displayName ?? "",
          "email": user.email ?? "",
          "phone": "",
          "location": "",
          "photoUrl": user.photoURL ?? "",
          "role": "user",
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
    }

    return userCredential;
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}
