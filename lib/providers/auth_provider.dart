// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool isBooting = true;
  bool isAuthenticated = false;
  String? username; // for greeting

  Future<void> bootstrap() async {
    try {
      final session = Supa.client.auth.currentSession;
      isAuthenticated = session != null;
      username = await _storage.read(key: 'username');
    } finally {
      isBooting = false;
      notifyListeners();
    }
  }

  // lib/providers/auth_provider.dart
  Future<bool> signUp(String email, String password, String name) async {
    try {
      final res = await Supa.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name}, // metadata saved in Supabase
      );
      return res.user != null; // true if account created
    } catch (e) {
      debugPrint("SignUp error: $e");
      return false;
    }
  }


  Future<void> loginWithPassword({required String email, required String password}) async {
    final res = await Supa.client.auth.signInWithPassword(email: email, password: password);
    isAuthenticated = res.session != null;
    if (res.user != null) {
      username = res.user!.userMetadata?['username'] ?? res.user!.email?.split('@').first;
      await _storage.write(key: 'username', value: username);
    }
    notifyListeners();
  }

  Future<void> reauthenticateLocked({required String password}) async {
    // Uses email from stored session
    final user = Supa.client.auth.currentUser;
    if (user?.email == null) throw Exception('No saved session');
    await loginWithPassword(email: user!.email!, password: password);
  }

  Future<bool> tryBiometric() async {
    final auth = LocalAuthentication();
    final can = await auth.canCheckBiometrics;
    if (!can) return false;
    final ok = await auth.authenticate(localizedReason: 'Sign in to Cardtonics');
    if (ok) {
      isAuthenticated = Supa.client.auth.currentSession != null;
      notifyListeners();
    }
    return ok;
  }

  Future<void> logout() async {
    await Supa.client.auth.signOut();
    isAuthenticated = false;
    notifyListeners();
  }
}
